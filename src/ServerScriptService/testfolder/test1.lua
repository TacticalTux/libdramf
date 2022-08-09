local test1 = {}

function test1.DramfInit(Core)
    print("This is test1!")
    print("Calling functions that don't exist yet.")
    Core.TestFunction()
    print("test1 is calling a library.")
    local TestLibrary = Core:GetLibrary("TestLibrary")
    TestLibrary.helloWorld()
    print("Now test1 will call a function that doesn't exist, yielding permanently.")
    Core.NotATestFunction()
    error()
end

return test1