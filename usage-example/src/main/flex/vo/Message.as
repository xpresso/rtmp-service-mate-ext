/**
 * @author Yura Zhloba
 */

package vo
{
import flash.net.registerClassAlias;

registerClassAlias("example.vo.Message", vo.Message);

public class Message
{
	public var senderName : String;
	public var content : String;
}
}

