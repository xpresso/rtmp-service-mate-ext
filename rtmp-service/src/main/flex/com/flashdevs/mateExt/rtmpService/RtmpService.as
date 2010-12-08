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

public class RtmpService extends EventDispatcher
{
	// properties
	protected var _netConnection : NetConnection;

	public function get netConnection() : NetConnection
	{ return _netConnection; }

	public function get connected() : Boolean
	{ return _netConnection.connected; }


	protected var _client : RtmpClient = new RtmpClient();


	protected var _defaultDispatcher : IEventDispatcher = new EventDispatcher();
	protected var _dispatcher : IEventDispatcher;

	public function get dispatcher() : IEventDispatcher
	{ return _dispatcher; }

	public function set dispatcher(value : IEventDispatcher) : void
	{ _dispatcher = value; }


	private var logger : ILogger = Log.getLogger('RtmpService');

	private var reconnect : Reconnect;
	private var selfDisconnect : Boolean = false;

	// constructor
	public function RtmpService(dispatcher : IEventDispatcher = null,
								netConnection : NetConnection = null,
								useAMF0 : Boolean = false)
	{
		super();

		logger.debug('instance created');

		if(dispatcher == null)
		{
			_dispatcher = _defaultDispatcher;
		}
		else _dispatcher = dispatcher;

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
			throw new Error(this + ' is already connected!');
		}

		logger.info('connect to [' + rtmp + ']', data);

		selfDisconnect = false;
		reconnect.rtmp = rtmp;
		reconnect.connectData = data;
		_netConnection.connect(rtmp, data);
	}

	public function disconnect() : void
	{
		logger.info('disconnect');

		selfDisconnect = true;
		_netConnection.close();
	}

	public function initReconnect(numTries : uint, delay : uint) : void
	{
		logger.info("initReconnect " + numTries + " " + delay);

		reconnect.numTries = numTries;
		reconnect.delay = delay;
	}

	public function registerCallback(methodName : String, callback : Function) : void
	{
		logger.debug('registerCallback [' + methodName + ']');

		_client[methodName] = callback;
	}

	public function call(methodName : String, ... args) : void
	{
		logger.debug('call [' + methodName + ']', args);

		args.unshift(new Responder(onResult, onCallStatus));
		args.unshift(methodName);
		_netConnection.call.apply(_netConnection, args);
	}

	protected function onResult(data : *) : void
	{
		logger.debug('onResult ' + data);

		if(_dispatcher == _defaultDispatcher)
			logger.warn("default dispatcher used, event can`t be catch in mate event map");
		
		_dispatcher.dispatchEvent(new RtmpResultEvent().init(data));
	}

	protected function onCallStatus(data : Object) : void
	{
		logger.error('onCallStatus ' + data.level + ' ' + data.code, data.description);

		_dispatcher.dispatchEvent(new RtmpErrorEvent().init(data.code, data.level, data.description));
	}

	protected function onNetStatus(e : NetStatusEvent) : void
	{
		logger.info('onNetStatus ' + e.info.level + ' ' + e.info.code);

		if(_dispatcher == _defaultDispatcher)
			logger.warn("default dispatcher used, event can`t be catch in mate event map");

		switch(e.info.code)
		{
			case 'NetConnection.Connect.Success':
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.SUCCESS));
				break;

			case 'NetConnection.Connect.Rejected':
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.REJECTED));
				break;

			case 'NetConnection.Connect.Failed':
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.FAILED));
				break;

			case 'NetConnection.Connect.Closed':
				_dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.DISCONNECTED));
				if(!selfDisconnect)
				{
					_netConnection.close();
					reconnect.processDisconnect();
				}
				break;

			default: logger.error('unknown netStatus [' + e.info.code + ']');
		}
	}

	protected function onIOError(e : IOErrorEvent) : void
	{
		logger.error('IO error: ' + e.text);
	}

	protected function onSecurityError(e : SecurityErrorEvent) : void
	{
		logger.error('Security error: ' + e.text);
	}

	protected function onAsyncError(e : AsyncErrorEvent) : void
	{
		logger.error('AsyncError ' + e.toString());
	}

	override public function toString() : String
	{ return 'RtmpService'; }
}
}