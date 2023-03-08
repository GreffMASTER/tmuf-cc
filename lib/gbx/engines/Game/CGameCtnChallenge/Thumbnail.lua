local fsb = require 'lib.fsbinary'

local Thumbnail = function(rf, size, chunkid)
    local out = {}
    --out.size = size
    --out.chunkid = chunkid
    out.version = fsb.readInt32(rf)
    if version ~= 0 then
        local thumbsize = fsb.readInt32(rf)
        rf:read(string.len('<Thumbnail.jpg>'))
        out.thumbnail = rf:read(thumbsize)
        rf:read(string.len('</Thumbnail.jpg>'))
        rf:read(string.len('<Comments>'))
        local strlen = fsb.readInt32(rf)
        out.comments = rf:read(strlen)
        rf:read(string.len('</Comments>'))
    end
    if string.len(out.thumbnail) > 0 then
        love.filesystem.write('Thumbnail.jpg', out.thumbnail, string.len(out.thumbnail))
        out.thumbnail = love.graphics.newImage('Thumbnail.jpg')
        love.filesystem.remove('Thumbnail.jpg')
        local c = love.graphics.newCanvas(out.thumbnail:getWidth(),out.thumbnail:getHeight())
        c:renderTo(function()
            love.graphics.clear(0,0,0,0)
            love.graphics.draw(out.thumbnail,0,out.thumbnail:getHeight(),0,1,-1)
        end)
        out.thumbnail = c
    else
        out.thumbnail = love.graphics.newCanvas(256,256)
        out.thumbnail:renderTo(function()
            love.graphics.clear(1,1,1)
        end)
    end
    return out
end

return Thumbnail
