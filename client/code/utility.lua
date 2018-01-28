local utility = {}

local __weakReferenceMetaTable__ = { __mode = "v", __call = function(self)
    if self.wrapper then
        return self.wrapper.value
    else
        return nil
    end
end }

function utility.createWeakRef(object)
    return setmetatable({ wrapper = { value = object } }, __weakReferenceMetaTable__)
end

function utility.silenceUnused(object)
end

return utility
