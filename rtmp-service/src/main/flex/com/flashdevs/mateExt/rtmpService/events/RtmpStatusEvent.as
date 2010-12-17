/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService.events
{
import flash.events.Event;

public class RtmpStatusEvent extends Event
{
	// constants
	static public const SUCCESS : String = "rtmpConnectionSuccess";
	static public const FAILED : String = "rtmpConnectionFailed";
	static public const REJECTED : String = "rtmpConnectionRejected";
	static public const DISCONNECTED : String = "rtmpConnectionDisconnected";
	static public const TRY_RECONNECT : String = "rtmpTryReconnect";
	static public const RECONNECT_FAILED : String = "rtmpReconnectFailed";

	// properties

	// constructor
	public function RtmpStatusEvent(type : String, bubbles : Boolean = true, cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	override public function clone() : Event
	{
		return new RtmpStatusEvent(type);
	}

	public override function toString() : String
	{ return "RtmpStatusEvent"; }
}
}
