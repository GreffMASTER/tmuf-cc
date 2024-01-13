_GState = require 'stateman'

_GLibs = {}
_GFonts = {}
_GVer = 'a1.3'

local l = love

function love.load(args)
    -- Load libraries
    _GLibs.gmui = require 'lib.gmui'
    _GLibs.gbx = require 'lib.gbx'
    -- Setup fonts
    _GFonts[12] = love.graphics.newFont(10)
    _GFonts[24] = love.graphics.newFont(24)
    _GFonts[28] = love.graphics.newFont(28)
    -- Load and set states
    _GState.addState(require 'states.mainstate', 'mainstate')
    _GState.setState('mainstate')
end

l.draw          = _GState.draw
l.filedropped   = _GState.filedropped
l.keypressed    = _GState.keypressed
l.keyreleased   = _GState.keyreleased
l.mousemoved    = _GState.mousemoved
l.mousepressed  = _GState.mousepressed
l.mousereleased = _GState.mousereleased
l.textinput     = _GState.textinput
l.update        = _GState.update
