local DramfCore = {}
DramfCore.ProtectedFunctions = {}

-- type checking stuff
type TableOfFunctions = {(...any?) -> (...any?)}

-- libraries are special dramfs inside of dramfs
function DramfCore.ProtectedFunctions:GetLibrary(LibraryName: string): {}
	if self.__Libraries[LibraryName] ~= nil then
		return self.__Libraries[LibraryName]
	else
		local NewLibraryDramf = DramfCore.ProtectedFunctions.NewDramfCore({}, self.__Shared)
		self.__Libraries[LibraryName] = NewLibraryDramf
		return NewLibraryDramf
	end
end

-- local func for waiting for the value in the table
-- this could use a bindable instead of waiting for efficiency, but it probably isn't needed
function DramfCore.ProtectedFunctions.WaitForValueInTable(Table : table, Index : any, Timeout : number): any
	if Timeout == nil then
		Timeout = math.huge
	end
	local CallRunTime = 0
	local WarnTime = 15
	while CallRunTime <= Timeout do
		CallRunTime += 0.1
		local Value = rawget(Table, Index)
		if Value then
			return Value
		else
			task.wait(0.1)
		end

		if WarnTime - CallRunTime <= 0 then
			warn("Failing to get", Index, "from table.")
			warn(debug.traceback("Traceback:"))
			WarnTime *= 2
		end
	end
	warn("Waiting for", Index, "has failed. Returning nil.")
	warn(debug.traceback("Traceback:"))
	print(Table)
end

-- internal functions
function DramfCore.ProtectedFunctions:LoadFunctions(Sources: TableOfFunctions): {}
	-- call our sources if they are available to run our draminit functions
	for _, Source in pairs(Sources) do
		task.spawn(function()
			Source(self)
		end)
	end
end

function DramfCore.ProtectedFunctions:GetSharedValue(Index: any, Timeout: number): any
	assert(Index ~= nil, "No index for GetParentSharedValue call. Traceback:")
	return DramfCore.ProtectedFunctions.WaitForValueInTable(self.__Shared, Index, Timeout)
end

function DramfCore.ProtectedFunctions:GetParentSharedValue(Index: any, Timeout: number): any
	assert(Index ~= nil, "No index for GetParentSharedValue call. Traceback:")
	return DramfCore.ProtectedFunctions.WaitForValueInTable(self.__ParentShared, Index, Timeout)
end

function DramfCore.ProtectedFunctions.NewDramfCore(Sources: TableOfFunctions, ParentShared: table | nil): {} -- Constructor, isn't meant to be used externally.
	local self = {}
	-- Establish our variables
	self.__Functions = {}
	self.__Libraries = {} -- Libraries are Dramf(s) inside of Dramf(s).
	self.__Globals = {}
	self.__Shared = {}
	self.__ParentShared = ParentShared or {}

	-- Set our metatable for DramfCore
	setmetatable(self, {
		-- Calls to DramfCore should only take Functions and ProtectedFunctions
		__index = function(_, Index)
			if DramfCore.ProtectedFunctions[Index] ~= nil then
				return DramfCore.ProtectedFunctions[Index]
			elseif self.__Functions[Index] ~= nil then
				-- if it's not a ProtectedFunction, see if it exists as a normal one. if not, return our proxy to yield
				return self.__Functions[Index]
			elseif Index == "Shared" then -- shared table refs
				return self.__Shared
		   	elseif Index == "ParentShared" then
				return self.__ParentShared
			else
				return function(...)
					return DramfCore.ProtectedFunctions.WaitForValueInTable(self.__Functions, Index)(...)
				end
			end
		end,
		-- ensure we are inserting a function, and if so, throw it in the thing, as well as other stuff
		__newindex = function(_, Index, Value)
			if Index == "Shared" or Index == "ParentShared" then
				warn("Blocking inserting", Index, "because index is used to refer to the Dramf's shared/parentshared table.")
				warn(debug.traceback("Traceback:"))
			elseif typeof(Value) ~= "function" then
				warn("Blocking inserting", Value, "at", Index, "because value is not a function.")
				warn(debug.traceback("Traceback:"))
			elseif DramfCore.ProtectedFunctions[Index] ~= nil then
				warn("Blocking inserting", Value, "at", Index, "because index shares a name with a ProtectedFunction.")
				warn(debug.traceback("Traceback:"))
			else
				self.__Functions[Index] = Value
			end
		end
	})

	-- finally, call our sources if they are available to run our draminit functions
	self:LoadFunctions(Sources)

	return self
end

-- set the metatable to point indexes to the protected func folder
setmetatable(DramfCore, {
	__index = DramfCore.ProtectedFunctions
})

return DramfCore