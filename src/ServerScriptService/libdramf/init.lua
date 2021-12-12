local libdramf = {}
libdramf.DramfInstances = {}

-- get variables
local DramfCore = require(script:WaitForChild("dramfcore"))

-- type checking stuff
type TableOfFunctions = {(...any?) -> (...any?)}

-- used to convert instances into a table f functions
local function ConvertSourcesToFunctions(Source: Instance): {}
    local NewSources = {}
    local SourcesToSearch = Source:GetDescendants()
    table.insert(SourcesToSearch, Source)
    
    for _, Item in pairs(SourcesToSearch) do
        -- go thru all the childen, find if they are a module
        if Item:IsA("ModuleScript") then
            -- if they are a module, require them
            local Success, ModuleReturn = pcall(function()
                local SourceModule = require(Item)
                -- if it was a table, and we have a validly named func, return that
                if typeof(SourceModule) == "table" and (SourceModule["DramfInit"]) then
                    return (SourceModule.DramfInit)
                end
            end)
            -- handle the results of the pcall
            if not Success then
                warn("Failure to process module.\n", ModuleReturn)
            elseif ModuleReturn ~= nil then
                table.insert(NewSources, ModuleReturn)
            end
        end
    end

    return NewSources
end

function libdramf:GetDramf(Sources: Instance | (any?) -> (any?) | TableOfFunctions | nil, DramfName: string | nil, OverwriteOld: boolean | nil): {}
    -- make Sources into a table for ease if it's a instance
    if typeof(Sources) == "Instance" then
        Sources = ConvertSourcesToFunctions(Sources)
    elseif typeof(Sources) == "function" or typeof(Sources) == "nil" then
        Sources = {Sources}
    end

    -- Check if we should return a pre-existing Dramf
    if DramfName and (not OverwriteOld) and self.DramfInstances[DramfName] then
        local FoundInstance = self.DramfInstances[DramfName]
        FoundInstance:LoadFunctions(Sources)
        return FoundInstance
    else
        -- get new dramf
        local NewDramf = DramfCore.NewDramfCore(Sources)
        if DramfName then
            self.DramfInstances[DramfName] = NewDramf
        end
        return NewDramf
    end
end

return libdramf