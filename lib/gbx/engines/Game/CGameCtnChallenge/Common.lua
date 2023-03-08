local fsb = require 'lib.fsbinary'

local utils = require 'lib.gbx.utils'

local Common = function(rf, size, chunkid)
    local out = {}
    out.version = fsb.readInt8(rf)
    out.trackmeta = utils.readMetaInfo(rf)
    local strlen = fsb.readInt32(rf)
    out.trackname = rf:read(strlen)
    out.kind = fsb.readInt8(rf)
    if out.version >= 1 then
        out.locked = fsb.readInt32(rf)
        local strlen = fsb.readInt32(rf)
        out.xorpassword = rf:read(strlen)
        if out.version >= 2 then
            out.decoration = utils.readMetaInfo(rf)
            if out.version >= 3 then
                out.maporigin = {
                    fsb.readInt32(rf),
                    fsb.readInt32(rf)
                }
                if out.version >= 4 then
                    out.maptarget = {
                        fsb.readInt32(rf),
                        fsb.readInt32(rf)
                    }
                    if out.version >= 5 then
                        fsb.readInt32(rf)
                        fsb.readInt32(rf)
                        fsb.readInt32(rf)
                        fsb.readInt32(rf)
                        if out.version >= 6 then
                            return nil
                        end
                    end
                end
            end
        end
    end
    return out
end

return Common
