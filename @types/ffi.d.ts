type Trim<T extends string> = T extends ` ${infer R}` ? Trim<R> : T extends `${infer L} ` ? Trim<L> : T
type Split<T extends string, S extends string = ','> = T extends `${infer L}${S}${infer R}` ? [Trim<L>, ...Split<Trim<R>, S>] : [T] extends [''] ? [] : [T]
type CDataSplit<T extends string, S extends string = ','> = T extends `${infer L}${S}${infer R}` ? [cdata<Trim<L>>, ...CDataSplit<Trim<R>, S>] : [T] extends [''] ? [] : [cdata<T>]
type CStructFieldSplit<T extends string[], S extends string = ' '> = T extends [`${infer A}${S}${infer B}`, ...infer R extends string[]] ? [{ [K in B]: CTypeTransform<A> }, ...CStructFieldSplit<R, S>] : T extends [`${infer A}`, ...infer R extends string[]] ? [A, ...CStructFieldSplit<R, S>] : T extends [] ? [] : never
type MergeToObject<T extends any[]> = T extends [infer A, ...infer R] ? A extends object ? R extends any[] ? MergeToObject<R> & A : A : never : T extends [] ? {} : never
type CTypeTransform<T extends string> = T extends 'void' ? void : T extends 'int' ? number : T extends 'unsigned int' ? number : T extends 'long' ? number : T extends 'unsigned long' ? number : T extends 'long long' ? number : T extends 'unsigned long long' ? number : T extends 'float' ? number : T extends 'double' ? number : T extends 'char' ? number : T extends 'unsigned char' ? number : T extends 'short' ? number : T extends 'unsigned short' ? number : T extends 'int8_t' ? number : T extends 'uint8_t' ? number : T extends 'int16_t' ? number : T extends 'uint16_t' ? number : T extends 'int32_t' ? number : T extends 'uint32_t' ? number : T extends 'int64_t' ? number : T extends 'uint64_t' ? number : T extends 'intptr_t' ? number : T extends 'uintptr_t' ? number : T extends 'size_t' ? number : T extends 'bool' ? boolean : T extends 'const char' ? string : T
type CStructParse<T extends string> = MergeToObject<CStructFieldSplit<Split<Trim<T>, ';'>>>

type clib = symbol
type ctype = symbol
type cdata<T extends string | ctype> = T extends `${infer A}[${infer _}]` | `${infer A}*` | `${infer A}&` ? cdata<A>[]
    : T extends `${infer A}(__${infer _}*)(${infer C})` ? (...args: CDataSplit<C>) => cdata<A>
    : T extends `struct {${infer A}}` ? CStructParse<A>
    : T extends `${infer A}` ? CTypeTransform<A> : never
type userdata = object

/** @noResolution */
declare module "ffi" {
    let exports: {
        cdef: (this: void, def: string) => void
        C: {}
        load: (this: void, name: string, global?: boolean) => clib
        new: (<T extends string | ctype, U>(this: void, ct: T, nelem?: number, ...init: U[]) => cdata<T>) & (<T extends string | ctype, U>(this: void, ct: T, ...init: U[]) => cdata<T>)
        typeof: <T extends string | ctype>(this: void, ct: T, ...types: ctype[]) => ctype<T>
        cast: <T extends string | ctype, U>(this: void, ct: T, ...init: U[]) => cdata<T>
        metatype: (this: void, ct: ctype, metatable: object) => ctype<T>
        gc: (this: void, ct: cdata, finalizer: Function) => void
        sizeof: (this: void, ct: (string | ctype | cdata), nelem?: number) => number
        alignof: (this: void, ct: (string | ctype | cdata)) => number
        offsetof: (this: void, ct: (string | ctype | cdata), field: string) => number
        istype: (this: void, ct: cdata, obj: any) => boolean
        errno: (this: void, msg: string) => never
        string: (this: void, ptr: cdata, len?: number) => string
        copy: (((this: void, dst: cdata, src: cdata, len: number) => void) & ((this: void, dst: cdata, str: string) => void))
        fill: (this: void, dst: cdata, len: number, c: any) => void
        abi: (this: void, param: ('32bit' | '64bit' | 'le' | 'be' | 'fpu' | 'softfp' | 'hardfp' | 'eabi' | 'win')) => boolean
        os: (this: void) => string
        arch: (this: void) => string
    }
    export = exports
}
