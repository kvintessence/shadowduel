local class = require("lib/middleclass")

local component = require("code/ecs/component")

local module = {}

module.Entity = class('ecs/Entity')

function module.Entity:initialize()
    self.__components__ = {}
end

function module.Entity:add(newComponent, ...)
    if newComponent == nil then return end

    assert(newComponent:isInstanceOf(component.Component), "Trying to add a non-component object to entity.")
    self.__components__[newComponent] = true  -- using table as a set

    self.add(unpack(arg))
end

function module.Entity:remove(someComponent, ...)
    if not someComponent then return end

    self.__components__[someComponent] = nil  -- using table as a set

    self.remove(unpack(arg))
end

function module.Entity:get(componentClass)
    local componentName = componentClass.name

    for localComponent, _ in pairs(self.__components__) do
        if localComponent.class.name == componentName then return localComponent end
    end

    return nil
end

function module.Entity:has(componentClass, ...)
    if componentClass == nil then return true end

    if self:get(componentClass) == nil then
        return false
    else
        return self:has(...)
    end
end

function module.Entity:all()
    local componentsList = {}

    for localComponent, _ in pairs(self.__components__) do
        table.insert(componentsList, localComponent)
    end

    return componentsList
end

return module
