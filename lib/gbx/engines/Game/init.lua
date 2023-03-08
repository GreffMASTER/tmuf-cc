local Game = {
    ['043'] = require 'lib.gbx.engines.Game.CGameCtnChallenge',
    ['003'] = require 'lib.gbx.engines.Game.CGameCtnChallenge'
}

local unimplemented = {
    __index = function()
        return require 'lib.gbx.engines.Undefined.Undefined'
    end
}

setmetatable(Game, unimplemented)

return Game
