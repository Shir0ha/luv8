-- Devs
--------------------------------------------------
--                                              --
--										 Yukino --
--									  agapornis --
--											   	--
--------------------------------------------------
local *

import cast, typeof, new from ffi
import jmp, proc_bind from require 'hooks'

--#pragma region helper_functions
safe_error = (msg) ->
    -- TODO: Will automatically call shutdown function to make sure nothing goes wrong. to be implemented.
    error(msg)
rawget = (tbl, key) ->
    mtb = getmetatable(tbl)
    setmetatable(tbl, nil)
    res = tbl[key]
    setmetatable(tbl, mtb)
    res
rawset = (tbl, key, value) ->
    mtb = getmetatable(tbl)
    setmetatable(tbl, nil)
    tbl[key] = value
    setmetatable(tbl, mtb)
__thiscall = (func, this) -> (...) -> func(this, ...)
table_copy = (t) -> {k, v for k, v in pairs t}
vtable_bind = (module, interface, index, typedef) ->
    addr = cast("void***", utils.find_interface(module, interface)) or safe_error(interface .. " is nil.")
    __thiscall(cast(typedef, addr[0][index]), addr)
vtable_thunk = (index, typedef) -> (instance, ...) ->
    assert(instance)
    addr = cast("void***", instance)
    __thiscall(cast(typedef, addr[0][index]), addr)(...)
follow_call = (ptr) ->
    insn = cast("uint8_t*", ptr)
    switch insn[0]
        when 0xE8 or 0xE9
            cast("uint32_t", insn + cast("int32_t*", insn + 1)[0] + 5)
        when 0xFF if insn[1] == 0x15
            cast("uint32_t**", cast("const char*", ptr) + 2)[0][0]
v8js_args = (...) ->
    argTbl = {...}
    iArgc = #argTbl
    pArgv = new(string.format("void*[%.f]", iArgc))
    for i = 1, iArgc do
        pArgv[i - 1] = Value\fromLua(argTbl[i])\getInternal!
    iArgc,pArgv
is_array = (val) ->
    i=1
    for _ in pairs(val) do
        if val[i] ~=nil then
            i=i+1
        else
            return false
    return i~=1

--#pragma endregion helper_functions
nullptr = new("void*")
intbuf = new("int[1]")
panorama = {
    panelIDs: {}
}

class vtable
    new: (ptr) => @this = cast("void***", ptr)
    get: (index, t) => __thiscall(cast(t, @this[0][index]), @this)
    getInstance: => @this

class DllImport
    cache: {}
    new: (filename) => @file = filename
    get: (method, typedef) =>
        @cache[method] = proc_bind(@file, method, typedef) unless @cache[method]
        @cache[method]

--#pragma region native_panorama_functions
UIEngine = vtable(vtable_bind("panorama.dll", "PanoramaUIEngine001", 11, "void*(__thiscall*)(void*)")!)
nativeIsValidPanelPointer = UIEngine\get(36, "bool(__thiscall*)(void*,void const*)")
nativeGetLastDispatchedEventTargetPanel = UIEngine\get(56, "void*(__thiscall*)(void*)")
nativeCompileRunScript = UIEngine\get(113, "void****(__thiscall*)(void*,void*,char const*,char const*,int,int,bool)")
nativeRunScriptSig=utils.find_pattern("panorama.dll", "E8 ? ? ? ? 8B 4C 24 10 FF 15 ? ? ? ?")
if nativeRunScriptSig==nil then
    nativeRunScriptSig=utils.find_pattern("panorama.dll", "E8 ? ? ? ? 50 8B 4C 24 14 FF 15 ? ? ? ?")
nativeRunScript = __thiscall(cast(typeof("void*(__thiscall*)(void*,void*,void*,void*,int,bool)"), follow_call(nativeRunScriptSig)), UIEngine\getInstance!)
nativeGetV8GlobalContext = UIEngine\get(123, "void*(__thiscall*)(void*)")
nativeGetIsolate = UIEngine\get(129, "void*(__thiscall*)(void*)")
nativeGetParent = vtable_thunk(25, "void*(__thiscall*)(void*)")
nativeGetID = vtable_thunk(9, "const char*(__thiscall*)(void*)")
nativeFindChildTraverse = vtable_thunk(40, "void*(__thiscall*)(void*,const char*)")
nativeGetJavaScriptContextParent = vtable_thunk(218, "void*(__thiscall*)(void*)")
nativeGetPanelContext = __thiscall(cast("void***(__thiscall*)(void*,void*)", follow_call(utils.find_pattern("panorama.dll", "E8 ? ? ? ? 8B 00 85 C0 75 1B"))), UIEngine\getInstance!)
jsContexts = {}
getJavaScriptContextParent = (panel) ->
    if jsContexts[panel]~=nil then return jsContexts[panel]
    jsContexts[panel]=nativeGetJavaScriptContextParent(panel)
    jsContexts[panel]
--#pragma endregion native_panorama_functions

--#pragma region native_v8_functions
v8_dll = DllImport("v8.dll")

class Local
    new: (val) => @this = cast("void**", val)
    getInternal: => @this
    globalize: =>
        Persistent(v8_dll\get("?GlobalizeReference@V8@v8@@CAPAPAVObject@internal@2@PAVIsolate@42@PAPAV342@@Z", "void*(__cdecl*)(void*,void*)")(nativeGetIsolate!, @this[0]))
    __call: => Value(@this[0])

class MaybeLocal
    new: (val) => @this = cast("void**", val)
    getInternal: => @this
    toLocalChecked: => Local(@this) unless @this[0] == nullptr

PersistentProxy_mt = {
    __index: (key) =>
        if rawget(@,"internal")[key]~=nil then
         return rawget(@,"internal")[key]
        ret = HandleScope!(() -> rawget(@,"this")\get!\toLocalChecked!!\toObject!\get(Value\fromLua(key)\getInternal!)\toLocalChecked!!\toLua!)
        if type(ret) == "table" then
            rawset(ret,"parent",rawget(@,"this"))
            rawget(@,"internal")[key]=ret
        ret
    __newindex: (key, value) =>
        rawget(@,"internal")[key]=nil
        HandleScope!(() -> rawget(@,"this")\get!\toLocalChecked!!\toObject!\set(Value\fromLua(key)\getInternal!,Value\fromLua(value)\getInternal!)\toLocalChecked!!\toLua!)
    __len: =>
        ret = 0
        if rawget(@,"this").baseType == "Array" then
            ret = HandleScope!(() -> rawget(@,"this")\get!\toLocalChecked!!\toArray!\length!)
        elseif rawget(@,"this").baseType == "Object" then
            ret = HandleScope!(() -> rawget(@,"this")\get!\toLocalChecked!!\toObject!\getPropertyNames!\toLocalChecked!!\toArray!\length!)
        ret
    __pairs: =>
        ret = () -> nil
        if rawget(@,"this").baseType == "Object" then
            HandleScope!(() ->
                keys = Array(rawget(@,"this")\get!\toLocalChecked!!\toObject!\getPropertyNames!\toLocalChecked!!)
                current, size = 0, keys\length!
                ret = () ->
                    current = current+1
                    key = keys[current-1]
                    if current <= size then
                        return key,@[key]
            )
        ret
    __ipairs: =>
        ret = () -> nil
        if rawget(@,"this").baseType == "Array" then
            HandleScope!(() ->
                current, size = 0, rawget(@,"this")\get!\toLocalChecked!!\toArray!\length!
                ret = () ->
                    current = current+1
                    if current <= size then
                        return current,@[current-1]
            )
        ret
    __call: (...) =>
        args = { ... }
        if rawget(@,"this").baseType ~= "Function" then safe_error("Attempted to call a non-function value: " .. rawget(@,"this").baseType)
        HandleScope!(() ->
            rawget(@,"this")\get!\toLocalChecked!!\toFunction!\setParent(rawget(@,"parent"))(unpack(args))\toLocalChecked!!\toLua!
        )
    __tostring: =>
        HandleScope!(() -> rawget(@,"this")\get!\toLocalChecked!!\stringValue!)
    __gc: =>
        rawget(@,"this")\disposeGlobal!
}

class Persistent
    new: (val, baseType="Value") =>
        @this = val
        @baseType=baseType
    setType: (val) =>
        @baseType=val
        @
    getInternal: => @this
    disposeGlobal: =>
        v8_dll\get("?DisposeGlobal@V8@v8@@CAXPAPAVObject@internal@2@@Z","void(__cdecl*)(void*)")(@this)
    get: => MaybeLocal(HandleScope\createHandle(@this))
    toLua: => -- should NOT be used if the persistent is an object!!!! cuz it will just return the same thing again
        @get!\toLocalChecked!!\toLua!
    getIdentityHash: => v8_dll\get("?GetIdentityHash@Object@v8@@QAEHXZ", "int(__thiscall*)(void*)")(@this)
    __call: =>
        setmetatable({this: self, parent: nil, internal: {}}, PersistentProxy_mt)

class Value
    new: (val) => @this = cast("void*", val)
    fromLua: (val) =>
        if val==nil then return Null(nativeGetIsolate!)\getValue!
        if type(val) == "boolean" then return Boolean(nativeGetIsolate!,val)\getValue!
        if type(val) == "number" then return Number(nativeGetIsolate!,val)\getInstance!
        if type(val) == "string" then return String(nativeGetIsolate!,val)\getInstance!
        if type(val) == "table" and is_array(val) then return Array\fromLua(nativeGetIsolate!,val)
        if type(val) == "table" then return Object\fromLua(nativeGetIsolate!,val)
        safe_error("Failed to convert from lua to v8js: Unknown type")
    isUndefined: => v8_dll\get("?IsUndefined@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isNull: => v8_dll\get("?IsNull@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isBoolean: => v8_dll\get("?IsBoolean@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isBooleanObject: => v8_dll\get("?IsBooleanObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isNumber: => v8_dll\get("?IsNumber@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isNumberObject: => v8_dll\get("?IsNumberObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isString: => v8_dll\get("?IsString@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isStringObject: => v8_dll\get("?IsStringObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isObject: => v8_dll\get("?IsObject@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isArray: => v8_dll\get("?IsArray@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    isFunction: => v8_dll\get("?IsFunction@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    booleanValue: => v8_dll\get("?BooleanValue@Value@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    numberValue: => v8_dll\get("?NumberValue@Value@v8@@QBENXZ", "double(__thiscall*)(void*)")(@this)
    stringValue: =>
        strBuf = new('char*[2]')
        val = v8_dll\get("??0Utf8Value@String@v8@@QAE@V?$Local@VValue@v8@@@2@@Z", "struct{char* str; int length;}*(__thiscall*)(void*,void*)")(strBuf, @this)
        s = ffi.string(val.str, val.length)
        v8_dll\get("??1Utf8Value@String@v8@@QAE@XZ", "void(__thiscall*)(void*)")(strBuf)
        s
    toObject: =>
        Object(MaybeLocal(v8_dll\get("?ToObject@Value@v8@@QBE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, intbuf))\toLocalChecked!!\getInternal!)
    toArray: =>
        Array(MaybeLocal(v8_dll\get("?ToObject@Value@v8@@QBE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, intbuf))\toLocalChecked!!\getInternal!)
    toFunction: =>
        Function(MaybeLocal(v8_dll\get("?ToObject@Value@v8@@QBE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, intbuf))\toLocalChecked!!\getInternal!)
    toLocal: =>
        Local(new("void*[1]",@this))
    toLua: =>
        if @isUndefined! or @isNull! then return nil
        if @isBoolean! or @isBooleanObject! then return @booleanValue!
        if @isNumber! or @isNumberObject! then return @numberValue!
        if @isString! or @isStringObject! then return @stringValue!
        if @isObject! then -- returns persistent proxy
            if @isArray! then return @toArray!\toLocal!\globalize!\setType("Array")!
            if @isFunction! then return @toFunction!\toLocal!\globalize!\setType("Function")!
            return @toObject!\toLocal!\globalize!\setType("Object")!
        safe_error("Failed to convert from v8js to lua: Unknown type")
    getInternal: => @this

class Object extends Value
    new: (val) => @this = val
    fromLua: (isolate, val) =>
        obj = Object(MaybeLocal(v8_dll\get("?New@Object@v8@@SA?AV?$Local@VObject@v8@@@2@PAVIsolate@2@@Z","void*(__cdecl*)(void*,void*)")(intbuf, isolate))\toLocalChecked!!\getInternal!)
        for i,v in pairs(val) do
            obj\set(Value\fromLua(i)\getInternal!,Value\fromLua(v)\getInternal!)
        obj
    get: (key) =>
        MaybeLocal(v8_dll\get("?Get@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@@Z", "void*(__thiscall*)(void*,void*,void*)")(@this, intbuf, key))
    set: (key, value) => v8_dll\get("?Set@Object@v8@@QAE_NV?$Local@VValue@v8@@@2@0@Z", "bool(__thiscall*)(void*,void*,void*)")(@this, key, value)
    getPropertyNames: =>
        MaybeLocal(v8_dll\get("?GetPropertyNames@Object@v8@@QAE?AV?$Local@VArray@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, intbuf))
    callAsFunction: (recv, argc, argv) =>
        MaybeLocal(v8_dll\get("?CallAsFunction@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@HQAV32@@Z", "void*(__thiscall*)(void*,void*,void*,int,void*)")(@this, intbuf,recv, argc, argv))
    getIdentityHash: => v8_dll\get("?GetIdentityHash@Object@v8@@QAEHXZ", "int(__thiscall*)(void*)")(@this)

class Array extends Object
    new: (val) => @this = val
    fromLua: (isolate, val) =>
        arr = Array(MaybeLocal(v8_dll\get("?New@Array@v8@@SA?AV?$Local@VArray@v8@@@2@PAVIsolate@2@H@Z","void*(__cdecl*)(void*,void*,int)")(intbuf, isolate, #val))\toLocalChecked!!\getInternal!)
        for i=1, #val do
            arr\set(i-1,Value\fromLua(val[i])\getInternal!)
        arr
    get: (key) =>
        MaybeLocal(v8_dll\get("?Get@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@I@Z", "void*(__thiscall*)(void*,void*,unsigned int)")(@this, intbuf, key))-- this is NOT the same as the one above
    set: (key, value) =>
        v8_dll\get("?Set@Object@v8@@QAE_NIV?$Local@VValue@v8@@@2@@Z", "bool(__thiscall*)(void*,unsigned int,void*)")(@this, key, value)
    length: => v8_dll\get("?Length@Array@v8@@QBEIXZ", "uint32_t(__thiscall*)(void*)")(@this)

class Function extends Object
    new: (val, parent) =>
        @this = val
        @parent=parent
    setParent: (val) =>
        @parent=val
        @
    __call: (...) =>
        if @parent==nil then
            @callAsFunction(Context(Isolate(nativeGetIsolate!)\getCurrentContext!)\global!\toLocalChecked!!\getInternal!, v8js_args(...))
        else
            @callAsFunction(@parent\get!\toLocalChecked!!\getInternal!, v8js_args(...))

class ObjectTemplate
    new: =>
        @this = MaybeLocal(v8_dll\get("?New@ObjectTemplate@v8@@SA?AV?$Local@VObjectTemplate@v8@@@2@XZ", "void*(__cdecl*)(void*)")(intbuf))\toLocalChecked!

class FunctionTemplate
    new: (callback) =>
        @this = MaybeLocal(v8_dll\get("?New@FunctionTemplate@v8@@SA?AV?$Local@VFunctionTemplate@v8@@@2@PAVIsolate@2@P6AXABV?$FunctionCallbackInfo@VValue@v8@@@2@@ZV?$Local@VValue@v8@@@2@V?$Local@VSignature@v8@@@2@HW4ConstructorBehavior@2@@Z", "void*(__cdecl*)(void*,void*,void*,void*,void*,int,int)")(intbuf,nativeGetIsolate!,callback,new("int[1]"),new("int[1]"),0,0))\toLocalChecked!


class Primitive extends Value
    new: (val) => @this = val
    getValue: => @this
    toString: => @this\getValue!\stringValue!

class Null extends Primitive
    new: (isolate) => @this = Value(cast("uintptr_t", isolate) + 0x48)

class Boolean extends Primitive
    new: (isolate, bool) => @this = Value(cast("uintptr_t", isolate) + (if bool then 0x4C else 0x50))

class Number extends Value
    new: (isolate, val) =>
        @this = MaybeLocal(v8_dll\get("?New@Number@v8@@SA?AV?$Local@VNumber@v8@@@2@PAVIsolate@2@N@Z", "void*(__cdecl*)(void*,void*,double)")(intbuf, isolate, tonumber(val)))\toLocalChecked!
    getLocal: => @this
    getValue: => @getInstance!\numberValue!
    getInstance: => @this!

class Integer extends Number
    new: (isolate, val) =>
        @this = MaybeLocal(v8_dll\get("?NewFromUnsigned@Integer@v8@@SA?AV?$Local@VInteger@v8@@@2@PAVIsolate@2@I@Z", "void*(__cdecl*)(void*,void*,uint32_t)")(intbuf, isolate, tonumber(val)))\toLocalChecked!

class String extends Value
    new: (isolate, val) =>
        @this = MaybeLocal(v8_dll\get("?NewFromUtf8@String@v8@@SA?AV?$MaybeLocal@VString@v8@@@2@PAVIsolate@2@PBDW4NewStringType@2@H@Z", "void*(__cdecl*)(void*,void*,const char*,int,int)")(intbuf, isolate, val, 0, #val))\toLocalChecked!
    getLocal: => @this
    getValue: => @getInstance!\stringValue!
    getInstance: => @this!

class Isolate
    new: (val = nativeGetIsolate!) => @this = val
    enter: => v8_dll\get("?Enter@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    exit: => v8_dll\get("?Exit@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    getCurrentContext: => MaybeLocal(v8_dll\get("?GetCurrentContext@Isolate@v8@@QAE?AV?$Local@VContext@v8@@@2@XZ", "void**(__thiscall*)(void*,void*)")(@this, intbuf))\toLocalChecked!!\getInternal!
    getInternal: => @this

class Context
    new: (val) => @this = val
    enter: => v8_dll\get("?Enter@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    exit: => v8_dll\get("?Exit@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    global: =>
        MaybeLocal(v8_dll\get("?Global@Context@v8@@QAE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, intbuf))

class HandleScope
    new: => @this = new("char[0xC]")
    enter: => v8_dll\get("??0HandleScope@v8@@QAE@PAVIsolate@1@@Z", "void(__thiscall*)(void*,void*)")(@this, nativeGetIsolate!)
    exit: => v8_dll\get("??1HandleScope@v8@@QAE@XZ", "void(__thiscall*)(void*)")(@this)
    createHandle: (val) => v8_dll\get("?CreateHandle@HandleScope@v8@@KAPAPAVObject@internal@2@PAVIsolate@42@PAV342@@Z", "void**(__cdecl*)(void*,void*)")(nativeGetIsolate!, val)
    __call: (func, panel = panorama.GetPanel("CSGOJsRegistration")) =>
        isolate = Isolate!
        isolate\enter!
        @enter!
        ctx = if panel then nativeGetPanelContext(getJavaScriptContextParent(panel))[0] else Context(isolate\getCurrentContext!)\global!\getInternal!
        ctx = Context(if ctx ~= nullptr then @createHandle(ctx[0]) else 0)
        ctx\enter!
        val = func!
        ctx\exit!
        @exit!
        isolate\exit!
        val

class TryCatch
    new: => @this = new("char[0x19]")
    enter: => v8_dll\get("??0TryCatch@v8@@QAE@PAVIsolate@1@@Z", "void(__thiscall*)(void*,void*)")(@this, nativeGetIsolate!)
    exit: => v8_dll\get("??1TryCatch@v8@@QAE@XZ", "void(__thiscall*)(void*)")(@this)
    canContinue: => v8_dll\get("?CanContinue@TryCatch@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    hasTerminated: => v8_dll\get("?HasTerminated@TryCatch@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)
    hasCaught: => v8_dll\get("?HasCaught@TryCatch@v8@@QBE_NXZ", "bool(__thiscall*)(void*)")(@this)

class Script
    compile: (panel, source, layout = "") =>
        __thiscall(cast("void**(__thiscall*)(void*,void*,const char*,const char*)", utils.find_pattern("panorama.dll", "55 8B EC 83 E4 F8 83 EC 64 53 8B D9")), UIEngine\getInstance!)(panel, source, layout)
    loadstring: (str, panel) =>
        isolate = Isolate(nativeGetIsolate!)
        handleScope = HandleScope!
        tryCatch = TryCatch()
        isolate\enter!
        handleScope\enter!
        ctx = if panel then nativeGetPanelContext(getJavaScriptContextParent(panel))[0] else Context(isolate\getCurrentContext!)\global!\getInternal!
        ctx = Context(if ctx ~= nullptr then handleScope\createHandle(ctx[0]) else 0)
        ctx\enter!
        tryCatch\enter!
        compiled = MaybeLocal(@compile(panel, str))\toLocalChecked!
        tryCatch\exit!
        ret = MaybeLocal(nativeRunScript(intbuf, panel, compiled!\getInternal!, 0, false))\toLocalChecked!!\toLua! unless compiled==nil -- we do not have to trycatch this one because it already does it itself!
        ctx\exit!
        handleScope\exit!
        isolate\exit!
        ret

PanelInfo_t = typeof([[
    struct {
        char* pad1[0x4];
        void*         m_pPanel;
        void* unk1;
    }
]])

CUtlVector_Constructor_t = typeof([[
    struct {
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
    __index: {
        Count: => @m_Memory.m_nAllocationCount,
        Element: (i) => cast(typeof("$&", PanelInfo_t), @m_Memory.m_pMemory[i])
        RemoveAll: =>
            @ = nil
            @ = typeof("$[?]", CUtlVector_Constructor_t)(1)[0]
            @m_Size = 0
            return
    },
    __ipairs: =>
        current, size = 0, @\Count!
        ->
            current = current + 1
            pPanel = @\Element(current - 1).m_pPanel
            if current <= size and nativeIsValidPanelPointer(pPanel) then
                current, pPanel
})

panelList = typeof("$[?]", CUtlVector_Constructor_t)(1)[0]
panelArrayOffset = cast("unsigned int*", cast("uintptr_t**", UIEngine\getInstance!)[0][36] + 21)[0]
panelArray = cast(panelList, cast("uintptr_t", UIEngine\getInstance!) + panelArrayOffset)

panorama.GetPanel = (panelName) ->
    cachedPanel = panorama.panelIDs[panelName]
    if cachedPanel ~= nil and nativeIsValidPanelPointer(cachedPanel) then
        return cachedPanel
    panorama.panelIDs = {}

    pPanel = nullptr
    for i, v in ipairs(panelArray) do
        curPanelName = ffi.string(nativeGetID(v))
        if curPanelName ~= "" then
            panorama.panelIDs[curPanelName] = v
            if curPanelName == panelName then
                pPanel = v
                break
    if pPanel == nullptr then
        safe_error("Failed to get target panel " .. tostring(panelName))
    pPanel

panorama.RunScript = (jsCode, panel=panorama.GetPanel("CSGOJsRegistration"), pathToXMLContext="panorama/layout/base.xml") ->
    if not nativeIsValidPanelPointer(panel) then safe_error("Invalid panel")
    nativeCompileRunScript(panel,jsCode,pathToXMLContext,8,10,false)

panorama.loadstring = (jsCode, panel="CSGOJsRegistration") ->
    () -> Script\loadstring(string.format("(function(){%s})()", jsCode), panorama.GetPanel(panel))

panorama.open = (panel="CSGOJsRegistration") ->
    HandleScope!(() -> Context(Isolate()\getCurrentContext!)\global!\toLocalChecked!!\toLua!, panorama.GetPanel(panel))

panorama