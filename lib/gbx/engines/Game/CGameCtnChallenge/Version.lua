local fsb = require 'lib.fsbinary'

local Version = function(rf, size, chunkid)
    local out = {}
    out.version = fsb.readInt32(rf)
    return out
end

return Version
