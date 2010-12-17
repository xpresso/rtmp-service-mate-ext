/**
 * @author Yura Zhloba
 */
package com.flashdevs.mateExt.rtmpService.mate
{
import com.asfusion.mate.actionLists.IScope;
import com.asfusion.mate.actions.AbstractAction;
import com.asfusion.mate.actions.IAction;
import com.asfusion.mate.core.Cache;
import com.asfusion.mate.core.Creator;
import com.asfusion.mate.core.ISmartObject;
import com.flashdevs.mateExt.rtmpService.*;

public class CallbackRegistrator extends AbstractAction implements IAction
{
    public var service : Class = RtmpService;

    private var serviceInst : RtmpService = null;

    /**
     * callback name as it is called from media server
     */
    public var action : String;

    /**
     * target object which handle callback call
     */
    public var target : *;

    /**
     * target method which handle callback call
     */
    public var method : String;


    private var _serviceCache : String = "inherit";

    public function get serviceCache() : String
    { return _serviceCache; }

    [Inspectable(enumeration="local,global,inherit")]
    public function set serviceCache(value : String) : void
    { _serviceCache = value; }


    private var _targetCache : String = "inherit";

    public function get targetCache() : String
    { return _targetCache; }

    [Inspectable(enumeration="local,global,inherit")]
    public function set targetCache(value : String) : void
    { _targetCache = value; }

    override protected function prepare(scope : IScope) : void
    {
        if(service == null) throw new Error("service must be set");

        serviceInst = Cache.getCachedInstance(service, _serviceCache, scope) as RtmpService;
        if(serviceInst == null) throw new Error("rtmpService must be set");

        if(target is Class)
        {
            currentInstance = Cache.getCachedInstance(target, _targetCache, scope);
            if(!currentInstance)
            {
                var creator : Creator = new Creator(target, scope.dispatcher);
                currentInstance = creator.create(scope, true, null, _targetCache);
            }
        }
        else if(target is ISmartObject)
        {
            currentInstance = ISmartObject(target).getValue(scope);
        }
        else
        {
            currentInstance = target;
        }
    }

    override protected function run(scope : IScope) : void
    {
        serviceInst.registerCallback(action, currentInstance[method]);
    }

    public function toString() : String
    { return "CallbackRegistrator"; }
}
}