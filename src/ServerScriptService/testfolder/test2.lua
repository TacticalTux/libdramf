local test2 = {}

function test2.DramfInit(Core)
    Core.TestFunction()
    Core.NotATestFunction()
    local yolib = Core:GetLibrary("yo")
    print(yolib)
    yolib.helloWorld()
end

return test2