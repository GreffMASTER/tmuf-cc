local engines = {
    ['03'] = require 'lib.gbx.engines.Game',
    ['24'] = require 'lib.gbx.engines.Game'
}

local unimplemented = {
    __index = function()
        return require 'lib.gbx.engines.Undefined'
    end
}

setmetatable(engines,unimplemented)

return engines
