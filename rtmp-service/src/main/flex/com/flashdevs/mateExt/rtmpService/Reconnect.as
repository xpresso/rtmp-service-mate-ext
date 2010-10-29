/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService
{
import com.flashdevs.mateExt.rtmpService.events.RtmpStatusEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.logging.ILogger;
import mx.logging.Log;

internal class Reconnect
{
	// properties
	public var numTries : uint = 3;
	public var delay : uint = 20 * 1000; // miliseconds
	public var rtmp : String;
	public var connectData : Object;

	private var timer : Timer;
	private var service : RtmpService;

	private var logger : ILogger = Log.getLogger('RtmpService');

	public function Reconnect(service : RtmpService) : void
	{
		this.service = service; 
	}

	public function processDisconnect() : void
	{
		logger.info("process disconnect, try to reconnect in " + delay + " miliseconds");

		if(!timer)
		{
			timer = new Timer(delay, numTries);
			timer.addEventListener(TimerEvent.TIMER, doReconnect);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, giveUp);
		}
		else
		{
			timer.reset();
			timer.delay = delay;
			timer.repeatCount = numTries;
		}
		timer.start();
	}

	private function doReconnect(e : TimerEvent) : void
	{
		logger.info("trying to reconnect to " + rtmp);

		service.dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.TRY_RECONNECT));
		service.connect(rtmp, connectData);
	}

	private function giveUp(e : TimerEvent) : void
	{
		logger.error("failed to reconnect to " + rtmp);
		service.dispatcher.dispatchEvent(new RtmpStatusEvent(RtmpStatusEvent.RECONNECT_FAILED));
	}

	public function toString() : String
	{ return 'Reconnect'; }
}
}