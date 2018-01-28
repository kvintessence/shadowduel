local eventbus = require("code/eventbus")
local utility = require("code/utility")

local tests = {}

local eventName = "eventName"

function tests.globalInstanceExistence()
    assert(eventbus.default, "Global event bus instance doesn't exist.")
end

function tests.zeroEventSubscription()
    eventbus.default:post(eventName)
end

function tests.oneEventSubscription()
    local shared = { value = 0 }
    local subscription = eventbus.default:subscribe(eventName, function()
        shared.value = 1
    end)

    utility.silenceUnused(subscription)

    eventbus.default:post(eventName)

    assert(shared.value == 1, "Haven't received the event and haven't changed the value.")
end

function tests.multipleEventSubscriptions()
    local shared = { value = 0 }

    local subscription1 = eventbus.default:subscribe(eventName, function()
        shared.value = shared.value + 1
    end)
    local subscription2 = eventbus.default:subscribe(eventName, function()
        shared.value = shared.value + 1
    end)

    utility.silenceUnused(subscription1)
    utility.silenceUnused(subscription2)

    eventbus.default:post(eventName)

    assert(shared.value == 2, "Haven't received the event and haven't changed the value.")
end

function tests.eventSubscriptionDeath()
    local shared = { value = 0 }
    local subscription = eventbus.default:subscribe(eventName, function()
        shared.value = 1
    end)
    utility.silenceUnused(subscription)

    subscription = nil
    collectgarbage("collect")

    eventbus.default:post(eventName)

    assert(shared.value == 0, "Subscription is still alive after setting it to nil.")
end

return tests
