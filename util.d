module util;

bool isIdentifierStart(char c)
{
    return (c >= 'a' && c <= 'z') ||
           (c >= 'A' && c <= 'Z') ||
           c == '_';
}
bool isIdentifierChar(char c)
{
    return isIdentifierStart(c) ||
        (c >= '0' && c <= '9');
}
bool isWhitespace(char c)
{
    return c == ' ' || c == '\r' || c == '\n' || c == '\v';
}


// Take a list of arguments and reformats it with only the names
@property auto formatArgNamesOnly(string args)
{
    struct Formatter
    {
        string args;
        void toString(scope void delegate(const(char)[]) sink) const
        {
            if(args.length == 0)
            {
                return;
            }

            size_t next = 0;
            for(;;)
            {
                if(next == args.length)
                {
                    assert(0, "invalid args format");
                }
                char c = args[next];
                if(!isIdentifierStart(c))
                {
                    next++;
                }
                else
                {
                    auto idStart = next;
                    for(;;)
                    {
                        next++;
                        if(next == args.length)
                        {
                            sink(args[idStart..next]);
                            return;
                        }
                        c = args[next];
                        if(!isIdentifierChar(c))
                        {
                            break;
                        }
                    }
                    auto idLimit = next;
                    for(; isWhitespace(c); )
                    {
                        next++;
                        if(next == args.length)
                        {
                            sink(args[idStart..idLimit]);
                            return;
                        }
                        c = args[next];
                    }
                    if(c == ',')
                    {
                        sink(args[idStart..idLimit]);
                        sink(", ");
                    }
                }
            }
        }
    }
    return Formatter(args);
}
unittest
{
    assert("msg" == format("%s", "string msg".formatArgNamesOnly));
    assert("msg, a" == format("%s", "string msg, int a".formatArgNamesOnly));
    assert("abcd, efgh" == format("%s", "Template!0 abcd, Another!(1, 2, \"3\") efgh".formatArgNamesOnly));
}
