import cast, typeof, new from ffi
import jmp, proc_bind from require 'hooks'

--#pragma region helper_functions
__thiscall = (func, this) -> (...) -> func(this, ...)
table_copy = (t) -> {k, v for k, v in pairs t}
vtable_bind = (module, interface, index, typedef) ->
    addr = cast("void***", utils.find_interface(module, interface)) or error(interface .. " is nil.")
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
    __call: => cast("void**", @this)[0]

class MaybeLocal
    new: (val) => @this = val
    toLocalChecked: => Local(@this) unless @this == nullptr

class Value
    new: (val) => @this = val
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
        MaybeLocal(v8_dll\get("?ToObject@Value@v8@@QBE?AV?$Local@VObject@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, new("int[1]")))

class Object
    new: (val) => @this = val
    get: (key) =>
        MaybeLocal(v8_dll\get("?Get@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@@Z", "void*(__thiscall*)(void*,void*,void*)")(@this, new("int[1]"), key))
    set: (key, value) => v8_dll\get("?Set@Object@v8@@QAE_NV?$Local@VValue@v8@@@2@0@Z", "bool(__thiscall*)(void*,void*,void*)")(@this, key, value)
    getPropertyNames: =>
        MaybeLocal(v8_dll\get("?GetPropertyNames@Object@v8@@QAE?AV?$Local@VArray@v8@@@2@XZ", "void*(__thiscall*)(void*,void*)")(@this, new("int[1]")))
    callAsFunction: (args, recv, argc, argv) =>
        MaybeLocal(v8_dll\get("?CallAsFunction@Object@v8@@QAE?AV?$Local@VValue@v8@@@2@V32@HQAV32@@Z", "void*(__thiscall*)(void*,void*,void*,int,void*)")(@this, new("int[1]"), argc, argv))
    getIdentityHash: => v8_dll\get("?GetIdentityHash@Object@v8@@QAEHXZ", "int(__thiscall*)(void*)")(@this)

class Array
    new: (val) => @this = val
    length: => v8_dll\get("?Length@Array@v8@@QBEIXZ", "uint32_t(__thiscall*)(void*)")(@this)

class Isolate
    new: (val) => @this = val
    enter: => v8_dll\get("?Enter@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    exit: => v8_dll\get("?Exit@Isolate@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    getInstance: => @this

class Context
    new: (val) => @this = val
    enter: => v8_dll\get("?Enter@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)
    exit: => v8_dll\get("?Exit@Context@v8@@QAEXXZ", "void(__thiscall*)(void*)")(@this)

class HandleScope
    new: => @this = new("char[0xC]")
    enter: => v8_dll\get("??0HandleScope@v8@@QAE@PAVIsolate@1@@Z", "void(__thiscall*)(void*,void*)")(@this, nativeGetIsolate!)
    exit: => v8_dll\get("??1HandleScope@v8@@QAE@XZ", "void(__thiscall*)(void*)")(@this)
    createHandle: (val) => v8_dll\get("?CreateHandle@HandleScope@v8@@KAPAPAVObject@internal@2@PAVIsolate@42@PAV342@@Z", "void*(__cdecl*)(void*,void*)")(nativeGetIsolate!, val)
    __call: (func, panel) =>
        isolate = Isolate(nativeGetIsolate!)
        isolate\enter!
        @enter!
        ctx = nativeGetPanelContext(nativeGetJavaScriptContextParent(panel))[0]
        ctx = Context(if ctx ~= nullptr then @createHandle(ctx[0]) else 0)
        ctx\enter!
        val = func!
        ctx\exit!
        @exit!
        isolate\exit!
        val

test = HandleScope()
testFunc = ->
    str = MaybeLocal(v8_dll\get("?NewFromUtf8@String@v8@@SA?AV?$MaybeLocal@VString@v8@@@2@PAVIsolate@2@PBDW4NewStringType@2@H@Z", "void*(__cdecl*)(void*,void*,const char*,int,int)")(new("int[1]"), nativeGetIsolate!, "hello world", 0, 11))
    print(Value(str\toLocalChecked!!)\stringValue!)
test(testFunc, panorama.GetPanel("CSGOJsRegistration"))
return 0