local cast, typeof, new
do
    local _obj_0 = ffi
    cast, typeof, new = _obj_0.cast, _obj_0.typeof, _obj_0.new
end
local jmp, proc_bind
do
    local _obj_0 = require('hooks')
    jmp, proc_bind = _obj_0.jmp, _obj_0.proc_bind
end
local rawget
rawget = function(tbl, key)
    local mtb = getmetatable(tbl)
    setmetatable(tbl, nil)
    local res = tbl[key]
    setmetatable(tbl, mtb)
    return res
end
local rawset
rawset = function(tbl, key, value)
    local mtb = getmetatable(tbl)
    setmetatable(tbl, nil)
    tbl[key] = value
    return setmetatable(tbl, mtb)
end
local __thiscall
__thiscall = function(func, this)
    return function(...)
        return func(this, ...)
    end
end
local table_copy
table_copy = function(t)
    local _tbl_0 = { }
    for k, v in pairs(t) do
        _tbl_0[k] = v
    end
    return _tbl_0
end
local vtable_bind
vtable_bind = function(module, interface, index, typedef)
    local addr = cast("void***", utils.find_interface(module, interface)) or error(interface .. " is nil.")
    return __thiscall(cast(typedef, addr[0][index]), addr)
end
local vtable_thunk
vtable_thunk = function(index, typedef)
    return function(instance, ...)
        assert(instance)
        local addr = cast("void***", instance)
        return __thiscall(cast(typedef, addr[0][index]), addr)(...)
    end
end
local follow_call
follow_call = function(ptr)
    local insn = cast("uint8_t*", ptr)
    local _exp_0 = insn[0]
    if (0xE8 or 0xE9) == _exp_0 then
        return cast("uint32_t", insn + cast("int32_t*", insn + 1)[0] + 5)
    elseif 0xFF == _exp_0 then
        if insn[1] == 0x15 then
            return cast("uint32_t**", cast("const char*", ptr) + 2)[0][0]
        end
    end
end
local nullptr = new("void*")
local panorama = {
    panelIDs = { }
}
local vtable
do
    local _class_0
    local _base_0 = {
        get = function(self, index, t)
            return __thiscall(cast(t, self.this[0][index]), self.this)
        end,
        getInstance = function(self)
            return self.this
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, ptr)
            self.this = cast("void***", ptr)
        end,
        __base = _base_0,
        __name = "vtable"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    vtable = _class_0
end
local DllImport
do
    local _class_0
    local _base_0 = {
        cache = { },
        get = function(self, method, typedef)
            if not (self.cache[method]) then
                self.cache[method] = proc_bind(self.file, method, typedef)
            end
            return self.cache[method]
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, filename)
            self.file = filename
        end,
        __base = _base_0,
        __name = "DllImport"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    DllImport = _class_0
end
local UIEngine = vtable(vtable_bind("panorama.dll", "PanoramaUIEngine001", 11, "void*(__thiscall*)(void*)")())
local nativeIsValidPanelPointer = UIEngine:get(36, "bool(__thiscall*)(void*,void const*)")
local nativeGetLastDispatchedEventTargetPanel = UIEngine:get(56, "void*(__thiscall*)(void*)")
local nativeRunScript = UIEngine:get(113, "int(__thiscall*)(void*,void*,char const*,char const*,int,int,bool)")
local nativeGetV8GlobalContext = UIEngine:get(123, "void*(__thiscall*)(void*)")
local nativeGetIsolate = UIEngine:get(129, "void*(__thiscall*)(void*)")
local nativeGetParent = vtable_thunk(25, "void*(__thiscall*)(void*)")
local nativeGetID = vtable_thunk(9, "const char*(__thiscall*)(void*)")
local nativeFindChildTraverse = vtable_thunk(40, "void*(__thiscall*)(void*,const char*)")
local nativeGetJavaScriptContextParent = vtable_thunk(218, "void*(__thiscall*)(void*)")
local nativeGetPanelContext = __thiscall(cast("void***(__thiscall*)(void*,void*)", follow_call(utils.find_pattern("panorama.dll", "E8 ? ? ? ? 8B 00 85 C0 75 1B"))), UIEngine:getInstance())
local v8_dll = DllImport("v8.dll")
local Local, MaybeLocal, Value, Object, Array, Isolate, Context, HandleScope = nil
do
    local _class_0
    local _base_0 = {
        getInstance = function(self)
            return self.this
        end,
        __call = function(self)
            return Value(self.this[0])
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Local"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    Local = _class_0
end
do
    local _class_0
    local _base_0 = {
        getInstance = function(self)
            return self.this
        end,
        toLocalChecked = function(self)
            if not (self.this == nullptr) then
                return Local(self.this)
            end
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = cast("void**", val)
        end,
        __base = _base_0,
        __name = "MaybeLocal"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    MaybeLocal = _class_0
end
do
    local _class_0
    local _base_0 = {
        isUndefined = function(self)
            return v8_dll:get("?IsUndefined@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isNull = function(self)
            return v8_dll:get("?IsNull@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isBoolean = function(self)
            return v8_dll:get("?IsBoolean@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isBooleanObject = function(self)
            return v8_dll:get("?IsBooleanObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isNumber = function(self)
            return v8_dll:get("?IsNumber@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isNumberObject = function(self)
            return v8_dll:get("?IsNumberObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isString = function(self)
            return v8_dll:get("?IsString@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isStringObject = function(self)
            return v8_dll:get("?IsStringObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isObject = function(self)
            return v8_dll:get("?IsObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isArray = function(self)
            return v8_dll:get("?IsArray@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        isFunction = function(self)
            return v8_dll:get("?IsFunction@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        booleanValue = function(self)
            return v8_dll:get("?BooleanValue@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(self.this)
        end,
        numberValue = function(self)
            return v8_dll:get("?NumberValue@Value@v8@@QBENXZ", "double(__thiscall*)(void*)")(self.this)
        end,
        stringValue = function(self)
            local strBuf = new('char*[2]')
            local val = v8_dll:get("??0Utf8Value@String@v8@@QAE@V?$Local@VValue@v8@@@2@@Z", "struct{char* str; int length;}*(__thiscall*)(void*,void*)")(strBuf, self.this)
            local s = ffi.string(val.str, val.length)
            v8_dll:get("??1Utf8Value@String@v8@@QAE@XZ", "void(__thiscall*)(void*)")(strBuf)
            return s
        end,
        toObject = function(self)
            return Object(MaybeLocal(v8_dll:get("?ToObject@Value@v8@@QBE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(self.this, new("int[1]"))):toLocalChecked()())
        end,
        toLocal = function(self)
            return Local(new("uintptr_t[1]", self.this))
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Value"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    Value = _class_0
end
do
    local _class_0
    local _parent_0 = Value
    local _base_0 = {
        get = function(self, key)
            return MaybeLocal(v8_dll:get("?Get@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@@Z", "void*(__thiscall*)(void*,void*,void*)")(self.this, new("int[1]"), key))
        end,
        set = function(self, key, value)
            return v8_dll:get("?Set@Object@v8@@QAE_NV?$Local@VValue@v8@@@2@0@Z", "bool(__thiscall*)(void*,void*,void*)")(self.this, key, value)
        end,
        getPropertyNames = function(self)
            return MaybeLocal(v8_dll:get("?GetPropertyNames@Object@v8@@QAE?AV?$Local@VArray@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(self.this, new("int[1]")))
        end,
        callAsFunction = function(self, args, recv, argc, argv)
            return MaybeLocal(v8_dll:get("?CallAsFunction@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@HQAV32@@Z", "void*(__thiscall*)(void*,void*,void*,int,void*)")(self.this, new("int[1]"), argc, argv))
        end,
        getIdentityHash = function(self)
            return v8_dll:get("?GetIdentityHash@Object@v8@@QAEHXZ", "int(__thiscall*)(void*)")(self.this)
        end
    }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Object",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    Object = _class_0
end
do
    local _class_0
    local _parent_0 = Object
    local _base_0 = {
        length = function(self)
            return v8_dll:get("?Length@Array@v8@@QBEIXZ", "uint32_t(__thiscall*)(void*)")(self.this)
        end
    }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Array",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    Array = _class_0
end
local Primitive
do
    local _class_0
    local _parent_0 = Value
    local _base_0 = {
        getValue = function(self)
            return self.this
        end,
        toString = function(self)
            return self.this:getValue():stringValue()
        end
    }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Primitive",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    Primitive = _class_0
end
local Null
do
    local _class_0
    local _parent_0 = Value
    local _base_0 = { }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, isolate)
            self.this = Value(cast("uintptr_t", isolate) + 0x48)
        end,
        __base = _base_0,
        __name = "Null",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    Null = _class_0
end
local Boolean
do
    local _class_0
    local _parent_0 = Value
    local _base_0 = { }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, isolate, bool)
            self.this = Value(cast("uintptr_t", isolate) + ((function()
                if bool then
                    return 0x4C
                else
                    return 0x50
                end
            end)()))
        end,
        __base = _base_0,
        __name = "Boolean",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    Boolean = _class_0
end
local Number
do
    local _class_0
    local _parent_0 = Value
    local _base_0 = {
        getValue = function(self)
            return self.this:numberValue()
        end,
        getInstance = function(self)
            return self.this
        end
    }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, isolate, val)
            self.this = MaybeLocal(v8_dll:get("?New@Number@v8@@SA?AV?$Local@VNumber@v8@@@2@PAVIsolate@2@N@Z", "void*(__cdecl*)(void*,void*,double)")(new("int[1]"), isolate, tonumber(val))):toLocalChecked()()
        end,
        __base = _base_0,
        __name = "Number",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    Number = _class_0
end
local String
do
    local _class_0
    local _parent_0 = Value
    local _base_0 = {
        getValue = function(self)
            return self.this:stringValue()
        end,
        getInstance = function(self)
            return self.this
        end
    }
    _base_0.__index = _base_0
    setmetatable(_base_0, _parent_0.__base)
    _class_0 = setmetatable({
        __init = function(self, isolate, val)
            self.this = MaybeLocal(v8_dll:get("?NewFromUtf8@String@v8@@SA?AV?$MaybeLocal@VString@v8@@@2@PAVIsolate@2@PBDW4NewStringType@2@H@Z", "void*(__cdecl*)(void*,void*,const char*,int,int)")(new("int[1]"), isolate, val, 0, #val)):toLocalChecked()()
        end,
        __base = _base_0,
        __name = "String",
        __parent = _parent_0
    }, {
        __index = function(cls, name)
            local val = rawget(_base_0, name)
            if val == nil then
                local parent = rawget(cls, "__parent")
                if parent then
                    return parent[name]
                end
            else
                return val
            end
        end,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    if _parent_0.__inherited then
        _parent_0.__inherited(_parent_0, _class_0)
    end
    String = _class_0
end
do
    local _class_0
    local _base_0 = {
        enter = function(self)
            return v8_dll:get("?Enter@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(self.this)
        end,
        exit = function(self)
            return v8_dll:get("?Exit@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(self.this)
        end,
        getCurrentContext = function(self)
            return v8_dll:get("?GetCurrentContext@Isolate@v8@@QAE?AV?$Local@VContext@v8@@@2@XZ", "void**(__thiscall*)(void*,void*)")(nativeGetIsolate(), new("int[1]"))
        end,
        getInstance = function(self)
            return self.this
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Isolate"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    Isolate = _class_0
end
do
    local _class_0
    local _base_0 = {
        enter = function(self)
            return v8_dll:get("?Enter@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(self.this)
        end,
        exit = function(self)
            return v8_dll:get("?Exit@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(self.this)
        end,
        global = function(self)
            return MaybeLocal(v8_dll:get("?Global@Context@v8@@QAE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(self.this, new("int[1]")))
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self, val)
            self.this = val
        end,
        __base = _base_0,
        __name = "Context"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    Context = _class_0
end
do
    local _class_0
    local _base_0 = {
        enter = function(self)
            return v8_dll:get("??0HandleScope@v8@@QAE@PAVIsolate@1@@Z", "void(__thiscall*)(void*,void*)")(self.this, nativeGetIsolate())
        end,
        exit = function(self)
            return v8_dll:get("??1HandleScope@v8@@QAE@XZ", "void(__thiscall*)(void*)")(self.this)
        end,
        createHandle = function(self, val)
            return v8_dll:get("?CreateHandle@HandleScope@v8@@KAPAPAVObject@internal@2@PAVIsolate@42@PAV342@@Z", "void*(__cdecl*)(void*,void*)")(nativeGetIsolate(), val)
        end,
        __call = function(self, func, panel)
            local isolate = Isolate(nativeGetIsolate())
            isolate:enter()
            self:enter()
            local ctx
            if panel then
                ctx = nativeGetPanelContext(nativeGetJavaScriptContextParent(panel))[0]
            else
                ctx = Context(Isolate():getCurrentContext():toLocalChecked()()):global():getInstance()
            end
            ctx = Context((function()
                if ctx ~= nullptr then
                    return self:createHandle(ctx[0])
                else
                    return 0
                end
            end)())
            ctx:enter()
            local val = func()
            ctx:exit()
            self:exit()
            isolate:exit()
            return val
        end
    }
    _base_0.__index = _base_0
    _class_0 = setmetatable({
        __init = function(self)
            self.this = new("char[0xC]")
        end,
        __base = _base_0,
        __name = "HandleScope"
    }, {
        __index = _base_0,
        __call = function(cls, ...)
            local _self_0 = setmetatable({}, _base_0)
            cls.__init(_self_0, ...)
            return _self_0
        end
    })
    _base_0.__class = _class_0
    HandleScope = _class_0
end
local PanelInfo_t = typeof([[    struct {
        char* pad1[0x4];
        void*         m_pPanel;
        void* unk1;
    }
]])
local CUtlVector_Constructor_t = typeof([[    struct {
        struct {
            $ *m_pMemory;
            int m_nAllocationCount;
            int m_nGrowSize;
        } m_Memory;
        int m_Size;
        $ *m_pElements;
    }
]], PanelInfo_t, PanelInfo_t)
ffi.metatype(CUtlVector_Constructor_t, {
    __index = {
        Count = function(cdata)
            return cdata.m_Memory.m_nAllocationCount
        end,
        Element = function(cdata, i)
            return cast(typeof("$&", PanelInfo_t), cdata.m_Memory.m_pMemory[i])
        end,
        RemoveAll = function(this)
            this = nil
            this = typeof("$[?]", CUtlVector_Constructor_t)(1)[0]
            this.m_Size = 0
        end
    },
    __ipairs = function(panelArray)
        local current, size = 0, panelArray:Count()
        return function()
            current = current + 1
            local pPanel = panelArray:Element(current - 1).m_pPanel
            if current <= size and nativeIsValidPanelPointer(pPanel) then
                return current, pPanel
            end
        end
    end
})
local panelList = typeof("$[?]", CUtlVector_Constructor_t)(1)[0]
local panelArrayOffset = cast("unsigned int*", cast("uintptr_t**", UIEngine:getInstance())[0][36] + 21)[0]
local panelArray = cast(panelList, cast("uintptr_t", UIEngine:getInstance()) + panelArrayOffset)
panorama.GetPanel = function(panelName)
    local cachedPanel = panorama.panelIDs[panelName]
    if cachedPanel ~= nil and nativeIsValidPanelPointer(cachedPanel) and ffi.string(nativeGetID(cachedPanel)) == panelName then
        return cachedPanel
    end
    panorama.panelIDs = { }
    local pPanel = nullptr
    for i, v in ipairs(panelArray) do
        local curPanelName = ffi.string(nativeGetID(v))
        if curPanelName ~= "" then
            panorama.panelIDs[curPanelName] = v
            if curPanelName == panelName then
                pPanel = v
                break
            end
        end
    end
    if pPanel == nullptr then
        error("Failed to get target panel " .. tostring(panelName))
    end
    return pPanel
end
local test = HandleScope()
local testFunc
testFunc = function()
    local isolate = nativeGetIsolate()
    return print(String(isolate, "hello world"):getValue())
end
test(testFunc, panorama.GetPanel("CSGOJsRegistration"))
return 0