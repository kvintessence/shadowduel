local utility = require("code/utility")

tests = {}

function tests:weakReference()
    local value = "value"
    local weakReference = utility.createWeakRef(value)

    assert(weakReference() == "value", "Can't get weak reference value.")

    value = nil
    collectgarbage("collect")

    assert(weakReference() == nil, "Weak reference is still alive after object destruction")
end

return tests
