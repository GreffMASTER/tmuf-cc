local draw = {}

local lg = love.graphics

local g_chall = lg.newImage('states/mainstate/graphics/chall.png')
local g_chall_sel = lg.newImage('states/mainstate/graphics/chall_sel.png')
local g_done = lg.newImage('states/mainstate/graphics/done.png')
local g_flags = {
    lg.newImage('states/mainstate/graphics/flag_A.png'),
    lg.newImage('states/mainstate/graphics/flag_B.png'),
    lg.newImage('states/mainstate/graphics/flag_C.png'),
    lg.newImage('states/mainstate/graphics/flag_D.png'),
    lg.newImage('states/mainstate/graphics/flag_E.png')
}

local t_flags = {
    'White',
    'Green',
    'Blue',
    'Red',
    'Black'
}

function draw.drawButtons(hover, curflag)
    for i=1,5 do
        if i == curflag then
            lg.setColor(0.1, 0.1, 0.1, 0.80)
            lg.rectangle('fill', 0, 64+i*64, 256, 64)
            lg.setColor(1, 1, 1)
        end
        if i == hover then
            lg.setColor(0.7, 0.7, 0.7, 0.80)
            lg.rectangle('fill', 0, 64+i*64, 256, 64)
            lg.setColor(1, 1, 1)
        end
        lg.draw(g_flags[i], 0, 64+i*64, 0, 0.5, 0.5)
        lg.printf(t_flags[i], _GFonts[24], 64, 80+i*64, 192, 'left')
    end
    if hover == 6 then
        lg.setColor(0.7, 0.7, 0.7, 0.80)
        lg.rectangle('fill', 0, lg.getHeight()-64, 256, 64)
        lg.setColor(1, 1, 1)
    end
    lg.draw(g_done, 0, lg.getHeight()-64, 0, 0.5, 0.5)
end

function draw.drawChallenge(challenge, sel, x, y, s)
    sel = sel or false
    x = x or 0
    y = y or 0
    s = s or 1
    local name = challenge.userdata[2].trackname
    local thumb = nil
    if challenge.userdata[5] then
        thumb = challenge.userdata[5].thumbnail
    end
    if thumb then
        lg.draw(thumb, x+4, y+4)
    else
        lg.rectangle('fill', x+4, y+4, 120, 100)
    end
    if sel then
        lg.draw(g_chall_sel, x, y, 0, s, s)
    else
        lg.draw(g_chall, x, y, 0, s, s)
    end
    lg.setColor(0, 0, 0)
    lg.printf(name, _GFonts[24], x, y+(256-44)*s, 256, 'center', 0, s, s)
    lg.setColor(1, 1, 1)
end

return draw
