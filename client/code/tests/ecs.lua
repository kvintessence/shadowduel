local class = require("lib/middleclass")

local utility = require("code/utility")
local ecs = require("code/ecs/ecs")

local tests = {}

-- utility structures

local TestComponent1 = class("TestComponent1", ecs.Component)
local TestComponent2 = class("TestComponent2", ecs.Component)
local NotAComponent = class("NotAComponent")

local TestSystem1 = class("TestSystem1", ecs.System)

function TestSystem1:componentTypes()
    return { TestComponent1 }
end

function TestSystem1:update(entities, delta)
    for _, entity in ipairs(entities) do
        entity:get(TestComponent1).test1 = true
    end
end

local TestSystem12 = class("TestSystem12", ecs.System)

function TestSystem12:componentTypes()
    return { TestComponent1, TestComponent2 }
end

function TestSystem12:update(entities, delta)
    for _, entity in ipairs(entities) do
        entity:get(TestComponent1).test2 = true
        entity:get(TestComponent2).test2 = true
    end
end

-- tests

function tests.invalidComponentAddition()
    local entity = ecs.Entity:new()
    local invalidComponent = NotAComponent:new()
    assert(not pcall(function()
        entity:add(invalidComponent)
    end), "Invalid component can't be added.")
end

function tests.hasComponent()
    local entity = ecs.Entity:new()

    assert(not entity:has(TestComponent1), "This entity should be empty.")
    assert(not entity:has(TestComponent2), "This entity should be empty.")
    assert(not entity:has(TestComponent1, TestComponent2), "This entity should be empty.")

    entity:add(TestComponent1:new())

    assert(entity:has(TestComponent1), "This entity should have `TestComponent1` component.")
    assert(not entity:has(TestComponent2), "This entity should have only `TestComponent1` component.")
    assert(not entity:has(TestComponent1, TestComponent2), "This entity should have only `TestComponent1` component.")

    entity:add(TestComponent2:new())

    assert(entity:has(TestComponent1), "This entity should have both test components.")
    assert(entity:has(TestComponent2), "This entity should have both test components.")
    assert(entity:has(TestComponent1, TestComponent2), "This entity should have both test components.")
end

function tests.getComponent()
    local entity = ecs.Entity:new()
    local component = TestComponent1:new()

    assert(entity:get(TestComponent1) == nil, "There should be no component.")
    entity:add(component)
    assert(entity:get(TestComponent1) == component, "We just added this component, it should be there.")
end

function tests.getAllComponents()
    local entity = ecs.Entity:new()
    local component1 = TestComponent1:new()
    local component2 = TestComponent2:new()

    assert(utility.areEqual(entity:all(), {}), "This entity should have no components yet.")

    entity:add(component1)
    assert(utility.areEqual(entity:all(), { component1 }), "This entity should have only first component.")

    entity:add(component2)
    assert(utility.areEqual(entity:all(), { component1, component2 }) or utility.areEqual(entity:all(), { component2, component1 }), "This entity should have both components.")

    entity:remove(component1)
    assert(utility.areEqual(entity:all(), { component2 }), "This entity should have only second component.")
end

function tests.entitiesWithComponents()
    local entity1 = ecs.Entity:new()
    entity1:add(TestComponent1:new())

    local entity12 = ecs.Entity:new()
    entity12:add(TestComponent1:new())
    entity12:add(TestComponent2:new())

    assert(utility.areEqual({}, ecs.default:entitiesWithComponent(TestComponent1)))
    assert(utility.areEqual({}, ecs.default:entitiesWithComponent(TestComponent2)))
    assert(utility.areEqual({}, ecs.default:entitiesWithComponents({ TestComponent1, TestComponent2 })))

    ecs.default:addEntity(entity1)

    assert(utility.areEqual({ entity1 }, ecs.default:entitiesWithComponent(TestComponent1)))
    assert(utility.areEqual({}, ecs.default:entitiesWithComponent(TestComponent2)))
    assert(utility.areEqual({}, ecs.default:entitiesWithComponents({ TestComponent1, TestComponent2 })))

    ecs.default:addEntity(entity12)

    local withComponent1 = ecs.default:entitiesWithComponent(TestComponent1)
    assert(utility.areEqual({ entity1, entity12 }, withComponent1) or utility.areEqual({ entity12, entity1 }, withComponent1))
    assert(utility.areEqual({ entity12 }, ecs.default:entitiesWithComponent(TestComponent2)))
    assert(utility.areEqual({ entity12 }, ecs.default:entitiesWithComponents({ TestComponent1, TestComponent2 })))

    ecs.default:removeEntity(entity1)

    assert(utility.areEqual({ entity12 }, ecs.default:entitiesWithComponent(TestComponent1)))
    assert(utility.areEqual({ entity12 }, ecs.default:entitiesWithComponent(TestComponent2)))
    assert(utility.areEqual({ entity12 }, ecs.default:entitiesWithComponents({ TestComponent1, TestComponent2 })))

    ecs.default:removeEntity(entity12)

    assert(utility.areEqual({}, ecs.default:entitiesWithComponent(TestComponent1)))
    assert(utility.areEqual({}, ecs.default:entitiesWithComponent(TestComponent2)))
    assert(utility.areEqual({}, ecs.default:entitiesWithComponents({ TestComponent1, TestComponent2 })))
end

return tests
