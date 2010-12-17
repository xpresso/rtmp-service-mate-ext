/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService.events
{
import flash.events.Event;

public class RtmpDataEvent extends Event
{
	// constants
	static public const DATA : String = "onRtmpData";

	// properties
	public var methodName : String;
	public var args : Array;

	// constructor
	public function RtmpDataEvent(type : String = DATA,
								  bubbles : Boolean = true,
								  cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	public function init(methodName : String, args : Array) : RtmpDataEvent
	{
		this.methodName = methodName;
		this.args = args;
		return this;
	}

	override public function clone() : Event
	{
		return new RtmpDataEvent().init(methodName, args);
	}

	public override function toString() : String
	{ return "RtmpDataEvent"; }
}
}
