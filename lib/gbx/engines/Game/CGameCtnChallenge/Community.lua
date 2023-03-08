local fsb = require 'lib.fsbinary'

local Community = function(rf, size, chunkid)
    local out = {}
    local strlen = fsb.readInt32(rf)
    out.xml = rf:read(strlen)
    return out
end

return Community