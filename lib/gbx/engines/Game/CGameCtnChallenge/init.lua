local CGameCtnChallenge = {
    ['002'] = require 'lib.gbx.engines.Game.CGameCtnChallenge.TmDesc',
    ['003'] = require 'lib.gbx.engines.Game.CGameCtnChallenge.Common',
    ['004'] = require 'lib.gbx.engines.Game.CGameCtnChallenge.Version',
    ['005'] = require 'lib.gbx.engines.Game.CGameCtnChallenge.Community',
    ['007'] = require 'lib.gbx.engines.Game.CGameCtnChallenge.Thumbnail'
}

local unimplemented = {
    __index = function()
        return require 'lib.gbx.engines.Undefined.Undefined.Undefined'
    end
}

setmetatable(CGameCtnChallenge, unimplemented)

return CGameCtnChallenge
