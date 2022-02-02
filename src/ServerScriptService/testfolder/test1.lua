local test1 = {}

function test1.DramfInit(Core)
    print("hello world")
    print(Core)
    task.wait(3)
    Core.TestBadFunction = "lol"
    Core.TestFunction = function()
        print("yooo")
    end
    Core.TestFunction2 = function()
        print("woah cross script flushed")
    end
    Core.Shared.AmGaming = true
end

return test1