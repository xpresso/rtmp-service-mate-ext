package example;

import com.wowza.wms.amf.AMFDataArray;
import com.wowza.wms.amf.AMFDataItem;
import com.wowza.wms.amf.AMFDataList;
import com.wowza.wms.amf.AMFDataObj;
import com.wowza.wms.application.IApplicationInstance;
import com.wowza.wms.client.IClient;
import com.wowza.wms.logging.WMSLogger;
import com.wowza.wms.module.ModuleBase;
import com.wowza.wms.request.RequestFunction;

/**
 * @author Yura Zhloba
 */
public class ExampleApp extends ModuleBase
{
	WMSLogger log = getLogger();

	public void onAppStart(IApplicationInstance appInstance)
	{
		log.info("================");
		log.info("start ExampleApp");
	}

	public void onAppStop(IApplicationInstance appInstance)
	{
		log.info("onAppStop");
	}

	public void onConnect(IClient client, RequestFunction function, AMFDataList params)
	{
		log.info("onConnect " + client.getClientId());
	}

	public void login(IClient client, RequestFunction function, AMFDataList params)
	{
		String userName = String.valueOf(params.getString(PARAM1));
		log.info("login " + userName);

		sendResult(client, params, new AMFDataItem(userName));
	}

	public void getRooms(IClient client, RequestFunction function, AMFDataList params)
	{
		AMFDataArray amfArray = new AMFDataArray();
		amfArray.add(new AMFDataItem("Yellow Room"));
		amfArray.add(new AMFDataItem("Pink Room"));
		amfArray.add(new AMFDataItem("White Room"));

		sendResult(client, params, amfArray);
	}

	public void joinRoom(IClient client, RequestFunction function, AMFDataList params)
	{
		String roomName = String.valueOf(params.getString(PARAM1));
		log.info("client " + client.getClientId() + " has joined to room " + roomName);

		sendResult(client, params, new AMFDataItem(roomName));
	}

	public void sendMessage(IClient client, RequestFunction function, AMFDataList params)
	{
		AMFDataObj map = getParamObj(params, PARAM1);
		if(map == null) return;

		String senderName = map.getString("senderName");
		String content = map.getString("content");

		log.info("client " + senderName + " send message: " + content);

		AMFDataObj message = new AMFDataObj();
		message.put("senderName", "(" + senderName + ")");
		message.put("content", "{" + content + "}");

		client.getAppInstance().broadcastMsg("newMessage", message);

		sendResult(client, params, new AMFDataItem(true));
	}
}
