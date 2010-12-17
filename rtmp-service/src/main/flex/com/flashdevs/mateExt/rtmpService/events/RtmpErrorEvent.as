/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService.events
{
import flash.events.Event;

public class RtmpErrorEvent extends Event
{
	// constants
	static public const ERROR : String = "onRtmpError";

	// properties
	public var code : String;
	public var level : String;
	public var description : String;

	// constructor
	public function RtmpErrorEvent(type : String = ERROR,
								   bubbles : Boolean = true,
								   cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	public function init(code : String, level : String, description : String) : RtmpErrorEvent
	{
		this.code = code;
		this.level = level;
		this.description = description;
		return this;
	}

	override public function clone() : Event
	{
		return new RtmpErrorEvent().init(code, level, description);
	}

	public override function toString() : String
	{ return "RtmpErrorEvent"; }
}
}
