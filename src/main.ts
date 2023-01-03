import ffi = require("ffi")

let v = ffi.cast('void*(__fastcall*)(void*, void*)', () => {})
//  ^? let v: (args_0: void[], args_1: void[]) => void[]

let a = ffi.new('void*')
//  ^? let a: void[]

let s = ffi.cast('struct { int x; int y; int z; }(__fastcall*)(void*, void*)', () => {})
//  ^? let s: (args_0: void[], args_1: void[]) => ({z: number} & {y: number} & {x: number})

let t = s(a, a)
//  ^? let t: {z: number} & {y: number} & {x: number}

let c = ffi.new('const char*', 'hello')
//  ^? let c: string[]
