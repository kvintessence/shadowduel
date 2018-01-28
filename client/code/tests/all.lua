require("code/settings")

if not settings.debug then return end

function runTest(suitName, tests)
    for key, value in pairs(tests) do
        value()
        print(suitName .. ":".. key .. ": OK")
    end

    print ""
end

runTest("utility", require("code/tests/utility"))
runTest("eventBus", require("code/tests/eventbus"))
