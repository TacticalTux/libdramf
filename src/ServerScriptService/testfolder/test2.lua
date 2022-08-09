local test2 = {}

function test2.DramfInit(Core)
    task.wait(5)
    print("Hello, world! This is test2! We are running after waiting for 5 seconds.")
    Core.TestBadFunction = "ThisIsNotAFunction"
    Core.TestFunction = function()
        print("TestFunction")
    end
    Core.TestFunction2 = function()
        print("TestFunction2")
    end
    Core.Shared.TestSharedValue = true

    print("test2 is now going to error testing verbose error handling.")
    Core:GetParentSharedValue()
end

return test2