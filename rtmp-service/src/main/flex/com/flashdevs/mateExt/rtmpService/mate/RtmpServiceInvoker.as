/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService.mate
{
import com.flashdevs.mateExt.rtmpService.*;
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.actions.AbstractServiceInvoker;
import com.asfusion.mate.actions.IAction;
import com.asfusion.mate.actions.builders.serviceClasses.Request;
import com.asfusion.mate.core.*;
import com.flashdevs.mateExt.rtmpService.events.RtmpErrorEvent;
import com.flashdevs.mateExt.rtmpService.events.RtmpResultEvent;

[DefaultProperty('request')]
public class RtmpServiceInvoker extends AbstractServiceInvoker implements IAction
{
	// properties
	public var service : Class = RtmpService;

    private var serviceInst : RtmpService = null;

	public var request : Request;

	private var _callParams : Array;

	private var _cache : String = 'inherit';

	public function get cache() : String
	{ return _cache; }

	[Inspectable(enumeration='local,global,inherit,none')]
	public function set cache(value : String) : void
	{ _cache = value; }


	// methods
	override protected function prepare(scope : IScope) : void
	{
		super.prepare(scope);

		if(service == null) throw new Error('service must be set');

		serviceInst = Cache.getCachedInstance(service, _cache, scope) as RtmpService;
		if(serviceInst == null) throw new Error('rtmpService must be set');
		if(!serviceInst.connected) throw new Error('rtmpService must be connected');

		if(!request) throw new Error('request must be set');
		if(!request.action) throw new Error('request.action must be set');

		_callParams = getCallParams(scope);
	}

	private function getCallParams(scope : IScope) : Array
	{
		var params : Array;

		var data : Object = {};
		data = Properties.smartCopy(request, data, scope);

		var sa : SmartArguments = new SmartArguments();

		if(data.arguments && data.arguments.length > 0)
		{
			params = sa.getRealArguments(scope, data.arguments);
		}
		else params = [];

		params.unshift(sa.getRealArguments(scope, data.action));

		return params;
	}

	override protected function run(scope : IScope) : void
	{
		innerHandlersDispatcher = serviceInst.dispatcher;

		if(resultHandlers && resultHandlers.length > 0)
		{
			createInnerHandlers(scope, RtmpResultEvent.DATA, resultHandlers);
		}

		if(faultHandlers && faultHandlers.length > 0)
		{
			createInnerHandlers(scope, RtmpErrorEvent.ERROR, faultHandlers);
		}

		serviceInst.call.apply(serviceInst, _callParams);
	}

	public function toString() : String
	{ return 'RtmpServiceInvoker'; }
}
}