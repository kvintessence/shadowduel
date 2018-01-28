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

function tests.areEqual()
    local stringValue1 = "value"
    local stringValue2 = "value"
    local stringValue3 = "other value"

    assert(utility.areEqual(stringValue1, stringValue1))
    assert(utility.areEqual(stringValue1, stringValue2))
    assert(not utility.areEqual(stringValue1, stringValue3))

    local tableValue1 = {}
    local tableValue2 = {}
    local tableValue3 = { 1, 2, 3 }
    local tableValue4 = { 1, 2, 3 }
    local tableValue5 = { 1 }

    assert(utility.areEqual(tableValue1, tableValue1))
    assert(utility.areEqual(tableValue1, tableValue2))
    assert(not utility.areEqual(stringValue1, tableValue1))
    assert(not utility.areEqual(tableValue1, tableValue3))
    assert(utility.areEqual(tableValue3, tableValue3))
    assert(utility.areEqual(tableValue3, tableValue4))
    assert(not utility.areEqual(tableValue4, tableValue5))

    local multiTableValue1 = { 1, { 1, 2, 3 } }
    local multiTableValue2 = { 1, { 1, 2, 3 } }
    local multiTableValue3 = { 1, { 1 } }

    assert(utility.areEqual(multiTableValue1, multiTableValue1))
    assert(utility.areEqual(multiTableValue1, multiTableValue2))
    assert(not utility.areEqual(multiTableValue1, tableValue1))
    assert(not utility.areEqual(multiTableValue1, tableValue3))
    assert(not utility.areEqual(multiTableValue1, stringValue1))
    assert(not utility.areEqual(multiTableValue1, multiTableValue3))
end

function tests.shallowCopy()
    local oldValue = { x = 0, table = { y = 0 } }
    local newValue = utility.shallowCopy(oldValue)

    assert(utility.areEqual(oldValue, newValue))

    newValue.table.y = 1

    assert(utility.areEqual(oldValue, newValue))

    newValue.x = 1

    assert(not utility.areEqual(oldValue, newValue))
end

function tests.deepCopy()
    local oldValue = { x = 0, table = { y = 0 } }
    local newValue = utility.deepCopy(oldValue)

    assert(utility.areEqual(oldValue, newValue))

    newValue.table.y = 1

    assert(not utility.areEqual(oldValue, newValue))

    newValue = utility.deepCopy(oldValue)
    newValue.x = 1

    assert(not utility.areEqual(oldValue, newValue))
end

return tests
