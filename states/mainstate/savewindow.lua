local savef = require 'states.mainstate.savefunc'

local function toggleme(button)
    button.value = not button.value
    if button.value then
        button.text = 'Open Folder: Yes'
    else
        button.text = 'Open Folder: No'
    end
end

local w_save = _GLibs.gmui.Window:new {
    x = 400, y = 250,
    xpos = 400, ypos = 200,
    w = 210, h = 258,
    title = 'Save Campaign',
    focused = true,
    shown = false,
    closable = true,
    children = {
        -- Textboxes
        _GLibs.gmui.Textbox:new {   -- 1
            xpos = 6, ypos = 4,
            w = 190, h = 16,
            default = 'Campaign Name'
        },
        _GLibs.gmui.Textbox:new {   -- 2
            xpos = 6, ypos = 26,
            w = 190, h = 16,
            default = 'Campaign Ident'
        },
        _GLibs.gmui.Textbox:new {   -- 3
            xpos = 6, ypos = 48,
            w = 190, h = 16,
            default = 'Campaign Index'
        },
        -- Lists
        _GLibs.gmui.List:new {      -- 4
            xpos = 6, ypos = 92,
            w = 190, h = 26,
            elements = {
                'By Row',
                'By Column'
            }
        },
        _GLibs.gmui.List:new {      -- 5
            xpos = 6, ypos = 144,
            w = 190, h = 50,
            elements = {
                'Race',
                'Puzzle',
                'Platform',
                'Stunts'
            }
        },
        -- Bottom buttons
        _GLibs.gmui.Button:new {    -- 6
            xpos = 4, ypos = 200,
            w = 194, h = 20,
            value = true,
            text = 'Open Folder: Yes',
            func = toggleme
        },
        _GLibs.gmui.Button:new {    -- 7
            xpos = 4, ypos = 228,
            w = 60, h = 20,
            text = 'Cancel',
            func = function(button) button.parent.shown = false end
        },
        _GLibs.gmui.Button:new {    -- 8
            xpos = 71, ypos = 228,
            w = 60, h = 20,
            text = 'Save LMU',
            func = savef.saveCampaignLMU
        },
        _GLibs.gmui.Button:new {    -- 9
            xpos = 138, ypos = 228,
            w = 60, h = 20,
            text = 'Save GBX',
            func = savef.saveCampaignGBX
        },
        -- Labels
        _GLibs.gmui.Label:new {     -- 10
            xpos = 4, ypos = 70,
            w = 130, h = 16,
            text = 'Unlock Order'
        },
        _GLibs.gmui.Label:new {     -- 11
            xpos = 4, ypos = 124,
            w = 130, h = 16,
            text = 'Campaign Type'
        }
    }
}

w_save.exitbutt.func = function(butt)
    butt.parent.shown = false
end

w_save.children[4].selected = 1
w_save.children[5].selected = 1

return w_save
