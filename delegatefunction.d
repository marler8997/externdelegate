module delegatefunction;

import std.stdio;
import std.format;
import util;

mixin template delegateFunctionImpl(string functionName, string templateArguments, string contextType, string contextVarName, string arguments, string code)
{
    private import util : formatArgNamesOnly;
    enum MixinCode = `struct ` ~ functionName ~ `
{
    private auto memberFunction` ~ templateArguments ~ `(` ~ arguments ~ `)
    {
        auto ` ~ contextVarName ~ ` = cast(` ~ contextType ~ `)&this;
` ~ code ~ `
    }
    pragma(inline) static auto opCall` ~ templateArguments ~ `(` ~ contextType ~ ` ` ~ contextVarName ~
        ( (arguments.length == 0) ? "" : ", ") ~ arguments ~ `)
    {
        return (cast(` ~ functionName ~ `*)` ~ contextVarName ~ `).memberFunction(` ~
            format("%s", arguments.formatArgNamesOnly) ~ `);
    }
    // NOTE: this doesn't quite work yet if there are template parameters
    static auto createDelegate` ~ templateArguments ~ `(` ~ contextType ~ ` ` ~ contextVarName ~ `)
    {
        ` ~ functionName ~ ` __dummyWrapper__;
        auto dg = &__dummyWrapper__.memberFunction;
        dg.ptr = cast(void*)` ~ contextVarName ~ `;
        return dg;
    }
}
`;
   // pragma(msg, MixinCode);
    mixin(MixinCode);
}

//
//
/+
mixin template delegateFunction(string func)
{
    import util;
    enum StartFunctionName = findFunctionNameStart(func);
    enum EndFunctionName   = (StartFunctionName + 1) + findEndOfIdentifier(func[StartFunctionName + 1..$]);
    enum StartFirstArg     = (EndFunctionName      ) + findChar(func[EndFunctionName..$], '(') + 1;
    enum FirstArgComma     = (StartFirstArg        ) + findChar(func[StartFirstArg..$], ',');

    import std.conv : to;
    pragma(msg, "(" ~ StartFunctionName.to!string ~ ", " ~
        EndFunctionName.to!string ~ ", " ~
        StartFirstArg.to!string ~ ", " ~
        FirstArgComma.to!string ~ ")");


    enum FunctionName = func[StartFunctionName..EndFunctionName];

    enum MixinCode = `struct ` ~ FunctionName ~ `
{
  ` ~ func[0..StartFunctionName] ~ `call` ~ func[EndFunctionName..StartFirstArg] ~ func[FirstArgComma + 1..$] ~ `

}`;
    pragma(msg, MixinCode);
    mixin(MixinCode);

}
+/

auto skipWhitespace(string str, size_t index)
{
    for(;;index++)
    {
        if(index >= str.length)
        {
            assert(0);
        }
        if(!isWhitespace(str[index]))
        {
            return index;
        }
    }
}
auto untilWhitespace(string str, size_t index)
{
    for(;;index++)
    {
        if(index >= str.length)
        {
            assert(0);
        }
        if(isWhitespace(str[index]))
        {
            return index;
        }
    }
}

auto findFunctionNameStart(string func)
{
    // dumb implementation right now
    size_t index = 0;

    index = func.skipWhitespace(index);
    index++;
    index = func.untilWhitespace(index);
    index++;
    index = func.skipWhitespace(index);

    return index;
}
auto findEndOfIdentifier(string str)
{
    size_t i;
    for(i = 0; i < str.length; i++)
    {
        if(!isIdentifierChar(str[i]))
        {
            break;
        }
    }
    return i;
}
auto findChar(string str, char c)
{
    for(size_t i = 0; ; i++)
    {
        if(i >= str.length)
        {
            assert(0);
        }
        if(str[i] == c)
        {
            return i;
        }
    }
}