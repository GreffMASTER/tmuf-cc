local ms = {}

local drawer = require 'states.mainstate.drawer'
local savef = require 'states.mainstate.savefunc'
local lmu = require 'lib.lmu'
local lg = love.graphics

local challenges = {
    {},
    {},
    {},
    {},
    {}
}

local g_bg = lg.newImage('states/mainstate/graphics/bg.png')

local curflag = 1
local selected = 0
local offset = 0
local true_offset = 0
local hover = 0
local anim = false

local w_save = require 'states.mainstate.savewindow'
w_save.challenges = challenges

local w_info = require 'states.mainstate.infobox'

local mpressfuncs = {
    function() curflag = 1 end,
    function() curflag = 2 end,
    function() curflag = 3 end,
    function() curflag = 4 end,
    function() curflag = 5 end,
    function()
        local ccount = 0
        for k,flag in ipairs(challenges) do
            for l,chall in ipairs(flag) do
                ccount = ccount + 1
            end
        end
        if ccount then
            w_save.shown = true
            hover = 0
        end
    end
}

function ms.load(args)
    print('mainstate loaded')
end

function ms.update(dt)
    if w_save.shown then w_save:update(dt) end
    if w_info.shown then w_info:update(dt) end
    if anim then
        if offset > true_offset then true_offset = true_offset + dt * (512+256) end
        if offset < true_offset then true_offset = true_offset - dt * (512+256) end
        if math.ceil(true_offset) == offset or math.floor(true_offset) == offset then anim = false end
        print(true_offset)
    end
    
end

function ms.draw()
    lg.setColor(1, 1, 1)
    lg.draw(g_bg)
    lg.setColor(0.15, 0.15, 0.15, 0.5)
    lg.rectangle('fill', 0, 0, 256, lg.getHeight()) -- Side menu bg
    lg.setColor(1, 1, 1)
    lg.printf('TMUF Campaign Constructor', _GFonts[28], 0, 16, 256, 'center')
    lg.printf('v.'.._GVer, _GFonts[12], 0, 64, 256, 'right')
    drawer.drawButtons(hover, curflag)
    lg.printf('Create Campaign', _GFonts[24], 64, lg.getHeight()-64, 192, 'left')
    -- Challenges
    local counter = 0
    local y = 16
    local x = 312
    if #challenges[curflag] > 0 then
        for k, chal in ipairs(challenges[curflag]) do
            if k == selected then
                drawer.drawChallenge(chal, true, x, y-true_offset, 0.5)
            else
                drawer.drawChallenge(chal, false, x, y-true_offset, 0.5)
            end
            counter = counter + 1
            x = x + 128
            if counter > 4 then
                counter = 0
                y = y + 128
                x = 312
            end
        end
    else
        lg.printf('Drag your Challenge files or LMU project file onto the window.', _GFonts[24], 256, 200, lg.getWidth()-256, 'center')
    end
    -- Save window
    if w_save.shown or w_info.shown then
        lg.setColor(0, 0, 0, 0.75)
        lg.rectangle('fill', 0, 0, lg.getWidth(), lg.getHeight())
        lg.setColor(1, 1, 1)
        if w_save.shown then w_save:draw() end
        if w_info.shown then w_info:draw() end
    end
end

function ms.keypressed(key, scancode)
    if not w_save.shown and not w_info.shown then
        if key == 'pagedown' then
            offset = offset + 512
            if offset > #challenges[curflag] * 25 then offset = offset - 512 else anim = true end
        end
        if key == 'pageup' then
            offset = offset - 512
            if offset < 0 then offset = 0 else anim = true end
        end
        if key == '1' then curflag = 1; selected = 0 end
        if key == '2' then curflag = 2; selected = 0 end
        if key == '3' then curflag = 3; selected = 0 end
        if key == '4' then curflag = 4; selected = 0 end
        if key == '5' then curflag = 5; selected = 0 end
        if key == 'delete' and selected > 0 then
            table.remove(challenges[curflag], selected)
            if selected > #challenges[curflag] then selected = #challenges[curflag] end
            if selected < 1 then selected = 1 end
            if offset > #challenges[curflag] * 25 then offset = offset - 512; anim = true end
        end
        if key == 'left' then
            selected = selected - 1
            if selected < 1 then selected = #challenges[curflag] end
        end
        if key == 'right' then
            selected = selected + 1
            if selected > #challenges[curflag] then selected = 1 end
        end
        if key == 'up' and selected > 0 then
            selected = selected - 1
            if selected < 1 then selected = 1
            else
                local chal = challenges[curflag][selected+1]
                table.remove(challenges[curflag], selected+1)
                table.insert(challenges[curflag], selected, chal)
            end
        end
        if key == 'down' and selected > 0 then
            selected = selected + 1
            if selected > #challenges[curflag] then selected = #challenges[curflag]
            else
                local chal = challenges[curflag][selected-1]
                table.remove(challenges[curflag], selected-1)
                table.insert(challenges[curflag], selected, chal)
            end
        end
        if key == 'return' then mpressfuncs[6]() end
    else
        if w_save.shown then 
            w_save:keypressed(key, scancode)
            if key == 'escape' then w_save.shown = false end
        end
        if w_info.shown then 
            w_info:keypressed(key, scancode)
            if key == 'escape' then w_info.shown = false end
        end
    end
end

function ms.keyreleased(key, scancode)
    if w_save.shown then w_save:keyreleased(key, scancode) end
    if w_info.shown then w_info:keyreleased(key, scancode) end
end

function ms.mousemoved(x, y, dx, dy, istouch)
    if w_save.shown then
        w_save:mousemoved(x, y, dx, dy, istouch)
    elseif w_info.shown then
        w_info:mousemoved(x, y, dx, dy, istouch)
    else
        if x < 256 then
            if y > 128 and y < 196 then
                hover = 1
            elseif y > 196 and y < 260 then
                hover = 2
            elseif y > 260 and y < 324 then
                hover = 3
            elseif y > 324 and y < 388 then
                hover = 4
            elseif y > 388 and y < 452 then
                hover = 5
            elseif y > lg.getHeight()-64 and y < lg.getHeight() then
                hover = 6
            else
                hover = 0
            end
        else
            hover = 0
        end
    end
end

function ms.mousepressed(x, y, button, istouch, presses)
    if w_save.shown then w_save:mousepressed(x, y, button, istouch, presses) end
    if w_info.shown then w_info:mousepressed(x, y, button, istouch, presses) end
end

function ms.mousereleased(x, y, button, istouch, presses)
    if w_save.shown then
        w_save:mousereleased(x, y, button, istouch, presses)
    elseif w_info.shown then
        w_info:mousereleased(x, y, button, istouch, presses)
    else
        if mpressfuncs[hover] then mpressfuncs[hover]() end
    end
end

function ms.filedropped(file)
    if not w_save.shown or not w_info.shown then

        local s, is_gbx = pcall(function()
            file:open('r')
            local gbx = file:read(3)
            file:close()
            if gbx == 'GBX' then return true else return false end
        end)
        if not s then
            w_info.shown = true
            return
        end

        local s, is_lmu = pcall(function()
            file:open('r')
            local gbx = file:read(3)
            file:close()
            if gbx == 'LMU' then return true else return false end
        end)
        if not s then
            w_info.shown = true
            return
        end

        if is_gbx then
            local status, challenge = pcall(_GLibs.gbx.open, file, false)
            if status and challenge then
                local cid = challenge.classid
                if savef.isAChallenge(cid) then
                    table.insert(challenges[curflag], challenge)
                else
                    w_info.children.info.text = 'Error: not a GBX challenge.'
                    w_info.shown = true
                    return
                end
            else
                if not challenge then
                    w_info.children.info.text = 'Error while reading GBX: Incompatible challenge version'
                else
                    w_info.children.info.text = 'Error while reading GBX: ' .. challenge
                end
                w_info.shown = true
                return
            end
        elseif is_lmu then
            local status, lmuproj, res = pcall(lmu.loadLMUFile, file)
            if status then
                if res then print(res) end
                if lmuproj and lmuproj.ftype and lmuproj.ftype == 'TMUF-CC' then
                    w_save.children[1].value = lmuproj.name
                    w_save.children[2].value = lmuproj.ident
                    w_save.children[3].value = lmuproj.index
                    w_save.children[4].selected = lmuproj.unlockorder
                    w_save.children[5].selected = lmuproj.camptype
                    if lmuproj.challenges then
                        challenges = lmuproj.challenges
                    end
                end
            else
                w_info.children.info.text = 'Error while reading LMU: ' .. lmuproj
                w_info.shown = true
                return
            end
        else
            w_info.children.info.text = 'Error: unsupported file format. Please load either GBX or LMU.'
            w_info.shown = true
            return
        end
    end
end

function ms.textinput(text)
    if w_save.shown then w_save:textinput(text) end
end

return ms
