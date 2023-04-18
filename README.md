# luv8 - Panorama V8 support for lua  

## Will there be cs2 support
yes.

## build  
1. download and install [moonc compiler](https://moonscript.org/)  
2. `./moonc panorama.moon`

## install  

### ev0lve  
- use the [workshop version](https://ev0lve.xyz/resources/panorama.43/) on forum
### primordial  
- use the [workshop version](https://primordial.dev/resources/panorama-library.248/) on forum
- the workshop version may be outdated (due to [@Shir0ha](https://github.com/Shir0ha) being ~~lazy af~~ **DEAD**), please use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
### fatality  
- use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
### legendware  
- use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
- released on [forum](https://legendware.pw/threads/panorama-library.8821/)
### pandora
- use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
- released on [forum](https://pandora.gg/threads/panorama-library.651/)
### gamesense
- use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
### memesense
- buggy & may crash from time to time
- use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
### nixware
- use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
### other cheats  
- luv8 currently only provides compatibility with ev0lve, primordial, pandora, legendware, memesense, fatality, gamesense, and nixware, if you wish to use it on other cheats feel free to add more to the compatibility layer and/or contribute code by pr. Contributions are welcomed.

## API
### supports both gamesense & neverlose style api
### `panorama.loadstring`  
```lua
panorama.loadstring(js_code: string[, panel: string]) : function
```  
> compiles the given Javascript code inside the v8::Context of the specified panel and
returns a function handle for calling the compiled code  
### `panorama.open`  
```lua
panorama.open([panel: string]) : table (V8PersistentProxy)
```  
> opens a handle to the v8 global object of the v8::Context of the specified panel and
returns a V8PersistentProxy
### `panorama.flush`  
```lua
panorama.flush() : nil
```  
> removes all globalized references
### `panorama.RunScript`  
```lua
panorama.RunScript(js_code: string[, panel: ffi::void*[, xml_context: string]]) : ffi::int
```  
> executes the given Javascript code with CUIEngine::RunScript()  
### `panorama.GetPanel`  
```lua
panorama.GetPanel(panel: string[, fallback: string]): ffi::void* (UIPanel)
```  
> returns a pointer to the given panel name, raises error upon failure
### `panorama.GetIsolate`  
```lua
panorama.GetIsolate(): Isolate
```  
> returns the Isolate object

## contributions
- [@dhdjSYS](https://github.com/dhdjSYS)
  - reverse engineering
  - implemented panel array traverse & get target panel
  - implemented data conversion from lua to v8js
  - implemented data conversion from v8js to lua
  - implemented function argument conversion from lua to v8js
  - implemented v8js function call (includes  calling v8js member functions of an object with parent)
  - implemented compatibility layer
  - implemented safe_error
  - implemented try catch
  - implemented `panorama.loadstring()`, `panorama.open()`, `panorama.RunScript()`, `panorama.GetPanel()`
  - fixed random bugs and created more of them
- [@Shir0ha](https://github.com/Shir0ha)
  - initiated & named the project
  - reverse engineering
  - initial implementation of V8ProxyValue (which eventually was rewritten to V8PersistentProxy)
  - implemented globalizeReference
  - implemented HandleScope
  - implemented Script\Compile (recreated `CUIEngine::RunScript` in lua)
  - implemented `V8Local`, `V8MaybeLocal`, `V8Value` in lua
  - rewritten & formated the code in moonscript
  - created at least 1 bug in each and every feature and fixed some of them
- [@nezu](https://github.com/dumbasPL)
  - added gamesense support
- [@lztqq](https://github.com/lztqq)
  - added nixware support
- ev0lve
  - the development of this library was 99% done on [ev0lve.xyz](https://ev0lve.xyz/)
- primordial
  - public testing of this library happened on [primordial.dev](https://primordial.dev/)

## some other stuff
- [old footage of the panorama lib before it was rewritten in moonscript](https://www.youtube.com/watch?v=2i9itIjnDlo)  
- [confusing stuff when we were trying to figure out globalizeReference](https://i.imgur.com/cX9hedq.png)
- [??????????](https://i.imgur.com/hJpVJtt.png)