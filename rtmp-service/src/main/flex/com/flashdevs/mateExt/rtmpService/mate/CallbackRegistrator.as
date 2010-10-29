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


    private var _cache : String = "inherit";

    public function get cache() : String
    { return _cache; }

    [Inspectable(enumeration="local,global,inherit")]
    public function set cache(value : String) : void
    { _cache = value; }

    override protected function prepare(scope : IScope) : void
    {
        if(service == null) throw new Error('service must be set');

        serviceInst = Cache.getCachedInstance(service, _cache, scope) as RtmpService;
        if(serviceInst == null) throw new Error('rtmpService must be set');

        if(target is Class)
        {
            currentInstance = Cache.getCachedInstance(target, _cache, scope);
            if(!currentInstance)
            {
                var creator : Creator = new Creator(target, scope.dispatcher);
                currentInstance = creator.create(scope, true, null, _cache);
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
    { return 'CallbackRegistrator'; }
}
}