local fsb = require 'lib.fsbinary'

local Undefined = {}

local unimplemented = {
    __index = function()
        return require 'lib.gbx.engines.Undefined.Undefined.Undefined'
    end
}

setmetatable(Undefined,unimplemented)

return Undefined