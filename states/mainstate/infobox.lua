local w_info = _GLibs.gmui.Window:new {
    x = 400, y = 250,
    xpos = 400, ypos = 200,
    w = 210, h = 105,
    title = 'Error',
    focused = true,
    shown = false,
    closable = false,
    children = {
        -- Labels
        info = _GLibs.gmui.Label:new {
            xpos = 4, ypos = 4,
            w = 206, h = 16,
            text = '%info%',
            textal = "center",
        },
        _GLibs.gmui.Button:new {    -- [1]
            xpos = 72, ypos = 74,
            w = 60, h = 20,
            text = 'Ok',
            func = function(button) button.parent.shown = false end
        }
    }
}

return w_info
