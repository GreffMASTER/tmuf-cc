local stateman = {}

local state_meta = {
    __index = function()
        return function() end
    end,
    name = 'empty'
}

local states = {}
local curstate = {}

setmetatable(curstate, state_meta)

-- Stateman functions

function stateman.addState(statetab, statename)
    setmetatable(statetab, state_meta)
    statetab.name = statename
    states[statename] = statetab
end

function stateman.setState(statename, args)
    args = args or {}
    curstate = states[statename]
    if not curstate then error('STATEMAN: State "'..statename..'" not found!') end
    curstate.load(args)
end

-- Callback functions

function stateman.draw() curstate.draw() end
function stateman.filedropped(file) curstate.filedropped(file) end
function stateman.keypressed(key, scancode) curstate.keypressed(key, scancode) end
function stateman.keyreleased(key, scancode) curstate.keyreleased(key, scancode) end
function stateman.mousemoved(x, y, dx, dy, istouch) curstate.mousemoved(x, y, dx, dy, istouch) end
function stateman.mousepressed(x, y, button, istouch, presses) curstate.mousepressed(x, y, button, istouch, presses) end
function stateman.mousereleased(x, y, button, istouch, presses) curstate.mousereleased(x, y, button, istouch, presses) end
function stateman.textinput(text) curstate.textinput(text) end
function stateman.update(dt) curstate.update(dt) end

return stateman
