local test2 = {}

function test2.DramfInit(Core)
    local yo = Core:GetLibrary("yo")
    yo.helloWorld = function()
        print("libraries working")
    end
end

return test2