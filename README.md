# luv8 - Panorama V8 support for lua  

## build  
1. download and install [moonc compiler](https://moonscript.org/)  
2. `./moonc panorama.moon`

## exported functions

```lua
panorama.hasPanel(string panelName) : bool
panorama.getPanel(string panelName, string fallback) : void*
panorama.getIsolate() : void*
panorama.runScript(string jsCode, void* panel, string pathToXMLContext) : nil (THIS FUNCTION IS UNTESTED IN CS2)
panorama.loadrawstring(string jsCode, string panel) : any (PersistentProxy_mt)
panorama.loadstring(string jsCode, string panel) : function (PersistentProxy_mt)
panorama.open(string panel) : Object (PersistentProxy_mt)
panorama.panelArray: CUtlVector_Constructor_t (__index and __ipairs metamethods available)
panorama.setSafeMode(bool enabled) : nil
panorama.info() : nil
panorama.flush() : nil
panorama.pairs(table t) : function
panorama.ipairs(table t) : function
panorama.len(table t) : number
panorama.type(any) : string
```

## example usage (in moonscript)

```lua
local js_globalThis = panorama.open("CSGOHud") -- finds the panel CSGOHud (ID = 1), and get a reference to the globalThis

print(tostring(js_globalThis)) -- [object Object], the lua tostring method will invoke the javascript toString() method on the object


-- this will iterate through the object, basically Object.keys(js_globalThis).forEach()
for i,v in panorama.pairs(js_globalThis) do
    print(i.." ",v," "..panorama.type(v))
end

-- this will not do anything, ipairs is for arrays only
for i,v in panorama.ipairs(js_globalThis) do
    print(i.." ",v," "..panorama.type(v))
end


arrtest = panorama.loadstring("return [1, false, \"test\"]") -- this compiles the js code and returns a reference to the function

print(tostring(arrtest)) -- ()=>{return [1, false, "test"] as you can see, we have a wrapper function builtin

--now we call that function
arr = arrtest()
print(tostring(arr)) -- 1,false,test again it returns an array object, so tostring() is equivalent to the javascript toString() method
print(panorama.type(arr)) -- PersistentProxy(Array) this is indeed a js array
print(type(arr)) -- table, the default type() will only tell you this much, it is recommended to use panorama.type()
print(panorama.type({}), panorama.type(123), panorama.type("deez nuts")) -- panorama.type() is fully compatible with the lua builtin type(), same for panorama.ipairs, panorama.pairs, panorama.len

--ipairs
for i,v in panorama.ipairs(arr) do
    print(i.. "->" ..tostring(v).." ("..panorama.type(v)..")")
end
-- [lua] 0->1 (number)
-- [lua] 1->false (boolean)
-- [lua] 2->test (string)

print(#arr) -- 0, sadly this does not work on luajit (lua 5.1)
print(panorama.len(arr)) -- 3, this works
print(panorama.len(js_globalThis)) -- 35, this works for objects and even functions as well

-- you can also access individual elements of an array or object
print(arr[0]) -- 0 is the starting index for array access..... I know this is not the lua standard but fuck the lua standard


-- example of loadrawstring, it removes the wrapper function
arrtest=panorama.loadrawstring("[1, false, \"test\"]")
-- you CANNOT use a return statement outside the scope of a function, else you will get the error  Illegal return statement

print(arrtest) --  1,false,test


-- this is how you print a message to the console by calling the $.Msg function with lua
js_globalThis["$"].Msg("Hello World?")
-- you can also do it this way in js
panorama.loadstring("$.Msg('Hello World!')")()
-- $ is an alias for panorama
js_globalThis.panorama.Msg("Hello World???")

-- we support the neverlose style syntax as well
panorama.CSGOHud['$'].Msg("deeznuts1")
panorama['$'].Msg("deeznuts2")

--an example of using MyPersonaAPI
local steam_name = panorama.MyPersonaAPI.GetName()
print(steam_name) -- dhdj
print(type(steam_name)) -- string
-- notice how the type is a lua string, rather than a PersistentProxy(String), this is because only Objects, Arrays and Functions are passed by reference, all other types are passed by value

-- last thing is that panorama.open() as well as object indexing does not do any caching. so it is better to
local js = panorama.open()
js_MyPersonaAPI = js.MyPersonaAPI
js_MyPersonaAPI_GetName = js_MyPersonaAPI.GetName
for i=1,10 do
    js_MyPersonaAPI_GetName()
end
-- rather than
for i=1,10 do
    panorama.open().MyPersonaAPI.GetName()
end
-- when you have to call a js function multiple times

-- the neverlose style globalThis access has a caching mechanism, however object indexing still does not
print(panorama.MyPersonaAPI.GetName()) -- panorama.MyPersonaAPI is cached, since we have already used it once, GetName is not, thus a handlescope was entered in order to access it, and another handlescope was entered in order to call it
```

## resources

[cs2 panorama source](https://github.com/dhdjSYS/cs2_panorama_source/tree/main)  