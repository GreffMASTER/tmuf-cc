function love.conf(t)
    t.identity = 'tmuf-cc'              -- The name of the save directory (string)
    t.version = "11.3"                  -- The LÖVE version this game was made for (string)
    t.accelerometerjoystick = false     -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = true            -- True to save files (and read from the save directory) in external storage on Android (boolean) 

    t.window.title = "TMUF-CC"          -- The window title (string)
    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.width = 1000               -- The window width (number)
    t.window.height = 600               -- The window height (number)
    t.window.resizable = false          -- Let the window be user-resizable (boolean)
    t.window.minwidth = 452             -- Minimum window width if the window is resizable (number)
    t.window.minheight = 300            -- Minimum window height if the window is resizable (number)

    t.modules.audio = false             -- Enable the audio module (boolean)
    t.modules.joystick = false          -- Enable the joystick module (boolean)
    t.modules.physics = false           -- Enable the physics module (boolean)
    t.modules.sound = false             -- Enable the sound module (boolean)
end
