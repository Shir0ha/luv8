"use strict";
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
var _a;
exports.__esModule = true;
var ts = require("typescript");
var tstl = require("typescript-to-lua");
var utils_1 = require("typescript-to-lua/dist/utils");
var createDiagnosticFactory = function (category, message) {
    return (0, utils_1.createSerialDiagnosticFactory)(function (node) {
        var args = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            args[_i - 1] = arguments[_i];
        }
        return {
            file: ts.getOriginalNode(node).getSourceFile(),
            start: ts.getOriginalNode(node).getStart(),
            length: ts.getOriginalNode(node).getWidth(),
            messageText: typeof message === "string" ? message : message.apply(void 0, args),
            category: category
        };
    });
};
var createErrorDiagnosticFactory = function (message) {
    return createDiagnosticFactory(ts.DiagnosticCategory.Error, message);
};
var createWarningDiagnosticFactory = function (message) {
    return createDiagnosticFactory(ts.DiagnosticCategory.Warning, message);
};
var getLuaTargetName = function (version) { return (version === tstl.LuaTarget.LuaJIT ? "LuaJIT" : "Lua ".concat(version)); };
var unsupportedForTarget = createErrorDiagnosticFactory(function (functionality, version) {
    return "".concat(functionality, " is/are not supported for target ").concat(getLuaTargetName(version), ".");
});
//#endregion
var expectedStringLiteralInGoto = createErrorDiagnosticFactory("Expected a string literal in '__goto'.");
var expectedFunctionExpressionInInline = createErrorDiagnosticFactory("Expected a function expression in '__inline'.");
var expectedStringLiteralInLabel = createErrorDiagnosticFactory("Expected a string literal in '__label'.");
var expectedAnArgumentInUnsafeCast = createErrorDiagnosticFactory("Expected a value in 'unsafe_cast'.");
var expectedClassTypeNameInMethodsOf = createErrorDiagnosticFactory("Expected a class type name in '__methodsof'.");
var expectedAnArgumentInNext = createErrorDiagnosticFactory("Expected an object in '__next'.");
var expectedClassTypeNameInPrototypeOf = createErrorDiagnosticFactory("Expected a class type name in '__prototypeof'.");
var typedParamsUsedOutsideOfFunction = createErrorDiagnosticFactory("'__typedparams' can not be used outside a function.");
var plugin = {
    visitors: (_a = {},
        _a[ts.SyntaxKind.CallExpression] = function (node, context) {
            var result = context.superTransformExpression(node);
            if (tstl.isCallExpression(result) && tstl.isIdentifier(result.expression)) {
                switch (result.expression.text) {
                    case "unsafe_cast": {
                        if (result.params.length === 1) {
                            return result.params[0];
                        }
                        context.diagnostics.push(expectedAnArgumentInUnsafeCast(node));
                        break;
                    }
                    case "__vararg": {
                        return tstl.createDotsLiteral(node);
                    }
                }
            }
            return result;
        },
        _a[ts.SyntaxKind.ExpressionStatement] = function (node, context) {
            var _a, _b, _c, _d, _e, _f;
            var result = context.superTransformStatements(node);
            if (ts.isExpressionStatement(node)) {
                var expr = node.expression;
                if (ts.isCallExpression(expr) && ts.isIdentifier(expr.expression)) {
                    switch (expr.expression.text) {
                        case "__continue": {
                            return tstl.createExpressionStatement(tstl.createIdentifier("continue", node), node);
                        }
                        case "__goto": {
                            if (context.luaTarget === tstl.LuaTarget.Lua50 || context.luaTarget === tstl.LuaTarget.Lua51) {
                                context.diagnostics.push(unsupportedForTarget(node, "goto", context.luaTarget));
                                break;
                            }
                            if (expr.arguments.length === 1 && ts.isStringLiteral(expr.arguments[0])) {
                                return tstl.createGotoStatement(expr.arguments[0].text, node);
                            }
                            context.diagnostics.push(expectedStringLiteralInGoto(node));
                            break;
                        }
                        case "__inline": {
                            if (expr.arguments.length > 0) {
                                var bodyArg = expr.arguments[0];
                                if (ts.isIdentifier(bodyArg)) {
                                    try {
                                        bodyArg = context.checker.getSymbolAtLocation(bodyArg).getDeclarations()[0];
                                    }
                                    catch (error) {
                                        context.diagnostics.push(expectedFunctionExpressionInInline(node));
                                        break;
                                    }
                                    if (!bodyArg) {
                                        context.diagnostics.push(expectedFunctionExpressionInInline(node));
                                        break;
                                    }
                                }
                                var paramNames = [];
                                var funcExpr = void 0;
                                if (ts.isFunctionLike(bodyArg)) {
                                    var bodyNode = context.transformNode(bodyArg)[0];
                                    if (!bodyNode) {
                                        context.diagnostics.push(expectedFunctionExpressionInInline(node));
                                        break;
                                    }
                                    if (tstl.isVariableDeclarationStatement(bodyNode) && bodyNode.right) {
                                        if (tstl.isFunctionExpression(bodyNode.right[0])) {
                                            funcExpr = bodyNode.right[0];
                                        }
                                    }
                                    paramNames.push.apply(paramNames, bodyArg.parameters.map(function (p) { return p.name.getText(); }));
                                }
                                for (var _i = 0, result_1 = result; _i < result_1.length; _i++) {
                                    var stmt = result_1[_i];
                                    if (tstl.isExpressionStatement(stmt)) {
                                        var callExpr = stmt.expression;
                                        if (tstl.isCallExpression(callExpr) && tstl.isIdentifier(callExpr.expression) &&
                                            callExpr.expression.text === expr.expression.text) {
                                            var paramCount = callExpr.params.length;
                                            if (paramCount > 0) {
                                                var body = callExpr.params[0];
                                                if (tstl.isIdentifier(body)) {
                                                    body = funcExpr;
                                                }
                                                if (body && tstl.isFunctionExpression(body)) {
                                                    var statements = body.body.statements;
                                                    for (var index = 1; index < paramCount; ++index) { // Skip the body parameter.
                                                        var param = callExpr.params[index];
                                                        statements.unshift(tstl.createVariableDeclarationStatement([tstl.createIdentifier(paramNames[index - 1])], [param]));
                                                    }
                                                    return tstl.createDoStatement(statements, node);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            context.diagnostics.push(expectedFunctionExpressionInInline(node));
                            break;
                        }
                        case "__label": {
                            if (context.luaTarget === tstl.LuaTarget.Lua50 || context.luaTarget === tstl.LuaTarget.Lua51) {
                                context.diagnostics.push(unsupportedForTarget(node, "label", context.luaTarget));
                                break;
                            }
                            if (expr.arguments.length === 1 && ts.isStringLiteral(expr.arguments[0])) {
                                return tstl.createLabelStatement(expr.arguments[0].text, node);
                            }
                            context.diagnostics.push(expectedStringLiteralInLabel(node));
                            break;
                        }
                        case "__typedparams": {
                            // TODO: Consider supporting any depth within function
                            if (ts.isBlock(node.parent) && ts.isFunctionLike(node.parent.parent) && expr.arguments.length === 1) {
                                var typedParams = [];
                                for (var _g = 0, _h = node.parent.parent.parameters; _g < _h.length; _g++) {
                                    var param = _h[_g];
                                    // /*parameter name*/string, /*full type*/string, /*dotDotDotToken*/boolean, /*questionToken*/boolean, /*type*/string, /*initializer*/string?
                                    var paramEntry = [
                                        tstl.createStringLiteral(param.name.getText()),
                                        tstl.createStringLiteral("".concat((_b = (_a = param.dotDotDotToken) === null || _a === void 0 ? void 0 : _a.getText()) !== null && _b !== void 0 ? _b : "").concat((_d = (_c = param.type) === null || _c === void 0 ? void 0 : _c.getText()) !== null && _d !== void 0 ? _d : "any").concat(param.questionToken ? "?" : "")),
                                        tstl.createBooleanLiteral(param.dotDotDotToken ? true : false),
                                        tstl.createBooleanLiteral(param.questionToken ? true : false),
                                        tstl.createStringLiteral((_f = (_e = param.type) === null || _e === void 0 ? void 0 : _e.getText()) !== null && _f !== void 0 ? _f : "any")
                                    ];
                                    if (param.initializer) {
                                        paramEntry.push(tstl.createStringLiteral(param.initializer.getText()));
                                    }
                                    typedParams.push(tstl.createTableExpression(__spreadArray([], paramEntry.map(function (e) { return tstl.createTableFieldExpression(e); }), true)));
                                }
                                for (var _j = 0, result_2 = result; _j < result_2.length; _j++) {
                                    var stmt = result_2[_j];
                                    if (tstl.isExpressionStatement(stmt)) {
                                        var callExpr = stmt.expression;
                                        if (tstl.isCallExpression(callExpr) && tstl.isIdentifier(callExpr.expression) &&
                                            callExpr.expression.text === expr.expression.text && callExpr.params.length === 1) {
                                            return tstl.createExpressionStatement(tstl.createCallExpression(callExpr.params[0], typedParams), node);
                                        }
                                    }
                                }
                            }
                            context.diagnostics.push(typedParamsUsedOutsideOfFunction(node));
                            break;
                        }
                    }
                }
            }
            return result;
        },
        _a[ts.SyntaxKind.ForOfStatement] = function (node, context) {
            var _a;
            var result = context.superTransformStatements(node);
            var expr = node.expression;
            if (ts.isCallExpression(expr) && ts.isIdentifier(expr.expression) && ts.isBlock(node.statement)) {
                switch (expr.expression.text) {
                    case "__methodsof": {
                        if (expr.typeArguments && expr.typeArguments.length === 1) {
                            var typeArg = expr.typeArguments[0];
                            if (ts.isTypeReferenceNode(typeArg)) {
                                var typeInfo = context.checker.getTypeAtLocation(typeArg); // Thanks Perry 😎
                                if (typeInfo.isClass()) {
                                    var escapedName = typeInfo.symbol.escapedName.toString();
                                    for (var _i = 0, result_3 = result; _i < result_3.length; _i++) {
                                        var stmt = result_3[_i];
                                        if (tstl.isForInStatement(stmt) && stmt.names.length === 2) {
                                            stmt.expressions.splice(0);
                                            stmt.expressions.push(tstl.createIdentifier("next"), tstl.createIdentifier("".concat(escapedName, ".prototype")));
                                            stmt.body.statements.push(tstl.createIfStatement(tstl.createBinaryExpression(
                                            // Skip non functions
                                            tstl.createBinaryExpression(tstl.createCallExpression(tstl.createIdentifier("type"), [stmt.names[1]]), tstl.createStringLiteral("function"), tstl.SyntaxKind.EqualityOperator), 
                                            // Skip metamethods (and constructor)
                                            tstl.createBinaryExpression(tstl.createCallExpression(tstl.createIdentifier("string.sub"), [stmt.names[0], tstl.createNumericLiteral(1), tstl.createNumericLiteral(2)]), tstl.createStringLiteral("__"), tstl.SyntaxKind.InequalityOperator), tstl.SyntaxKind.AndOperator), tstl.createBlock(stmt.body.statements.splice(0))));
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                        context.diagnostics.push(expectedClassTypeNameInMethodsOf(node));
                        break;
                    }
                    case "__next": {
                        for (var _b = 0, result_4 = result; _b < result_4.length; _b++) {
                            var stmt = result_4[_b];
                            if (tstl.isForInStatement(stmt)) {
                                var spliced = stmt.expressions.splice(0);
                                if (spliced.length === 1) {
                                    var callExpr = spliced[0];
                                    if (tstl.isCallExpression(callExpr)) {
                                        (_a = stmt.expressions).push.apply(_a, __spreadArray([tstl.createIdentifier("next")], callExpr.params, false));
                                        continue;
                                    }
                                }
                                context.diagnostics.push(expectedAnArgumentInNext(node));
                                break;
                            }
                        }
                        break;
                    }
                    case "__prototypeof": { // Stripped down version of __methodsof
                        if (expr.typeArguments && expr.typeArguments.length === 1) {
                            var typeArg = expr.typeArguments[0];
                            if (ts.isTypeReferenceNode(typeArg)) {
                                var typeInfo = context.checker.getTypeAtLocation(typeArg); // Thanks Perry 😎
                                if (typeInfo.isClass()) {
                                    var escapedName = typeInfo.symbol.escapedName.toString();
                                    for (var _c = 0, result_5 = result; _c < result_5.length; _c++) {
                                        var stmt = result_5[_c];
                                        if (tstl.isForInStatement(stmt)) {
                                            stmt.expressions.splice(0);
                                            stmt.expressions.push(tstl.createIdentifier("next"), tstl.createIdentifier("".concat(escapedName, ".prototype")));
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                        context.diagnostics.push(expectedClassTypeNameInPrototypeOf(node));
                        break;
                    }
                }
            }
            return result;
        },
        _a[ts.SyntaxKind.ContinueStatement] = function (node, context) {
            // FIXME: Custom tsconfig option check doesn't work (despite being specified in the tsconfig file)
            //const luaContinueSupport = (<ts.CompilerOptions & { luaContinueSupport?: boolean; }>context.program.getCompilerOptions()).luaContinueSupport; // context.options.luaContinueSupport
            var luaContinueSupport = false; // Change this to true at your own peril (if your target Lua environment supports continue statement as-is).
            if (luaContinueSupport) {
                return tstl.createExpressionStatement(tstl.createIdentifier("continue", node), node);
            }
            var result = context.superTransformStatements(node);
            return result;
        },
        _a)
};
exports["default"] = plugin;
