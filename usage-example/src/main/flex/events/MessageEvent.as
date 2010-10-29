/**
 * @author Yura Zhloba
 */
package events
{
import flash.events.Event;

import vo.Message;

public class MessageEvent extends Event
{
	// constants
	static public const SEND : String = 'sendMessage';

	// properties
	public var message : Message;

	// constructor
	public function MessageEvent(type : String = SEND,
								 bubbles : Boolean = true,
								 cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	public override function toString() : String
	{ return "MessageEvent"; }
}
}
