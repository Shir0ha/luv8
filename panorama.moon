local *

import cast, typeof, new from ffi
import jmp, proc_bind from require 'hooks'

--#pragma region helper_functions
safe_error = (msg) ->
    error(msg) -- Will automatically call shutdown function to make sure nothing goes wrong. to be implemented.
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
--#pragma endregion helper_functions
nullptr = new("void*")
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
nativeRunScript = UIEngine\get(113, "int(__thiscall*)(void*,void*,char const*,char const*,int,int,bool)")
nativeGetV8GlobalContext = UIEngine\get(123, "void*(__thiscall*)(void*)")
nativeGetIsolate = UIEngine\get(129, "void*(__thiscall*)(void*)")
nativeGetParent = vtable_thunk(25, "void*(__thiscall*)(void*)")
nativeGetID = vtable_thunk(9, "const char*(__thiscall*)(void*)")
nativeFindChildTraverse = vtable_thunk(40, "void*(__thiscall*)(void*,const char*)")
nativeGetJavaScriptContextParent = vtable_thunk(218, "void*(__thiscall*)(void*)")
nativeGetPanelContext = __thiscall(cast("void***(__thiscall*)(void*,void*)", follow_call(utils.find_pattern("panorama.dll", "E8 ? ? ? ? 8B 00 85 C0 75 1B"))), UIEngine\getInstance!)
--#pragma endregion native_panorama_functions

--#pragma region native_v8_functions
v8_dll = DllImport("v8.dll")

class Local
    new: (val) => @this = val
    getInstance: => @this
    __call: => Value(@this[0])

class MaybeLocal
    new: (val) => @this = cast("void**", val)
    getInstance: => @this
    toLocalChecked: => Local(@this) unless @this == nullptr

class Value
    new: (val) => @this = cast("void*", val)
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
        Object(MaybeLocal(v8_dll\get("?ToObject@Value@v8@@QBE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, new("int[1]")))\toLocalChecked!!)
    toLocal: =>
        Local(new("uintptr_t[1]", @this))

class Object extends Value
    new: (val) => @this = val
    get: (key) =>
        MaybeLocal(v8_dll\get("?Get@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@@Z", "void*(__thiscall*)(void*,void*,void*)")(@this, new("int[1]"), key))
    set: (key, value) => v8_dll\get("?Set@Object@v8@@QAE_NV?$Local@VValue@v8@@@2@0@Z", "bool(__thiscall*)(void*,void*,void*)")(@this, key, value)
    getPropertyNames: =>
        MaybeLocal(v8_dll\get("?GetPropertyNames@Object@v8@@QAE?AV?$Local@VArray@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, new("int[1]")))
    callAsFunction: (args, recv, argc, argv) =>
        MaybeLocal(v8_dll\get("?CallAsFunction@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@HQAV32@@Z", "void*(__thiscall*)(void*,void*,void*,int,void*)")(@this, new("int[1]"), argc, argv))
    getIdentityHash: => v8_dll\get("?GetIdentityHash@Object@v8@@QAEHXZ", "int(__thiscall*)(void*)")(@this)

class Array extends Object
    new: (val) => @this = val
    length: => v8_dll\get("?Length@Array@v8@@QBEIXZ", "uint32_t(__thiscall*)(void*)")(@this)

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
        @this = MaybeLocal(v8_dll\get("?New@Number@v8@@SA?AV?$Local@VNumber@v8@@@2@PAVIsolate@2@N@Z", "void*(__cdecl*)(void*,void*,double)")(new("int[1]"), isolate, tonumber(val)))\toLocalChecked!!
    getValue: => @this\numberValue!
    getInstance: => @this

class String extends Value
    new: (isolate, val) => @this = MaybeLocal(v8_dll\get("?NewFromUtf8@String@v8@@SA?AV?$MaybeLocal@VString@v8@@@2@PAVIsolate@2@PBDW4NewStringType@2@H@Z", "void*(__cdecl*)(void*,void*,const char*,int,int)")(new("int[1]"), isolate, val, 0, #val))\toLocalChecked!!
    getValue: => @this\stringValue!
    getInstance: => @this

class Isolate
    new: (val) => @this = val
    enter: => v8_dll\get("?Enter@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    exit: => v8_dll\get("?Exit@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    getCurrentContext: => v8_dll\get("?GetCurrentContext@Isolate@v8@@QAE?AV?$Local@VContext@v8@@@2@XZ", "void**(__thiscall*)(void*,void*)")(nativeGetIsolate!, new("int[1]"))
    getInstance: => @this

class Context
    new: (val) => @this = val
    enter: => v8_dll\get("?Enter@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    exit: => v8_dll\get("?Exit@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    global: =>
        MaybeLocal(v8_dll\get("?Global@Context@v8@@QAE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, new("int[1]")))

class HandleScope
    new: => @this = new("char[0xC]")
    enter: => v8_dll\get("??0HandleScope@v8@@QAE@PAVIsolate@1@@Z", "void(__thiscall*)(void*,void*)")(@this, nativeGetIsolate!)
    exit: => v8_dll\get("??1HandleScope@v8@@QAE@XZ", "void(__thiscall*)(void*)")(@this)
    createHandle: (val) => v8_dll\get("?CreateHandle@HandleScope@v8@@KAPAPAVObject@internal@2@PAVIsolate@42@PAV342@@Z", "void*(__cdecl*)(void*,void*)")(nativeGetIsolate!, val)
    __call: (func, panel) =>
        isolate = Isolate(nativeGetIsolate!)
        isolate\enter!
        @enter!
        ctx = if panel then nativeGetPanelContext(nativeGetJavaScriptContextParent(panel))[0] else Context(Isolate()\getCurrentContext!\toLocalChecked!!)\global!\getInstance!
        ctx = Context(if ctx ~= nullptr then @createHandle(ctx[0]) else 0)
        ctx\enter!
        val = func!
        ctx\exit!
        @exit!
        isolate\exit!
        val

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
    if cachedPanel ~= nil and nativeIsValidPanelPointer(cachedPanel) and ffi.string(nativeGetID(cachedPanel)) == panelName then
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

panorama.RunScript= (jsCode, panel=panorama.GetPanel("CSGOJsRegistration"), pathToXMLContext="panorama/layout/base.xml") ->
    if not nativeIsValidPanelPointer(panel) then safe_error("Invalid panel")
    nativeRunScript(panel,jsCode,pathToXMLContext,8,10,false)

test = HandleScope()
testFunc = ->
    isolate = nativeGetIsolate!
    print(String(isolate, "hello world")\getValue!)
test(testFunc, panorama.GetPanel("CSGOJsRegistration"))

panorama.RunScript([[
    $.Msg("hello again");
]])

return 0