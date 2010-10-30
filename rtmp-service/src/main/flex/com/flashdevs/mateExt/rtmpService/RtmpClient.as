/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService
{
import com.flashdevs.mateExt.rtmpService.events.RtmpDataEvent;

import flash.events.IEventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.logging.ILogger;
import mx.logging.Log;

internal class RtmpClient extends Proxy
{
	internal var dispatcher : IEventDispatcher;

	private var callbacks : Object = {};

	private var logger : ILogger = Log.getLogger('RtmpClient');

	flash_proxy override function setProperty(name : *, value : *) : void
	{
		logger.info('add callback [' + name + ']');

		callbacks[name] = value;
	}

	flash_proxy override function hasProperty(name : *) : Boolean
	{ return true; }

	flash_proxy override function callProperty(name : *, ... args) : *
	{
		logger.info('callProperty [' + name + ']', args);

		this[name].apply(this, args);
		return true;
	}

	flash_proxy override function getProperty(name : *) : *
	{
		logger.info('getProperty [' + name + ']');

		if(callbacks[name])
		{
			logger.info('use callback [' + name + ']');
			return callbacks[name];
		}

		return function(... args) : *
		{
			logger.info('dispatch RtmpDataEvent [' + name + ']', args);

			dispatcher.dispatchEvent(new RtmpDataEvent().init(name, args));

			return true;
		}
	}

	public function toString() : String
	{ return 'RtmpClient'; }
}
}