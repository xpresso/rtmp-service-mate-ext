/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService.events
{
import flash.events.Event;

public class RtmpResultEvent extends Event
{
	// constants
	static public const DATA : String = "onRtmpResult";

	// properties
	public var data : Object;

	// constructor
	public function RtmpResultEvent(type : String = DATA,
									bubbles : Boolean = true,
									cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	public function init(data : Object) : RtmpResultEvent
	{
		this.data = data;
		return this;
	}

	override public function clone() : Event
	{
		return new RtmpResultEvent().init(data);
	}

	public override function toString() : String
	{ return "RtmpResultEvent"; }
}
}
