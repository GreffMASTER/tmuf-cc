local fsb = require 'lib.fsbinary'

local utils = require 'lib.gbx.utils'

local TmDesc = function(rf, size, chunkid)
    local out = {}
    out.version = fsb.readInt8(rf)
    if out.version < 3 then
        out.trackmeta = utils.readMetaInfo(rf)
        local strlen = fsb.readInt32(rf)
        out.trackname = rf:read(strlen)
    end
    fsb.readInt32(rf) -- bool 0
    if out.version >= 1 then
        out.bronzetime = fsb.readInt32(rf)
        out.silvertime = fsb.readInt32(rf)
        out.goldtime = fsb.readInt32(rf)
        out.authortime = fsb.readInt32(rf)
        if out.version == 2 then
            out.byte = rf:read(1) -- byte
        end
        if out.version >= 4 then
            out.cost = fsb.readInt32(rf)
            if out.version >= 5 then
                out.multilap = fsb.readInt32(rf)
                if out.version == 6 then
                    out.bool1 = fsb.readInt32(rf) -- bool
                end
                if out.version >= 7 then
                    out.tracktype = fsb.readInt32(rf)
                    if out.version >= 9 then
                        fsb.readInt32(rf) -- 0
                        if out.version >= 10 then
                            out.authorscore = fsb.readInt32(rf)
                            if out.version >= 11 then
                                out.editormode = fsb.readInt32(rf)
                                if out.version >= 12 then
                                    out.bool2 = fsb.readInt32(rf) -- bool 0
                                    if out.version >= 13 then
                                        out.nbcheckpoints = fsb.readInt32(rf)
                                        out.nblaps = fsb.readInt32(rf)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return out
end

return TmDesc
