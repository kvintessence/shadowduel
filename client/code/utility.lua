local utility = {}

local __weakReferenceMetaTable__ = {
    __mode = "v",
    __call = function(self)
        if self.wrapper then
            return self.wrapper.value
        else
            return nil
        end
    end
}

function utility.createWeakRef(object)
    return setmetatable({ wrapper = { value = object } }, __weakReferenceMetaTable__)
end

function utility.silenceUnused(object)
    object = object
end

function utility.areEqual(first, second)
    local firstType = type(first)
    local secondType = type(second)
    if firstType ~= secondType then return false end

    -- non-table types can be directly compared
    if firstType ~= 'table' then return first == second end

    -- variables can reference the same table object
    if first == second then return true end

    -- as well as tables which have the meta method `__eq`
    local firstMetaTable = getmetatable(first)
    if firstMetaTable and firstMetaTable.__eq then return first == second end

    for firstKey, firstValue in pairs(first) do
        local secondValue = second[firstKey]
        if secondValue == nil or not utility.areEqual(firstValue, secondValue) then return false end
    end

    for secondKey, _ in pairs(second) do
        local firstValue = first[secondKey]
        if firstValue == nil then return false end
    end

    return true
end

function utility.shallowCopy(valueToCopy)
    if type(valueToCopy) ~= "table" then return valueToCopy end

    local metaTable = getmetatable(valueToCopy)
    local newCopy = {}

    for key, value in pairs(valueToCopy) do newCopy[key] = value end
    setmetatable(newCopy, metaTable)

    return newCopy
end

function utility.deepCopy(valueToCopy)
    if type(valueToCopy) ~= "table" then return valueToCopy end

    local metaTable = getmetatable(valueToCopy)
    local newCopy = {}

    for key, value in pairs(valueToCopy) do
        if type(value) == "table" then
            newCopy[key] = utility.deepCopy(value)
        else
            newCopy[key] = value
        end
    end

    setmetatable(newCopy, metaTable)
    return newCopy
end

function utility.appendToArray(array, value)
    array[#array + 1] = value
    return array
end

function utility.removeFromArray(array, valueToBeRemove)
    for key, value in pairs(array) do
        if value == valueToBeRemove then
            array[key] = nil
            return array
        end
    end

    return array
end

return utility
