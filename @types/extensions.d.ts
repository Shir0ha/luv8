/**
 * Emits a Lua continue statement.
 * @internal
 * @emits `continue`
 */
declare function __continue(this: void): void;

/**
 * Emits a Lua goto statement (requires Lua 5.2+ or JIT).
 * @param label - The label name to jump to.
 * @internal
 * @emits `goto label`
 */
declare function __goto(this: void, label: string): void;

/**
 * Inlines the body of the function in-place (useful in hot-path for high-performance code).
 * @param body - The function to inline (must be within chunk's scope).
 * @internal
 * @emits `body`
 * @remarks
 * This is currently experimental.
 */
declare function __inline(this: void, body: ((this: void) => void)): void;
declare function __inline<T>(this: void, body: ((this: void, arg: T) => void), arg: T): void;
declare function __inline<T1, T2>(this: void, body: ((this: void, arg1: T1, arg2: T2) => void), arg1: T1, arg2: T2): void;
declare function __inline<T1, T2, T3>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3) => void), arg1: T1, arg2: T2, arg3: T3): void;
declare function __inline<T1, T2, T3, T4>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4): void;
declare function __inline<T1, T2, T3, T4, T5>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5): void;
declare function __inline<T1, T2, T3, T4, T5, T6>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13, arg14: T14) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13, arg14: T14): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13, arg14: T14, arg15: T15) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13, arg14: T14, arg15: T15): void;
declare function __inline<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16>(this: void, body: ((this: void, arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13, arg14: T14, arg15: T15, arg16: T16) => void), arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5, arg6: T6, arg7: T7, arg8: T8, arg9: T9, arg10: T10, arg11: T11, arg12: T12, arg13: T13, arg14: T14, arg15: T15, arg16: T16): void;

/**
 * Emits a Lua label statement (requires Lua 5.2+ or JIT).
 * @param label - The label name to define.
 * @internal
 * @emits `::label::`
 */
declare function __label(this: void, label: string): void;

/**
 * Emits a class method iterator. Use in conjunction with for-of loop.
 * @typeParam TClass - The class to iterate.
 * @internal
 * @emits `next, TClass.prototype` (skipping non-functions, metamethods and constructor)
 */
declare function __methodsof<TClass extends AnyNotNil>(this: void): LuaIterable<LuaMultiReturn<[string, ((this: void, ...args: any[]) => any)]>>;

/**
 * Emits a Lua next iterator. Use in conjunction with for-of loop.
 * @param t - The table to iterate.
 * @internal
 * @emits `next, t, index`
 */
declare function __next<TKey extends AnyNotNil, TValue>(this: void, t: LuaTable<TKey, TValue>, index?: any): LuaIterable<LuaMultiReturn<[TKey, NonNullable<TValue>]>>;

/**
 * Emits a Lua next iterator. Use in conjunction with for-of loop.
 * @param t - The object to iterate.
 * @internal
 * @emits `next, t, index`
 */
declare function __next<T>(this: void, t: T, index?: any): LuaIterable<LuaMultiReturn<[keyof T, NonNullable<T[keyof T]>]>>;

/**
 * Emits a class prototype iterator. Use in conjunction with for-of loop.
 * @typeParam TClass - The class to iterate.
 * @internal
 * @emits `next, TClass.prototype`
 */
declare function __prototypeof<TClass extends AnyNotNil>(this: void): LuaIterable<LuaMultiReturn<[string, AnyNotNil]>>;

/**
 * Provides an ability to preserve (and validate) parameters' type information of the parent function.
 * @param validator - The callback function which will receive parameters' type information.
 * @remarks
 * This is currently experimental. Must be called directly in the main scope of the function.
 */
declare function __typedparams(this: void, validator: (this: void, ...info: [/*parameter name*/string, /*full type*/string, /*dotDotDotToken*/boolean, /*questionToken*/boolean, /*type*/string, /*initializer*/string?][]) => void): void;

/**
 * Emits a Lua vararg operator `...`.
 * @internal
 * @emits `...`
 */
declare function __vararg(this: void): LuaIterable<LuaMultiReturn<[...any[]]>>;

/**
 * Unsafely casts a given value as a value of type T.
 * @typeParam T - The type to cast to.
 * @param value - The value to be cast.
 * @returns Returns the given value.
 * @internal
 * @emits `value`
 * @remarks
 * This is useful in-place replacement for "as any" casting, because it allows to "find all references" quickly.
 */
declare function unsafe_cast<T>(this: void, value: unknown): T;