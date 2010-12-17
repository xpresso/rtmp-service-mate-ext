/**
 * @author Yura Zhloba
 */
package events
{
import flash.events.Event;

public class RoomEvent extends Event
{
	// constants
	static public const LOAD_LIST : String = "loadRoomList";
	static public const JOIN : String = "joinRoom";

	// properties
	public var roomName : String;

	// constructor
	public function RoomEvent(type : String,
							  bubbles : Boolean = true,
							  cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	public override function toString() : String
	{ return "RoomEvent"; }
}
}
