local fsb = require 'lib.fsbinary'

local Undefined = function(rf,size,chunkid)
    local out = {}
    out.size = size
    out.chunkid = chunkid
    out.data = rf:read(size)
    return out
end

return Undefined