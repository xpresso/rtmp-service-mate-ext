/**
 * @author Yura Zhloba
 */
package
{
import com.flashdevs.mateExt.rtmpService.RtmpService;
import com.flashdevs.mateExt.rtmpService.events.RtmpErrorEvent;

import enums.AppState;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;

import vo.Message;

public class MainManager
{
	// properties
	[Bindable]
	public var appState : int = AppState.CONNECTING;

	[Bindable]
	public var userName : String = '';

	[Bindable]
	public var rooms : ArrayCollection;

	[Bindable]
	public var roomName : String;

	[Bindable]
	public var outputText : String = '';

	private var logger : ILogger = Log.getLogger('MainManager');

	// constructor
	public function MainManager()
	{
	}

	// methods
	public function onConnect() : void
	{
		logger.info('onConnect');

		appState = AppState.LOGIN;
	}

	public function onLogin(userName : String) : void
	{
		logger.info('onLogin [' + userName + ']');

		this.userName = userName;
	}

	public function onRooms(rooms : Array) : void
	{
		logger.info('onRooms [' + rooms + ']');

		this.rooms = new ArrayCollection(rooms);
		appState = AppState.SELECT_ROOM;
	}

	public function onJoinRoom(roomName : String) : void
	{
		logger.info('onJoinRoom [' + roomName + ']');

		this.roomName = roomName;
		appState = AppState.CHAT;
	}

	public function onSendMessage(data : Object) : void
	{
		logger.info('onSendMessage [' + data + ']');
	}

	public function onNewMessage(data : Object) : void
	{
		var message : Message;
		if(data is Message)
		{
			// data from FMS or Red5
			message = data as Message;
		}
		else
		{
			// data from Wowza
			message = new Message;
			message.senderName = data.senderName;
			message.content = data.content;
		}

		logger.info('onNewMessage ' + message.senderName + ' ' + message.content);
		outputText += message.senderName + ': ' + message.content + '\n';
	}

	public function onError(event : RtmpErrorEvent) : void
	{
		logger.error('onError ' + event.level + ' ' + event.code, event.description);
	}

	public function toString() : String
	{ return 'MainManager'; }
}
}