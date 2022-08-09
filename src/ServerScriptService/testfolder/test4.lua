local test4 = {}

function test4.DramfInit(Core)
	print("This is test4. This should show that we are running at the same time as the other modules.")

	print("test4 is now calling the library function from test3 that does not exist yet.")
	Core:GetLibrary("TestLibrary").helloWorld()

	print("Calling a global module function, or timing out if it doesn't exist.")
	Core.ExampleGlobalModuleFunction()
end

return test4