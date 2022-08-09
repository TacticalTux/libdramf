-- This module acts as an example global module.
local ExampleGlobalModule = {}

function ExampleGlobalModule.DramfInit(Core)
	Core.ExampleGlobalModuleFunction = function()
		print("This is an example global Dramf function.")
	end
end

return ExampleGlobalModule