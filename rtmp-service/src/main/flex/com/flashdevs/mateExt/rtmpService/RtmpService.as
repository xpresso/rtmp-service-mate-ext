/**
 * @author Yura Zhloba
 *
 * Collaborate with rtmp server (FMS, Wowza, Red5)
 * Can be used without Mate
 *
 * If you want to work with RtmpService from Mate event map, add this to map:
 * <mt:Injectors target="{RtmpService}">
 *     <mt:PropertyInjector source="{scope}" targetKey="dispatcher" sourceKey="dispatcher"/>
 * </mt:Injectors>
 *
 * otherwise default EventDispatcher will be used and event can`t be catch in Mate event map.   
 *
 */
package com.flashdevs.mateExt.rtmpService
{
import com.flashdevs.mateExt.rtmpService.events.RtmpErrorEvent;
import com.flashdevs.mateExt.rtmpService.events.RtmpResultEvent;
import com.flashdevs.mateExt.rtmpService.events.RtmpStatusEvent;

import flash.events.AsyncErrorEvent;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.net.NetConnection;
import flash.net.ObjectEncoding;
import flash.net.Responder;

import mx.logging.ILogger;
import mx.logging.Log;

public class RtmpService
{
	// properties
	protected var _netConnection : NetConnection;

	public function get netConnection() : NetConnection
	{ return _netConnection; }

	public function get connected() : Boolean
	{ return _netConnection.connected; }


	protected var _client : RtmpClient;


	protected var _defaultDispatcher : IEventDispatcher = new EventDispatcher();
	protected var _dispatcher : IEventDispatcher;

	public function get dispatcher() : IEventDispatcher
	{ return _dispatcher; }

	public function set dispatcher(value : IEventDispatcher) : void
	{
		_dispatcher = value;
		log.debug("use dispatcher {0}", _dispatcher);
	}

	public var warnAboutDefaultDispatcher : Boolean = true;

	private var log : ILogger = Log.getLogger("RtmpService");

	private var reconnect : Reconnect;
	private var selfDisconnect : Boolean = false;

	private var instID : int = 0;
	static private var nextInstID : int = 0;

	// constructor
	public function RtmpService(dispatcher : IEventDispatcher = null,
								netConnection : NetConnection = null,
								useAMF0 : Boolean = false)
	{
		super();
		instID = ++nextInstID;

		log = Log.getLogger("RtmpService" + instID);
		log.debug("instance {0} created", instID);
		_client = new RtmpClient(instID);

		if(dispatcher == null) _dispatcher = _defaultDispatcher;
		else _dispatcher = dispatcher;
		log.debug("use dispatcher {0}", _dispatcher);

		_client.dispatcher = _dispatcher;

		if(netConnection == null)
		{
			_netConnection = new NetConnection();
			if(useAMF0) _netConnection.objectEncoding = ObjectEncoding.AMF0;
		}
		else _netConnection = netConnection;

		_netConnection.client = _client;

		_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		_netConnection.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);

		reconnect = new Reconnect(this);
	}

	// methods
	public function connect(rtmp : String, data : Object = null) : void
	{
		if(_netConnection.connected)
		{
			throw new Error(this + " is already connected!");
		}

		log.info("connect to [{0}]", rtmp);

		selfDisconnect = false;
		reconnect.rtmp = rtmp;
		reconnect.connectData = data;
		_netConnection.connect(rtmp, data);
	}

	public function disconnect() : void
	{
		log.info("disconnect");

		selfDisconnect = true;
		_netConnection.close();
	}

	public function initReconnect(numTries : uint, delay : uint) : void
	{
		log.info("initReconnect {0} {1}", numTries, delay);

		reconnect.numTries = numTries;
		reconnect.delay = delay;
	}

	public function registerCallback(methodName : String, callback : Function) : void
	{
		log.debug("registerCallback [{0}]", methodName);

		_client[methodName] = callback;
	}

	public function callWithResponder(methodName : String, responder : Responder, ... args) : void
	{
		log.debug("callWithResponder {0} {1}", methodName, args);

		args.unshift(responder);
		args.unshift(methodName);
		_netConnection.call.apply(_netConnection, args);
	}

	public function call(methodName : String, ... args) : void
	{
		log.debug("call {0} {1}", methodName, args);

		// NOTE: usual mistake is to call service.call("method", null, param1, param2);
		// instead of service.call("method", param1, param2);
		if(args[0] == null)
		{
			log.warn("RtmpService.call [{0}] is called with null in first argument", methodName);
		}

		args.unshift(new Responder(onResult, onCallStatus));
		args.unshift(methodName);
		_netConnection.call.apply(_netConnection, args);
	}

	protected function onResult(data : *) : void
	{
		log.debug("onResult {0}", data);

		if(warnAboutDefaultDispatcher && _dispatcher == _defaultDispatcher)
			log.warn("default dispatcher used, event can`t be catch in mate event map");
		
		_dispatcher.dispatchEvent(new RtmpResultEvent().init(data));
	}

	protected function onCallStatus(data : Object) : void
	{
		log.error("onCallStatus {0} {1} {2}", data.level, data.code, data.description);

		_dispatcher.dispatchEvent(new RtmpErrorEvent().init(data.code, data.level, data.description));
	}

	protected function onNetStatus(e : NetStatusEvent) : void
	{
		log.info("onNetStatus {0} {1}", e.info.level, e.info.code);

		if(warnAboutDefaultDispatcher && _dispatcher == _defaultDispatcher)
			log.warn("default dispatcher used, event can`t be catch in mate event map");

		switch(e.info.code)
		{
			case "NetConnection.Connect.Success":
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.SUCCESS));
				reconnect.stop();
				break;

			case "NetConnection.Connect.Rejected":
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.REJECTED));
				break;

			case "NetConnection.Connect.Failed":
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.FAILED));
				break;

			case "NetConnection.Connect.Closed":
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.DISCONNECTED));
				if(!selfDisconnect)
				{
					_netConnection.close();
					reconnect.processDisconnect();
				}
				break;

			default: log.error("unknown netStatus [{0}]", e.info.code);
		}
	}

	protected function onIOError(e : IOErrorEvent) : void
	{
		log.error("IO error: {0}", e.text);
	}

	protected function onSecurityError(e : SecurityErrorEvent) : void
	{
		log.error("Security error: {0}", e.text);
	}

	protected function onAsyncError(e : AsyncErrorEvent) : void
	{
		log.error("AsyncError {0}", e.toString());
	}

	public function toString() : String
	{ return "RtmpService"; }
}
}