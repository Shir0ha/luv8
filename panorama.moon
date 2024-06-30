-- Devs
-------------------------------------------------------
--                                                   --
-- Yukino                                            --
-- agapornis: 46 55 43 4B 20 50 61 6E 6F 72 61 6D 61 --
--                                                   --
-------------------------------------------------------
ffi = ffi or require('ffi')
local *

_INFO = {_VERSION: 1.7}

setmetatable(_INFO,{
    __call: => self._VERSION,
    __tostring: => self._VERSION
})

import cast, typeof, new, string, metatype from ffi

--#pragma region compatibility_layer
find_pattern = () -> error('Unsupported provider')
create_interface = () -> error('Unsupported provider')
add_shutdown_callback = () -> print('WARNING: Cleanup before shutdown disabled')

local api
while true
    if _G == nil
        if quick_maths == nil
            if info.fatality == nil
                api = 'ev0lve'
                break
            api = 'fa7ality'
            break
        api = 'rifk7'
        break
    if gui ~= nil then
        api = 'aimware'
        break
    if MatSystem ~= nil then
        api = 'spirthack'
        break
    if file ~= nil then
        api = 'legendware'
        break
    if GameEventManager ~= nil then
        api = 'memesense'
        break
    if penetration ~= nil then
        api = 'pandora'
        break
    if math_utils ~= nil then
        api = 'legion'
        break
    if plist ~= nil then
        api = 'gamesense'
        break
    if network ~= nil then
        api = 'neverlose'
        break
    if renderer ~= nil and renderer.setup_texture ~= nil then
        api = 'nixware'
        break
    api = 'primordial'
    break

switch api
    when 'ev0lve'
        find_pattern = utils.find_pattern
        create_interface = utils.find_interface
        add_shutdown_callback = () -> -- not needed
    when 'fa7ality'
        find_pattern = utils.find_pattern
        create_interface = utils.find_interface
        add_shutdown_callback = () -> -- not needed
    when 'primordial'
        find_pattern = memory.find_pattern
        create_interface = memory.create_interface
        add_shutdown_callback = (fn) -> callbacks.add(e_callbacks.SHUTDOWN, fn)
    when 'memesense'
        find_pattern = Utils.PatternScan
        create_interface = Utils.CreateInterface
        add_shutdown_callback = (fn) -> Cheat.RegisterCallback('destroy', fn)
    when 'legendware'
        find_pattern = utils.find_signature
        create_interface = utils.create_interface
        add_shutdown_callback = (fn) -> client.add_callback('unload', fn)
    when 'pandora'
        find_pattern = client.find_sig
        create_interface = client.create_interface
    when 'legion'
        find_pattern = memory.find_pattern
        create_interface = memory.create_interface
        add_shutdown_callback = (fn) -> client.add_callback('on_unload', fn)
    when 'gamesense'
        find_pattern = (moduleName, pattern) ->
            gsPattern = ''
            for token in pattern\gmatch('%S+') do
                gsPattern = gsPattern .. (token == '?' and '\xCC' or _G.string.char(tonumber(token, 16)))
            return client.find_signature(moduleName, gsPattern)
        create_interface = client.create_interface
        add_shutdown_callback = (fn) -> client.set_event_callback('shutdown', fn)
    when 'nixware'
        find_pattern = client.find_pattern
        create_interface = se.create_interface
        add_shutdown_callback = (fn) -> client.register_callback("unload", fn)
    when 'neverlose'
        find_pattern = utils.opcode_scan
        create_interface = utils.create_interface
        add_shutdown_callback = () -> -- not needed
    when 'rifk7'
        find_pattern = (module_name, pattern) ->
            stupid = cast("uintptr_t*",engine.signature(module_name, pattern))
            assert(tonumber(stupid) ~= 0)
            stupid[0]
        create_interface = (module_name, interface_name) ->
            interface_name = _G.string.gsub(interface_name, "%d+", "")
            general.create_interface(module_name, interface_name)
        export print = (text) ->  -- :troll:
            general.log_to_console_colored("[lua] "..tostring(text),255,141,161,255)
            --general.log(text)
    when 'spirthack'
        find_pattern = Utils.PatternScan
        create_interface = Utils.CreateInterface
    when 'aimware'
        find_pattern = (module_name, pattern) ->
            pat = _G.string.gsub(pattern, '?', '??')
            mem.FindPattern(module_name, pat)
        create_interface = (module_name, interface_name) ->
            fnptr = find_pattern(module_name, '4C 8B 0D ? ? ? ? 4C 8B D2 4C 8B D9')
            if not fnptr then return nil
            res = cast('void*(__cdecl*)(const char*, int*)', fnptr)(interface_name, nil)
            res ~= nil and res or nil

safe_mode = (xpcall and pcall) and true or false

ffiCEnabled = ffi.C and api ~= 'gamesense'
print(('\nluv8 panorama library %s;\nhttps://github.com/Shir0ha/luv8\napi: %s; safe_mode: %s; ffi.C: %s')\format(_INFO._VERSION, api, tostring(safe_mode), tostring(ffiCEnabled)))
--#pragma endregion compatibility_layer

--#pragma region helper_functions
export shutdown = () ->
    for _,v in pairs(persistentTbl) do
        Persistent(v)\disposeGlobal!
_error = error
if error then
    export error = (msg) ->
        shutdown!
        _error(msg)
exception = (msg) ->
    print('Caught lua exception in V8 HandleScope: ', tostring(msg))
exceptionCb = (msg) ->
    print('Caught lua exception in V8 Function Callback: ', tostring(msg))
rawgetImpl = (tbl, key) ->
    mtb = getmetatable(tbl)
    setmetatable(tbl, nil)
    res = tbl[key]
    setmetatable(tbl, mtb)
    res
rawsetImpl = (tbl, key, value) ->
    mtb = getmetatable(tbl)
    setmetatable(tbl, nil)
    tbl[key] = value
    setmetatable(tbl, mtb)
if not rawget then export rawget = rawgetImpl -- in case some cheat doesn't have rawset/rawget enabled (like rifk7)
if not rawset then export rawset = rawsetImpl
__thiscall = (func, this) -> (...) -> func(this, ...)
table_copy = (t) -> {k, v for k, v in pairs t}
vtable_bind = (module, interface, index, typedef) ->
    addr = cast('void***', create_interface(module, interface)) or error(interface .. ' is nil.')
    __thiscall(cast(typedef, addr[0][index]), addr)
interface_ptr = typeof('void***')
vtable_entry = (instance, i, ct) -> cast(ct, cast(interface_ptr, instance)[0][i])
vtable_thunk = (i, ct) ->
    t = typeof(ct)
    (instance, ...) -> vtable_entry(instance, i, t)(instance, ...)
proc_bind = (() ->
    fnGetProcAddress = () -> error('Failed to load GetProcAddress')
    fnGetModuleHandle = () -> error('Failed to load GetModuleHandleA')
    if ffiCEnabled -- I did this mainly because memesense pattern scan is fucked up
        ffi.cdef[[
            uintptr_t GetProcAddress(uintptr_t, const char*);
            uintptr_t GetModuleHandleA(const char*);
        ]]
        fnGetProcAddress = ffi.C.GetProcAddress
        fnGetModuleHandle = ffi.C.GetModuleHandleA
    else
        fnGetProcAddress = cast('uintptr_t(__stdcall*)(uintptr_t, const char*)', cast('uintptr_t**', cast('uintptr_t', find_pattern('engine.dll', 'FF 15 ? ? ? ? A3 ? ? ? ? EB 05')) + 2)[0][0])
        fnGetModuleHandle = cast('uintptr_t(__stdcall*)(const char*)', cast('uintptr_t**', cast('uintptr_t', find_pattern('engine.dll', 'FF 15 ? ? ? ? 85 C0 74 0B')) + 2)[0][0])
    -- Gamesense really doesn't like when you call code in windows DLL's
    if api == 'gamesense'
        -- we need to use a gadget inside games code to call our function
        proxyAddr = find_pattern('engine.dll', '51 C3') -- PUSH ECX; RET
        fnGetProcAddressAddr = cast('void*', fnGetProcAddress)
        fnGetProcAddress = (moduleHandle, functionName) ->
            fnGetProcAddressProxy = cast('uintptr_t(__thiscall*)(void*, uintptr_t, const char*)', proxyAddr)
            return fnGetProcAddressProxy(fnGetProcAddressAddr, moduleHandle, functionName)
        fnGetModuleHandleAddr = cast('void*', fnGetModuleHandle)
        fnGetModuleHandle = (moduleName) ->
            fnGetModuleHandleProxy = cast('uintptr_t(__thiscall*)(void*, const char*)', proxyAddr)
            return fnGetModuleHandleProxy(fnGetModuleHandleAddr, moduleName)
    (module_name, function_name, typedef) ->
        cast(typeof(typedef), fnGetProcAddress(fnGetModuleHandle(module_name), function_name))
    )!
follow_call = (ptr) ->
    insn = cast('uint8_t*', ptr)
    switch insn[0]
        when 0xE8 or 0xE9
            cast('uintptr_t', insn + cast('int32_t*', insn + 1)[0] + 5)
        when 0xFF
            if insn[1] == 0x15
                cast('uintptr_t**', cast('const char*', ptr) + 2)[0][0]
        else
            ptr
v8js_args = (...) ->
    argTbl = {...}
    iArgc = #argTbl
    pArgv = new('void*[%.f]'\format(iArgc))
    for i = 1, iArgc do
        pArgv[i - 1] = Value\fromLua(argTbl[i])\getInternal!
    iArgc,pArgv
v8js_function = (callbackFunction) ->
    (callbackInfo) ->
        callbackInfo = FunctionCallbackInfo(callbackInfo)
        argTbl = {}
        length = callbackInfo\length!
        if length > 0 then
            for i = 0, length-1 do
                table.insert(argTbl,callbackInfo\get(i))
        val = nil
        if safe_mode then
            status, ret = xpcall((() -> callbackFunction(unpack(argTbl))),exceptionCb)
            if status then val = ret
        else
            val = callbackFunction(unpack(argTbl))
        callbackInfo\setReturnValue(Value\fromLua(val)\getInternal!)

is_array = (val) ->
    i=1
    for _ in pairs(val) do
        if val[i] ~= nil then
            i=i+1
        else
            return false
    return i~=1

--#pragma endregion helper_functions
nullptr = new('void*')
intbuf = new('int[1]')

panorama = {
    panelIDs: {}
}

class vtable
    new: (ptr) => @this = cast('void***', ptr)
    get: (index, t) => __thiscall(cast(t, @this[0][index]), @this)
    getInstance: => @this

class DllImport
    cache: {}
    new: (filename) => @file = filename
    get: (method, typedef) =>
        @cache[method] = proc_bind(@file, method, typedef) unless @cache[method]
        @cache[method]

--#pragma region native_panorama_functions
UIEngine = vtable(vtable_bind('panorama.dll', 'PanoramaUIEngine001', 13, 'void*(__thiscall*)(void*)')!) -- :troll:
nativeIsValidPanelPointer = UIEngine\get(32, 'bool(__thiscall*)(void*,void const*)')
nativeCompileRunScript = UIEngine\get(81, 'void****(__thiscall*)(void*,void*,char const*,char const*,int)')
nativeGetIsolate = UIEngine\get(96, 'void*(__thiscall*)(void*)')
nativeHandleException = UIEngine\get(90, 'void(__thiscall*)(void*, void*, void*)')
nativeGetID = vtable_thunk(11, 'const char*(__thiscall*)(void*)')
nativeGetPanelContext = UIEngine\get(89, 'void***(__thiscall*)(void*,void*)')
jsContexts = {}
--#pragma endregion native_panorama_functions

--#pragma region native_v8_functions
v8_dll = DllImport('v8.dll')

pIsolate = nativeGetIsolate!

persistentTbl = {}

class Message
    new: (val) => @this = cast('void*', val)

class Local
    new: (val) => @this = cast('void**', val)
    getInternal: => @this
    isValid: => @this[0] ~= nullptr
    getMessage: => Message(@this[0])
    globalize: =>
        pPersistent = v8_dll\get('?GlobalizeReference@api_internal@v8@@YAPEA_KPEAVIsolate@internal@2@PEA_K@Z', 'void*(__fastcall*)(void*,void*,void*)')(pIsolate, @this[0], intbuf)
        persistent = Persistent(pPersistent)
        persistentTbl[persistent\getIdentityHash!] = pPersistent
        persistent
    __call: => Value(@this[0])

class MaybeLocal
    new: (val) => @this = cast('void**', val)
    getInternal: => @this
    toLocalChecked: => Local(@this) unless @this[0] == nullptr
    toValueChecked: => Value(@this[0]) unless @this[0] == nullptr

PersistentProxy_mt = {
    __index: (key) =>
        this = rawget(@,'this')
        ret = HandleScope!(() -> this\getAsValue!\toObject!\get(Value\fromLua(key)\getInternal!)\toValueChecked!\toLua!)
        if type(ret) == 'table' then
            rawset(ret,'parent',this)
        ret
    __newindex: (key, value) =>
        this = rawget(@,'this')
        HandleScope!(() -> this\getAsValue!\toObject!\set(Value\fromLua(key)\getInternal!,Value\fromLua(value)\getInternal!)\toValueChecked!\toLua!)
    __len: =>
        this = rawget(@,'this')
        ret = 0
        if this.baseType == 'Array' then
            ret = HandleScope!(() -> this\getAsValue!\toArray!\length!)
        elseif this.baseType == 'Object' then
            ret = HandleScope!(() -> this\getAsValue!\toObject!\getPropertyNames!\toValueChecked!\toArray!\length!)
        ret
    __pairs: =>
        this = rawget(@,'this')
        ret = () -> nil
        if this.baseType == 'Object' then
            HandleScope!(() ->
                keys = Array(this\getAsValue!\toObject!\getPropertyNames!\toValueChecked!)
                current, size = 0, keys\length!
                ret = () ->
                    current = current+1
                    key = keys[current-1]
                    if current <= size then
                        return key, @[key]
            )
        ret
    __ipairs: =>
        this = rawget(@,'this')
        ret = () -> nil
        if this.baseType == 'Array' then
            HandleScope!(() ->
                current, size = 0, this\getAsValue!\toArray!\length!
                ret = () ->
                    current = current+1
                    if current <= size then
                        return current, @[current-1]
            )
        ret
    __call: (...) =>
        this = rawget(@,'this')
        args = { ... }
        if this.baseType ~= 'Function' then error('Attempted to call a non-function value: ' .. this.baseType)
        terminateExecution = false
        ret = HandleScope!(() ->
            tryCatch = TryCatch!
            tryCatch\enter!
            rawReturn = this\getAsValue!\toFunction!\setParent(rawget(@,'parent'))(unpack(args))\toLocalChecked!
            if tryCatch\hasCaught! then --lol exception handling
                nativeHandleException(tryCatch\getInternal!, panorama.getPanel("CSGOJsRegistration")) -- we don't keep track of panels..... so just throw everything in CSGOJsRegistration
                if safe_mode then
                    terminateExecution = true
            tryCatch\exit!
            if rawReturn == nil then
                nil
            else
                rawReturn!\toLua!
        )
        if terminateExecution then
            error("\n\nFailed to call the given javascript function, please check the error message above ^ \n\n(definitely not because I was too lazy to implement my own exception handler)\n")
        ret

    __tostring: =>
        this = rawget(@,'this')
        HandleScope!(() -> this\getAsValue!\stringValue!)
    __gc: =>
        this = rawget(@,'this')
        this\disposeGlobal!
}

class Persistent
    new: (val, baseType='Value') =>
        @this = val
        @baseType=baseType
    setType: (val) =>
        @baseType=val
        @
    getInternal: => @this
    disposeGlobal: =>
        v8_dll\get('?DisposeGlobal@api_internal@v8@@YAXPEA_K@Z','void(__thiscall*)(void*)')(@this)
    get: => MaybeLocal(HandleScope\createHandle(@this))
    getAsValue: => Value(HandleScope\createHandle(@this)[0]) -- unsafe but efficient, we're assuming that every maybelocal is a local
    toLua: => -- should NOT be used if the persistent is an object!!!! cuz it will just return the same thing again
        @get!\toValueChecked!\toLua!
    getIdentityHash: => v8_dll\get('?GetIdentityHash@Object@v8@@QEAAHXZ', 'int(__thiscall*)(void*)')(@this)
    __call: =>
        setmetatable({this: self, parent: nil}, PersistentProxy_mt)

class Value
    new: (val) => @this = cast('void*', val)
    fromLua: (val) =>
        if val==nil then return Null(pIsolate)\getValue!
        valType = type(val)
        switch valType
            when 'boolean'
                return Boolean(pIsolate,val)\getValue!
            when 'number'
                return Number(pIsolate,val)\getInstance!
            when 'string'
                return String(pIsolate,val)\getInstance!
            when 'table'
                if is_array(val) then
                    return Array\fromLua(pIsolate,val)
                else
                    return Object\fromLua(pIsolate,val)
            when 'function'
                return FunctionTemplate(v8js_function(val))\getFunction!!
            else
                error('Failed to convert from lua to v8js: Unknown type')
    isUndefined: => v8_dll\get('?IsUndefined@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isNull: => v8_dll\get('?IsNull@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isBoolean: => v8_dll\get('?IsBoolean@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isBooleanObject: => v8_dll\get('?IsBooleanObject@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isNumber: => v8_dll\get('?IsNumber@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isNumberObject: => v8_dll\get('?IsNumberObject@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isString: => v8_dll\get('?IsString@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isStringObject: => v8_dll\get('?IsStringObject@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isObject: => v8_dll\get('?IsObject@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isArray: => v8_dll\get('?IsArray@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    isFunction: => v8_dll\get('?IsFunction@Value@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    booleanValue: => v8_dll\get('?Value@Boolean@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    numberValue: => v8_dll\get('?Value@Number@v8@@QEBANXZ', 'double(__thiscall*)(void*)')(@this)
    stringValue: =>
        strBuf = new('char*[2]')
        val = v8_dll\get('??0Utf8Value@String@v8@@QEAA@PEAVIsolate@2@V?$Local@VValue@v8@@@2@@Z', 'struct{char* str; int length;}*(__fastcall*)(void*,void*,void*)')(strBuf, pIsolate, @this)
        s = string(val.str, val.length)
        v8_dll\get('??1Utf8Value@String@v8@@QEAA@XZ', 'void(__thiscall*)(void*)')(strBuf)
        s
    toObject: =>
        Object(MaybeLocal(v8_dll\get('?ToObject@Value@v8@@QEBA?AV?$MaybeLocal@VObject@v8@@@2@V?$Local@VContext@v8@@@2@@Z', 'void*(__fastcall*)(void*,void*)')(@this, intbuf))\toValueChecked!\getInternal!)
    toArray: =>
        Array(MaybeLocal(v8_dll\get('?ToObject@Value@v8@@QEBA?AV?$MaybeLocal@VObject@v8@@@2@V?$Local@VContext@v8@@@2@@Z', 'void*(__fastcall*)(void*,void*)')(@this, intbuf))\toValueChecked!\getInternal!)
    toFunction: =>
        Function(MaybeLocal(v8_dll\get('?ToObject@Value@v8@@QEBA?AV?$MaybeLocal@VObject@v8@@@2@V?$Local@VContext@v8@@@2@@Z', 'void*(__fastcall*)(void*,void*)')(@this, intbuf))\toValueChecked!\getInternal!)
    toLocal: =>
        Local(new('void*[1]',@this))
    toLua: =>
        if @isUndefined! or @isNull! then return nil
        if @isBoolean! or @isBooleanObject! then return @booleanValue!
        if @isNumber! or @isNumberObject! then return @numberValue!
        if @isString! or @isStringObject! then return @stringValue!
        if @isObject! then -- returns persistent proxy
            if @isArray! then return @toArray!\toLocal!\globalize!\setType('Array')!
            if @isFunction! then return @toFunction!\toLocal!\globalize!\setType('Function')!
            return @toObject!\toLocal!\globalize!\setType('Object')!
        error('Failed to convert from v8js to lua: Unknown type')
    getInternal: => @this

class Object extends Value
    new: (val) => @this = val
    fromLua: (isolate, val) =>
        obj = Object(MaybeLocal(v8_dll\get('?New@Object@v8@@SA?AV?$Local@VObject@v8@@@2@PEAVIsolate@2@@Z','void*(__fastcall*)(void*,void*)')(intbuf, isolate))\toValueChecked!\getInternal!)
        for i,v in pairs(val) do
            obj\set(Value\fromLua(i)\getInternal!,Value\fromLua(v)\getInternal!)
        obj
    get: (key) =>
        MaybeLocal(v8_dll\get('?Get@Object@v8@@QEAA?AV?$MaybeLocal@VValue@v8@@@2@V?$Local@VContext@v8@@@2@V?$Local@VValue@v8@@@2@@Z', 'void*(__fastcall*)(void*,void*,void*,void*)')(@this, intbuf, nil, key))
    set: (key, value) => v8_dll\get('?Set@Object@v8@@QEAA?AV?$Maybe@_N@2@V?$Local@VContext@v8@@@2@V?$Local@VValue@v8@@@2@1@Z', 'bool(__fastcall*)(void*,void*,void*,void*,void*)')(@this, intbuf, nil, key, value)
    getPropertyNames: =>
        MaybeLocal(v8_dll\get('?GetPropertyNames@Object@v8@@QEAA?AV?$MaybeLocal@VArray@v8@@@2@V?$Local@VContext@v8@@@2@@Z', 'void*(__fastcall*)(void*,void*,void*)')(@this, intbuf, nil))
    callAsFunction: (recv, argc, argv) =>
        MaybeLocal(v8_dll\get('?CallAsFunction@Object@v8@@QEAA?AV?$MaybeLocal@VValue@v8@@@2@V?$Local@VContext@v8@@@2@V?$Local@VValue@v8@@@2@HQEAV52@@Z', 'void*(__fastcall*)(void*,void*,void*,void*,int,void*)')(@this, intbuf, Isolate!\getCurrentContext!, recv, argc, argv))
    getIdentityHash: => v8_dll\get('?GetIdentityHash@Object@v8@@QEAAHXZ', 'int(__thiscall*)(void*)')(@this)

class Array extends Object
    new: (val) => @this = val
    fromLua: (isolate, val) =>
        arr = Array(MaybeLocal(v8_dll\get('?New@Array@v8@@SA?AV?$Local@VArray@v8@@@2@PEAVIsolate@2@PEAV?$Local@VValue@v8@@@2@_K@Z','void*(__fastcall*)(void*,void*,int)')(intbuf, isolate, #val))\toValueChecked!\getInternal!)
        for i=1, #val do
            arr\set(i-1,Value\fromLua(val[i])\getInternal!)
        arr
    get: (key) =>
        MaybeLocal(v8_dll\get('?Get@Object@v8@@QEAA?AV?$MaybeLocal@VValue@v8@@@2@V?$Local@VContext@v8@@@2@I@Z', 'void*(__fastcall*)(void*,void*,void*,unsigned int)')(@this, intbuf, nil, key))-- this is NOT the same as the one above
    set: (key, value) =>
        v8_dll\get('?Set@Object@v8@@QEAA?AV?$Maybe@_N@2@V?$Local@VContext@v8@@@2@IV?$Local@VValue@v8@@@2@@Z', 'bool(__fastcall*)(void*,void*,void*,unsigned int,void*)')(@this, intbuf, nil, key, value)
    length: => v8_dll\get('?Length@Array@v8@@QEBAIXZ', 'uintptr_t(__thiscall*)(void*)')(@this)

class Function extends Object
    new: (val, parent) =>
        @this = val
        @parent=parent
    setParent: (val) =>
        @parent=val
        @
    __call: (...) =>
        if @parent==nil then
            @callAsFunction(Context(Isolate!\getCurrentContext!)\global!\toValueChecked!\getInternal!, v8js_args(...))
        else
            @callAsFunction(@parent\getAsValue!\getInternal!, v8js_args(...))

-- class ObjectTemplate
--     new: =>
--         @this = MaybeLocal(v8_dll\get('?New@ObjectTemplate@v8@@SA?AV?$Local@VObjectTemplate@v8@@@2@XZ', 'void*(__cdecl*)(void*)')(intbuf))\toLocalChecked!

--to be honest this part is kinda messy, method names are confusing as fuck
class FunctionTemplate
    new: (callback) =>
        @this = MaybeLocal(v8_dll\get('?New@FunctionTemplate@v8@@SA?AV?$Local@VFunctionTemplate@v8@@@2@PEAVIsolate@2@P6AXAEBV?$FunctionCallbackInfo@VValue@v8@@@2@@ZV?$Local@VValue@v8@@@2@V?$Local@VSignature@v8@@@2@HW4ConstructorBehavior@2@W4SideEffectType@2@PEBVCFunction@2@GGG@Z', 'void*(__cdecl*)(void*,void*,void*,void*,void*,int,int)')(intbuf,pIsolate,cast('void(__cdecl*)(void******)',callback),new('int[1]'),new('int[1]'),0,0))\toLocalChecked!
    getFunction: () =>
        MaybeLocal(v8_dll\get('?GetFunction@FunctionTemplate@v8@@QEAA?AV?$MaybeLocal@VFunction@v8@@@2@V?$Local@VContext@v8@@@2@@Z', 'void*(__fastcall*)(void*, void*, void*)')(@this!\getInternal!, intbuf, nil))\toLocalChecked!
    getInstance: => @this!

class FunctionCallbackInfo
    kHolderIndex: 0
    kIsolateIndex: 1
    kReturnValueDefaultValueIndex: 2
    kReturnValueIndex: 3
    kDataIndex: 4
    kCalleeIndex: 5
    kContextSaveIndex: 6
    kNewTargetIndex: 7
    new: (val) => @this = cast('void****', val)
    getHolder: => MaybeLocal(@getImplicitArgs_![@kHolderIndex])\toLocalChecked! -- does not work (untested)
    getIsolate: => Isolate(@getImplicitArgs_![@kIsolateIndex][0]) -- does not work (untested)
    getReturnValueDefaultValue: => Value(new('void*[1]',@getImplicitArgs_![@kReturnValueDefaultValueIndex])) -- does not work (untested)
    getReturnValue: => Value(new('void*[1]',@getImplicitArgs_![@kReturnValueIndex])) -- does not work (untested)
    setReturnValue: (value) => @getImplicitArgs_![@kReturnValueIndex] = cast('void**',value)[0] --works
    getData: => MaybeLocal(@getImplicitArgs_![@kDataIndex])\toLocalChecked! -- does not work (untested)
    getCallee: => MaybeLocal(@getImplicitArgs_![@kCalleeIndex])\toLocalChecked! -- does not work (untested)
    getContextSave: => MaybeLocal(@getImplicitArgs_![@kContextSaveIndex])\toLocalChecked! -- does not work (untested)
    getNewTarget: => MaybeLocal(@getImplicitArgs_![@kNewTargetIndex])\toLocalChecked! -- does not work (untested)
    getImplicitArgs_: => return @this[0]
    getValues_: => return @this[1]
    getLength_: => return @this[2]
    length: => tonumber(cast('int',@getLength_!))
    get: (i) => -- so sad we can't use __index lol
        -- if ( (int)a1[2] > 0 )
        --   v8 = a1[1];
        -- else
        --   v8 = *(_DWORD *)(*a1 + 4) + 56;
        if @length! > i then
            return Value(@getValues_! - i)\toLua!
        else
            --well if you look at the assembly code, normally v8 will return v8::Undefined which is pIsolate+0x56, however we don't need that extra translation from v8 to lua so we can just return nothing instead lol
            return

class Primitive extends Value
    new: (val) => @this = val
    getValue: => @this
    toString: => @this\getValue!\stringValue!

class Null extends Primitive
    new: (isolate) => @this = Value(cast('uintptr_t', isolate) + 0x120)

class Undefined extends Primitive
    new: (isolate) => @this = Value(cast('uintptr_t', isolate) + 0x110)

class Boolean extends Primitive
    new: (isolate, bool) => @this = Value(cast('uintptr_t', isolate) + (if bool then 0x128 else 0x130))

class Number extends Value
    new: (isolate, val) =>
        @this = MaybeLocal(v8_dll\get('?New@Number@v8@@SA?AV?$Local@VNumber@v8@@@2@PEAVIsolate@2@N@Z', 'void*(__fastcall*)(void*,void*,double)')(intbuf, isolate, tonumber(val)))\toLocalChecked!
    getLocal: => @this
    getValue: => @getInstance!\numberValue!
    getInstance: => @this!

class Integer extends Number
    new: (isolate, val) =>
        @this = MaybeLocal(v8_dll\get('?New@Integer@v8@@SA?AV?$Local@VInteger@v8@@@2@PEAVIsolate@2@H@Z', 'void*(__fastcall*)(void*,void*,uintptr_t)')(intbuf, isolate, tonumber(val)))\toLocalChecked!

class String extends Value
    new: (isolate, val) =>
        @this = MaybeLocal(v8_dll\get('?NewFromUtf8@String@v8@@SA?AV?$MaybeLocal@VString@v8@@@2@PEAVIsolate@2@PEBDW4NewStringType@2@H@Z', 'void*(__fastcall*)(void*,void*,const char*,int,int)')(intbuf, isolate, val, 0, #val))\toLocalChecked!
    getLocal: => @this
    getValue: => @getInstance!\stringValue!
    getInstance: => @this!

class Isolate
    new: (val = pIsolate) => @this = val
    enter: => v8_dll\get('?Enter@Isolate@v8@@QEAAXXZ', 'void(__thiscall*)(void*)')(@this)
    exit: => v8_dll\get('?Exit@Isolate@v8@@QEAAXXZ', 'void(__thiscall*)(void*)')(@this)
    getCurrentContext: => MaybeLocal(v8_dll\get('?GetCurrentContext@Isolate@v8@@QEAA?AV?$Local@VContext@v8@@@2@XZ', 'void**(__fastcall*)(void*,void*)')(@this, intbuf))\toValueChecked!\getInternal!
    getInternal: => @this

class Context
    new: (val) => @this = val
    enter: => v8_dll\get('?Enter@Context@v8@@QEAAXXZ', 'void(__thiscall*)(void*)')(@this)
    exit: => v8_dll\get('?Exit@Context@v8@@QEAAXXZ', 'void(__thiscall*)(void*)')(@this)
    getInternal: => @this
    global: =>
        MaybeLocal(v8_dll\get('?Global@Context@v8@@QEAA?AV?$Local@VObject@v8@@@2@XZ', 'void*(__fastcall*)(void*,void*)')(@this, intbuf))

class HandleScope
    new: => @this = new('char[0x18]')
    enter: => v8_dll\get('??0HandleScope@v8@@QEAA@PEAVIsolate@1@@Z', 'void(__fastcall*)(void*,void*)')(@this, pIsolate)
    exit: => v8_dll\get('??1HandleScope@v8@@QEAA@XZ', 'void(__thiscall*)(void*)')(@this)
    createHandle: (val) => v8_dll\get('?CreateHandle@HandleScope@v8@@KAPEA_KPEAVIsolate@internal@2@_K@Z', 'void**(__fastcall*)(void*,void*)')(pIsolate, val)
    __call: (func, panel = panorama.GetPanel('CSGOJsRegistration')) =>
        isolate = Isolate!
        isolate\enter!
        @enter!
        ctx = if panel then nativeGetPanelContext(panel)[0] else Context(isolate\getCurrentContext!)\global!\getInternal!
        ctx = Context(if ctx ~= nullptr then @createHandle(ctx[0]) else 0)
        ctx\enter!
        val = nil
        if safe_mode then
            status, ret = xpcall(func,exception)
            if status then val = ret
        else
            val = func!
        ctx\exit!
        @exit!
        isolate\exit!
        val

class TryCatch
    new: => @this = new('char[0x30]') -- I pulled this out of my ass
    enter: => v8_dll\get('??0TryCatch@v8@@QEAA@PEAVIsolate@1@@Z', 'void(__fastcall*)(void*, void*)')(@this, pIsolate)
    exit: => v8_dll\get('??1TryCatch@v8@@QEAA@XZ', 'void(__thiscall*)(void*)')(@this)
    canContinue: => v8_dll\get('?CanContinue@TryCatch@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    hasTerminated: => v8_dll\get('?HasTerminated@TryCatch@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    hasCaught: => v8_dll\get('?HasCaught@TryCatch@v8@@QEBA_NXZ', 'bool(__thiscall*)(void*)')(@this)
    message: => Local(v8_dll\get('?Message@TryCatch@v8@@QEBA?AV?$Local@VMessage@v8@@@2@XZ', 'void*(__fastcall*)(void*, void*)')(@this, intbuf))
    getInternal: => @this

class Script
    compile: (panel, source, layout = '') =>
        __thiscall(cast('void**(__thiscall*)(void*,void*,const char*,const char*)', follow_call(find_pattern('panorama.dll', 'E8 ? ? ? ? 48 8B D8 48 83 38 00 75 15'))), UIEngine\getInstance!)(panel, source, layout)
    run: (compiled, context) =>
        v8_dll\get('?Run@Script@v8@@QEAA?AV?$MaybeLocal@VValue@v8@@@2@V?$Local@VContext@v8@@@2@@Z', 'void*(__fastcall*)(void*, void*, void*)')(compiled, intbuf, context)
    loadstring: (str, panel) =>
        -- this function does all the exception handling by itself, and returns a persistent
        compiled = MaybeLocal(@compile(panel, str))\toLocalChecked! -- CUIEngine::CompileScript
        if compiled == nullptr then
            if safe_mode then -- if can pcall, you should pcall this function to avoid script termination
                error("\nFailed to compile the given javascript string, please check the error message above ^\n")
            else
                print("\nFailed to compile the given javascript string, please check the error message above ^\n")
                return () -> print('WARNING: Attempted to call nullptr (script compilation failed)') -- your software doesn't support pcall wtf
        isolate = Isolate!
        handleScope = HandleScope!
        isolate\enter!
        handleScope\enter!
        ctx = if panel then nativeGetPanelContext(panel)[0] else Context(isolate\getCurrentContext!)\global!\getInternal!
        ctx = Context(if ctx ~= nullptr then handleScope\createHandle(ctx[0]) else 0)
        ctx\enter!
        tryCatch = TryCatch!
        tryCatch\enter!
        ret = MaybeLocal(@run(compiled!\getInternal!, ctx\getInternal!))\toValueChecked! -- nativeRunScript does not create it's own handlescope/context, we need to enter the context manually
        tryCatch\exit!
        if ret == nullptr then -- this doesn't happen very often if at all...
            if safe_mode then -- if can pcall, you should pcall this function to avoid script termination
                error("\nFailed to evaluate the given javascript string, please check the error message above ^\n")
            else
                print("\nFailed to evaluate the given javascript string, please check the error message above ^\n")
                ret = () -> print('WARNING: Attempted to call nullptr (script execution failed)') -- your software doesn't support pcall wtf
        else
            ret = ret\toLua!
        ctx\exit!
        handleScope\exit!
        isolate\exit!
        ret
--#pragma endregion native_v8_functions

--#pragma region panorma_functions
PanelInfo_t = typeof([[
    struct {
        char* pad1[2];
        void* m_pPanel;
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

metatype(CUtlVector_Constructor_t, {
    __index: {
        Count: => @m_Memory.m_nAllocationCount,
        Element: (i) => cast(typeof('$&', PanelInfo_t), @m_Memory.m_pMemory[i])
        RemoveAll: =>
            @ = nil
            @ = typeof('$[?]', CUtlVector_Constructor_t)(1)[0]
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

panelArray = cast(typeof('$&', CUtlVector_Constructor_t), cast('uintptr_t', UIEngine\getInstance!) + 304)

panorama.hasPanel = (panelName) ->
    for i, v in ipairs(panelArray) do
        curPanelName = string(nativeGetID(v))
        if curPanelName == panelName then
            return true
    false

panorama.getPanel = (panelName, fallback) ->
    cachedPanel = panorama.panelIDs[panelName]
    if cachedPanel ~= nil and nativeIsValidPanelPointer(cachedPanel) and string(nativeGetID(cachedPanel))==panelName then
        return cachedPanel
    panorama.panelIDs = {}

    pPanel = nullptr
    for i, v in ipairs(panelArray) do
        curPanelName = string(nativeGetID(v))
        if curPanelName ~= '' then
            panorama.panelIDs[curPanelName] = v
            if curPanelName == panelName then
                pPanel = v
                break
    if pPanel == nullptr then
        if fallback ~= nil then
            pPanel = panorama.getPanel(fallback)
        else
            error('Failed to get target panel %s (EAX == 0)'\format(tostring(panelName)))
    pPanel

panorama.getIsolate = () -> Isolate(nativeGetIsolate!)

panorama.runScript = (jsCode, panel = panorama.getPanel('CSGOJsRegistration'), pathToXMLContext = 'panorama/layout/base.xml') ->
    if not nativeIsValidPanelPointer(panel) then error('Invalid panel pointer (EAX == 0)')
    nativeCompileRunScript(panel,jsCode,pathToXMLContext,8,10,false)

panorama.loadstring = (jsCode, panel = 'CSGOJsRegistration') ->
    fallback = 'CSGOJsRegistration'
    if panel == 'CSGOMainMenu' then fallback = 'CSGOHud'
    if panel == 'CSGOHud' then fallback = 'CSGOMainMenu'
    Script\loadstring('(()=>{%s})'\format(jsCode), panorama.getPanel(panel, fallback))

panorama.open = (panel = 'CSGOJsRegistration') ->
    fallback = 'CSGOJsRegistration'
    if panel == 'CSGOMainMenu' then fallback = 'CSGOHud'
    if panel == 'CSGOHud' then fallback = 'CSGOMainMenu'
    HandleScope!((() -> Context(Isolate!\getCurrentContext!)\global!\toValueChecked!\toLua!), panorama.GetPanel(panel, fallback))


panorama.GetPanel = panorama.getPanel -- backwards compatibility
panorama.GetIsolate = panorama.getIsolate
panorama.RunScript = panorama.runScript -- backwards compatibility
panorama.panelArray = panelArray

panorama.info = _INFO
panorama.flush = shutdown

setmetatable(panorama, {
    __tostring: => 'luv8 panorama library v%.1f'\format(_INFO._VERSION)
    __index: (key) =>
        if panorama.hasPanel(key) then
            return panorama.open(key)
        panorama.open![key]
})
--#pragma endregion panorma_functions

--add_shutdown_callback(shutdown)

panorama
