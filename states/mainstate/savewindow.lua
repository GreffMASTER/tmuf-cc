local gbxf = require 'states.mainstate.gbxfunc'

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
    xpos = 400, ypos = 250,
    w = 200, h = 200,
    title = 'Save Campaign',
    focused = true,
    shown = false,
    children = {
        _GLibs.gmui.Textbox:new {
            xpos = 6, ypos = 4,
            w = 180, h = 16,
            default = 'Campaign Name'
        },
        _GLibs.gmui.Textbox:new {
            xpos = 6, ypos = 26,
            w = 180, h = 16,
            default = 'Campaign Ident'
        },
        _GLibs.gmui.Textbox:new {
            xpos = 6, ypos = 48,
            w = 180, h = 16,
            default = 'Campaign Index'
        },
        _GLibs.gmui.List:new {
            xpos = 6, ypos = 92,
            w = 180, h = 36,
            elements = {
                'By Row',
                'By Column'
            }
        },
        _GLibs.gmui.Button:new {
            xpos = 6, ypos = 138,
            w = 120, h = 20,
            value = true,
            text = 'Open Folder: Yes',
            func = toggleme
        },
        _GLibs.gmui.Button:new {
            xpos = 118, ypos = 170,
            w = 70, h = 20,
            text = 'Save',
            func = gbxf.saveCampaign
        },
        _GLibs.gmui.Button:new {
            xpos = 4, ypos = 170,
            w = 70, h = 20,
            text = 'Cancel',
            func = function(button) button.parent.shown = false end
        },
        _GLibs.gmui.Label:new {
            xpos = 4, ypos = 70,
            w = 120, h = 16,
            text = 'Unlock Order'
        }
    }
}

w_save.children[4].selected = 1

return w_save
