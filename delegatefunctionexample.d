// rdmd delegatefunctionexample.d
module externdelegate;

import std.stdio;
import delegatefunction;

// Note: Equivalent semantics for the previous functions using DIP 1011 extern(delegate)
version(WithExternDelegate)
{
    /*extern(delegate)*/ void importantWriteln(File* file, string msg)
    {
        file.writeln("Important: ", msg);
    }
    /*extern(delegate)*/ void importantWriteln2(T...)(File* file, T args)
    {
        file.writeln("Important: ", args);
    }
}
else
{
    //
    // Instantiate 2 delegate functions using the current library implementation
    // defined in delegatefunction.d.  Note that the second function which
    // is a templateted function doesn't quite work yet.
    //
    mixin delegateFunctionImpl!("importantWriteln", "", "File", "file", "string msg",
    q{
        file.writeln("Important: ", msg);
    });
    mixin delegateFunctionImpl!("importantWriteln2", "(T...)", "File", "file", "T args",
    q{
        file.writeln("Important: ", args);
    });
    /*
    Note: it may be possible to create another library mixin template that could parse the function
          signature and pass the necessary strings to delegateFunctionImpl.  If so, then you
          could define your delegate functions like this.

    mixin delegateFunction!q{
        void importantWriteln(File* file, string msg)
        {
            file.writeln("Important: ", msg);
        }
    };
    mixin delegateFunction!q{
        void importantWriteln2(T...)(File* file, T args)
        {
            file.writeln("Important: ", args);
        }
    };
    */
}

void main()
{
    // call like normal functions
    importantWriteln(stdout, "Called like a normal function");
    importantWriteln2!(string,string)(stdout, "Template version called", " like a normal function!");

    // creating a delegate
    // note: this does not use the same syntax a member functions which can
    //       cause added complexity with templates/mixins
    {
        auto dg = importantWriteln.createDelegate(stdout);
        dg("Called as a delegate");
    }
    {
        auto dg = importantWriteln2!(string,string).createDelegate(stdout);
        dg("Hello, ", "again");
    }
}
