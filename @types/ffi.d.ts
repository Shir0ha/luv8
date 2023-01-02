type clib = symbol
type ctype = symbol
type cdata = any
type userdata = any

/** @noResolution */
declare module "ffi" {
    let exports: {
        cdef: (this: void, def: string) => void
        C: {}
        load: (this: void, name: string, global?: boolean) => clib
        new: (this: void, ct: (string | ctype), nelem?: number, ...init: any[]) => cdata
        typeof: (this: void, ct: (string | ctype), ...init: ctype[]) => ctype
        cast: (this: void, ct: (string | ctype), ...init: cdata[]) => cdata
        metatype: (this: void, ct: ctype, metatable: object) => ctype
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
