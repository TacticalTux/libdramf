local DramfCore = {}
DramfCore.ProtectedFunctions = {}

-- type checking stuff
type TableOfFunctions = {(...any?) -> (...any?)}

-- libraries are special dramfs inside of dramfs
function DramfCore.ProtectedFunctions:GetLibrary(LibraryName: string): {}
    if self.__Libraries[LibraryName] ~= nil then
        return self.__Libraries[LibraryName]
    else
        local NewLibraryDramf = DramfCore.ProtectedFunctions.NewDramfCore({})
        self.__Libraries[LibraryName] = NewLibraryDramf
        return NewLibraryDramf
    end
end

function DramfCore.ProtectedFunctions:GetGlobal(GlobalName: string, WaitTime: number | nil): any
    if WaitTime ~= nil and WaitTime >= 0 then
        -- if we have a wait time, call it

        local CallStartedTime = 0
        while self.__Globals[GlobalName] == nil do
            -- brrr wait and check
            task.wait(0.1)
            CallStartedTime += 0.1
            if CallStartedTime >= WaitTime then
                warn("Waiting for " .. GlobalName .. "has failed.")
            end
        end
    end

    return self.__Globals[GlobalName]
end

function DramfCore.ProtectedFunctions:SetGlobal(GlobalName: string, Value: any): nil
    self.__Globals[GlobalName] = Value
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

function DramfCore.ProtectedFunctions.NewDramfCore(Sources: TableOfFunctions): {} -- Constructor, isn't meant to be used externally.
    local self = {}
    -- Establish our variables
    self.__Functions = {}
    self.__Libraries = {} -- Libraries are Dramf(s) inside of Dramf(s).
    self.__Globals = {}

    -- Set our metatable for DramfCore
    setmetatable(self, {
        -- Calls to DramfCore should only take Functions and ProtectedFunctions
        __index = function(_, Index)
            if DramfCore.ProtectedFunctions[Index] ~= nil then
                return DramfCore.ProtectedFunctions[Index]
            elseif self.__Functions[Index] ~= nil then
                -- if it's not a ProtectedFunction, see if it exists as a normal one. if not, return our proxy to yield
                return self.__Functions[Index]
            else
                local CallingIndex = Index
                local CallStartedTime = 0 -- Used to time out
                return function(...)
                    while self.__Functions[CallingIndex] == nil do
                        -- Could be made event based or something, however, this shouldn't happen except on very startup.
                        task.wait(0.1)
                        CallStartedTime += 0.1
                        if CallStartedTime >= 5 then
                            warn("Call for", Index, "has failed. Returning nil. If you are trying to get a global or library, use GetGlobal or GetLibrary.")
                            return nil
                        end
                    end
                    -- if we got here, we didn't return nil above
                    return self.__Functions[CallingIndex](...)
                end
            end
        end,
        -- ensure we are inserting a function, and if so, throw it in the thing
        __newindex = function(_, Index, Value)
            if typeof(Value) ~= "function" then
                warn("Blocking inserting", Value, "at", Index, "because value is not a function. Please use SetGlobal if trying to set a global value.")
            elseif DramfCore.ProtectedFunctions[Index] ~= nil then
                warn("Blocking inserting", Value, "at", Index, "because index shares a name with a ProtectedFunction.")
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