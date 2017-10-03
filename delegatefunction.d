module delegatefunction;

string generateDelegateFunctionCode(string functionName, string templateArguments,
    string contextType, string contextVarName, string arguments, string code)
{
    import std.format : format;
    import util : formatArgNamesOnly;

    return `struct ` ~ functionName ~ templateArguments ~ `
{
    ` ~ contextType ~ ` ` ~ contextVarName ~ `;
    auto opCall(` ~ arguments ~ `)
    {` ~ code ~ `}
    pragma(inline) static auto opCall(ref ` ~ contextType ~ ` ` ~ contextVarName ~
        ( (arguments.length == 0) ? "" : ", ") ~ arguments ~ `)
    {
        return (cast(` ~ functionName ~ `*)&` ~ contextVarName ~ `).opCall(` ~
            format("%s", arguments.formatArgNamesOnly) ~ `);
    }
    // NOTE: this doesn't quite work yet if there are template parameters
    pragma(inline) static auto createDelegate` ~ templateArguments ~ `(ref ` ~ contextType ~ ` ` ~ contextVarName ~ `)
    {
        return &(cast(` ~ functionName ~ `*)&` ~ contextVarName ~ `).opCall;
    }
}
`;
}

mixin template delegateFunctionImpl(T...)
{
    enum Code = generateDelegateFunctionCode(T);
    pragma(msg, Code);
    mixin(Code);
}

//
// Save code that could be used to parse function signature to implement the delegateFunction
// mixin template that forward the necessary strings to delegateFunctionImpl
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
+/
