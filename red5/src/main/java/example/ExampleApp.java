package example;

import example.vo.Message;
import org.red5.logging.Red5LoggerFactory;
import org.red5.server.adapter.ApplicationAdapter;
import org.red5.server.api.IClient;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.Red5;
import org.red5.server.api.service.IServiceCapableConnection;
import org.slf4j.Logger;

import java.util.Set;

/**
 * @author Yura Zhloba
 */
public class ExampleApp extends ApplicationAdapter
{
	private static Logger logger = Red5LoggerFactory.getLogger(ExampleApp.class, "rtmp-service-mate-ext");

	@Override
	public boolean start(IScope app)
	{
		logger.info("================");
		logger.info("start ExampleApp");

		return super.start(app);
	}

	@Override
	public boolean connect(IConnection conn, IScope scope, Object[] params)
	{
		super.connect(conn, scope, params);

		IClient client = conn.getClient();

		logger.info("connect " + client.getId());

		return true;
	}

	@Override
	public void disconnect(IConnection conn, IScope scope)
	{
		super.disconnect(conn, scope);

		IClient client = conn.getClient();

		logger.info("disconnect " + client.getId());
	}

	public String login(String userName)
	{
		logger.info("login " + userName);

		IClient client = Red5.getConnectionLocal().getClient();
		client.setAttribute("userName", userName);

		return userName;
	}

	public String[] getRooms()
	{
		return new String[]{"Yellow Room", "Pink Room", "White Room"};
	}

	public String joinRoom(String roomName)
	{
		IClient client = Red5.getConnectionLocal().getClient();
		logger.info(client.getAttribute("userName") + " has joined to room " + roomName);

		return roomName;
	}

	public boolean sendMessage(Message message)
	{
		IClient client = Red5.getConnectionLocal().getClient();
		logger.info(client.getAttribute("userName") + " send message: " + message.content);

		Message newMessage = new Message();
		newMessage.senderName = "(" + message.senderName + ")";
		newMessage.content = "{" + message.content + "}";

		broadcast("newMessage", new Object[]{newMessage});

		return true;
	}

	private void broadcast(String method, Object[] data)
	{
		logger.info("broadcast");
		for(Set<IConnection> connections : scope.getConnections())
		{
			for(IConnection conn : connections)
			{
				if(conn instanceof IServiceCapableConnection)
				{
					logger.info("send to " + conn.getClient().getId());
					((IServiceCapableConnection) conn).invoke(method, data);
				}
			}
		}
	}

}
