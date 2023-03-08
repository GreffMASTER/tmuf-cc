local Undefined = {}

local unimplemented = {
    __index = function()
        return require 'lib.gbx.engines.Undefined.Undefined'
    end
}

setmetatable(Undefined,unimplemented)

return Undefined