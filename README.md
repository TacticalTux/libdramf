DRAMF (pronounced "Dram-ph", though other versions are acceptable) stands for Dependency Respecting Asynchronous Module Framework. It is made for ROBLOX Lua, and is the entire repository is a Rojo project.

What it does is very simple - it asynchronously loads modules, either provided by hand by a script, or by having modules with a defined key that points to a function.
These modules can then write functions to their DRAMF instances, and then other modules that are a part of that instance can call those modules. This is especially
useful when dealing with cross dependencies and such in systems, but is otherwise a neat way to organize stuff.

In total, it could be considered to be a dependency flattener.

Best of all, it's only around ~200 lines, and keeps it short and simple.

The libdramf module only provides one function:
    :GetDramf(Sources, DramfName, OverwriteOld) -- This function gets a DRAMF instance that can be used across script.

        Sources (table, function, instance, or nil)
            Defines what functions are to be added to the DRAMF instance whenever it is acquired / created. Functions can either be passed as a table of functions, as a singular function,
            or as an instance.
            If an Instance is passed, all descendants of the Instance are searched (including the Instance itself) to see if they are a modulescript and if they have a function named DramfInit.
            Any functions that are called from a DRAMF instance will have the DRAMF instance itself passed as an argument.

        DramfName (string or nil)
            This can be used in order to allow GetDramf to acquire a pre-existing Dramf, if it exists, or if it doesn't, create a new one under that name.

        OverwriteOld (string or nil)
            Forces an overwrite, even if a Dramf already exists with the same name as defined in DramfName
    

DRAMF instances have a few more functions:
    The primary usage is to simply write in and out of the table. Metatables handle the indexing and such of functions added.

    :GetLibrary(LibraryName)
        -- This function creates a DRAMF inside of a DRAMF only accessible from the original DRAMF for the sake of organization.
        -- For example, if you had a very large module that provided a large amount of functions, it may make sense to package it inside of 
        -- this pre-exisiting DRAMF.

        LibraryName (string)
            The name of the Library being acquired.
    

    :GetGlobal(GlobalName, WaitTime)
        -- GetGlobal acquires a global variable that is shared among the DRAMF instance to allow for cross-module sharing of information.
        
        GlobalName (string)
            The name of the Global being searched for.

        WaitTime (number or nil)
            If a global does not exist and a positive number is passed for WaitTime, the request will wait for the specified time before returning nil if the global does not appear.
    

    :SetGlobal(GlobalName, Value)
        -- Sets a global value

        GlobalName (string)
            The name of the Global being set

        Value (any)
            The new value of the global
    