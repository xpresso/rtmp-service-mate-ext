/**
 * @author Yura Zhloba
 */
package events
{
import flash.events.Event;

public class LoginEvent extends Event
{
	// constants
	static public const LOGIN : String = "userLogin";

	// properties
	public var userName : String;

	// constructor
	public function LoginEvent(type : String = LOGIN,
							   bubbles : Boolean = true,
							   cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	// methods
	public override function toString() : String
	{ return "LoginEvent"; }
}
}
