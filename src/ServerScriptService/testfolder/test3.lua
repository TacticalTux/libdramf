local test3 = {}

function test3.DramfInit(Core)
    task.wait(10)
    print("test3 is adding a library function.")
    local OurLibrary = Core:GetLibrary("TestLibrary")
    OurLibrary.helloWorld = function()
        print("Libraries working! This one was created by test3.")
        print("Printing global from test2.")
        print(Core:GetSharedValue("TestSharedValue"))
    end
end

return test3