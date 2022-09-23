# luv8 - Panorama V8 support for lua  

## build  
1. download and install [moonc compiler](https://moonscript.org/)  
2. `./moonc panorama.moon`

## install  

### ev0lve  
- use the [workshop version](https://ev0lve.xyz/scripts/panorama-library.50/) on forum
### primordial  
- use the [workshop version](https://primordial.dev/resources/panorama-library.248/) on forum
- the workshop version may be outdated (due to [@Shir0ha](https://github.com/Shir0ha) being lazy af)
### fatality  
- use the [stolen version](https://fatality.win/threads/panorama.11377/) on forum (jk, I gave [@panzerfaust](https://github.com/panzerfaust1) the source code)
- may be EXTREMELY outdated, please use the [prebuilt version](https://github.com/Shir0ha/luv8/blob/main/build/panorama.lua) or build one yourself
### other cheats  
- luv8 currently only provides compatibility with ev0lve, primordial and fatality, if you wish to use it on other cheats feel free to add more to the compatibility layer and/or contribute code by pr. Contributions are welcomed.

## API
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
- ev0lve
  - the development of this library was 99% done on [ev0lve.xyz](https://ev0lve.xyz/)
- primordial
  - public testing of this library happened on [primordial.dev](https://primordial.dev/)