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

	private var log : ILogger = Log.getLogger('RtmpClient');

	flash_proxy override function setProperty(name : *, value : *) : void
	{
		log.debug('add callback [{0}]', name);

		callbacks[name] = value;
	}

	flash_proxy override function hasProperty(name : *) : Boolean
	{ return true; }

	flash_proxy override function callProperty(name : *, ... args) : *
	{
		log.debug('callProperty [{0}], {1}', name, args);

		this[name].apply(this, args);
		return true;
	}

	flash_proxy override function getProperty(name : *) : *
	{
		log.debug('getProperty [{0}]', name);

		if(callbacks[name])
		{
			log.debug('use callback [{0}]', name);
			return callbacks[name];
		}

		return function(... args) : *
		{
			log.debug('dispatch RtmpDataEvent [{0}], {1}', name, args);

			dispatcher.dispatchEvent(new RtmpDataEvent().init(name, args));

			return true;
		}
	}

	public function toString() : String
	{ return 'RtmpClient'; }
}
}