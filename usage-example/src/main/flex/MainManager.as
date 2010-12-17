/**
 * @author Yura Zhloba
 */
package
{
import com.flashdevs.mateExt.rtmpService.events.RtmpErrorEvent;

import enums.AppState;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;
import mx.logging.Log;

import vo.Message;

public class MainManager
{
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

	private var log : ILogger = Log.getLogger('MainManager');

	public function onConnect() : void
	{
		log.info('onConnect');

		appState = AppState.LOGIN;
	}

	public function onLogin(userName : String) : void
	{
		log.info('onLogin [{0}]', userName);

		this.userName = userName;
	}

	public function onRooms(rooms : Array) : void
	{
		log.info('onRooms [{0}]', rooms);

		this.rooms = new ArrayCollection(rooms);
		appState = AppState.SELECT_ROOM;
	}

	public function onJoinRoom(roomName : String) : void
	{
		log.info('onJoinRoom [{0}]', roomName);

		this.roomName = roomName;
		appState = AppState.CHAT;
	}

	public function onSendMessage(data : Object) : void
	{
		log.info('onSendMessage [{0}]', data);
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

		log.info('onNewMessage {0} {1}', message.senderName, message.content);
		outputText += message.senderName + ': ' + message.content + '\n';
	}

	public function onError(event : RtmpErrorEvent) : void
	{
		log.error('onError {0} {1} {2}', event.level, event.code, event.description);
	}

	public function toString() : String
	{ return 'MainManager'; }
}
}