--[[
DRAMF (pronounced "Dram-ph", though other versions are acceptable) stands for Dependency Respecting Asynchronous Module Framework.

What it does is very simple - it asynchronously loads modules, either provided by hand by a script, or by having modules with a defined key that points to a function.
These modules can then write functions to their DRAMF instances, and then other modules that are a part of that instance can call those modules. This is especially
useful when dealing with cross dependencies and such in systems, but is otherwise a neat way to organize stuff.

In total, it could be considered to be a mix between a normal dependency injecting framework and a dependency flattener. Not really sure exactly how to describe it normally.
(Feel free to make a PR if you can explain the structure better than I can!)

Best of all, it keeps it short and simple.

The libdramf module only provides one function:
	:GetDramf(
		-- This function gets a DRAMF instance that can be used across script.

		Sources (table, function, instance, or nil)
			-- Defines what functions are to be added to the DRAMF instance whenever it is acquired / created. Functions can either be passed as a table of functions, as a singular function,
			-- or as an instance.
			-- If an Instance is passed, all descendants of the Instance are searched (including the Instance itself) to see if they are a modulescript and if they have a function named DramfInit.
			-- Any functions that are called from a DRAMF instance will have the DRAMF instance itself passed as an argument.

		DramfName (string or nil)
			-- This can be used in order to allow GetDramf to acquire a pre-existing Dramf, if it exists, or if it doesn't, create a new one under that name.

		OverwriteOld (string or nil)
			-- Forces an overwrite, even if a Dramf already exists with the same name as defined in DramfName
	)

DRAMF instances themselves include a few functions, though the primary usage is to simply write in and out of the table.

	:GetLibrary(
		-- This function creates a DRAMF inside of a DRAMF only accessible from the original DRAMF for the sake of organization.
		-- For example, if you had a very large module that provided a large amount of functions, it may make sense to package it inside of 
		-- this pre-exisiting DRAMF.
		-- If a library with the name already exists, it will create a new one.

		LibraryName (string)
			The name of the Library being acquired.
	)

	:GetSharedValue(
		-- This function gets a value from the shared table while yielding for it for the internal timeout.
		-- See below for explanation.

		Index (any)
			Index of the value being looked for

		Timeout (number)
			A custom timeout value, where nil will be returned once the timeout has been passed.
	)

	:GetParentSharedValue(
		-- Same as above. See below for more info.

		Index (any)
			Index of the value being looked for

		Timeout (number)
			A custom timeout value, where nil will be returned once the timeout has been passed.
	)

DRAMF instances (and libraries) have two special indexes, Shared and ParentShared
Shared is a place to store general variables and the like inside of the DRAMF instance.
ParentShared is similar to the one above, but only exists in the case that it is being used from inside of a Library (see above)
The functions above can be used in order to call these tables while yielding for a specified index to exist.

GLOBAL DRAMF MODULES:
Any modules under the dramfcore module instance will be called with all newly created DRAMF instances, not including libraries. See the example included in the module.

That's it! Happy programming!
- r_aidmaster 2022
]]

return {}