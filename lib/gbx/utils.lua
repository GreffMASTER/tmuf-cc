local gbxutils = {}

local lfs = love.filesystem
local fsb = require 'lib.fsbinary'

function gbxutils.readLookbackString(rf)
    if not _Lookback then
        --print("First lookback string")
        _Lookback = {}
        _Lookback.version = fsb.readInt32(rf)
    end
    local index = fsb.readInt32(rf)
    local actualindex = bit.band(index, bit.bnot(bit.lshift(1,31)))
    actualindex = bit.band(actualindex, bit.bnot(bit.lshift(1,30)))
    --print("I:",index)
    --print("AI:",actualindex)
    local isnumber = false
    if bit.band(index, bit.lshift(1,31)) == 0 and bit.band(index, bit.lshift(1,30)) == 0 then
        isnumber = true -- index is a number, whatever that means
    end
    --print("ANUM",isnumber)
    if actualindex == 0 then
        local strlen = fsb.readInt32(rf)
        local str = rf:read(strlen)
        table.insert(_Lookback,str)
        --print("returning",str)
        return str
    end
    if actualindex == 0 and (bit.band(index, bit.lshift(1,31)) == 1 or bit.band(index, bit.lshift(1,30)) == 1) then
        local strlen = fsb.readInt32(rf)
        local str = rf:read(strlen)
        table.insert(_Lookback,str)
        --print("returning",str)
        return str
    end
    return _Lookback[actualindex]
end

function gbxutils.writeLookbackString(wf, str, isanumber)
    if not _Lookback then
        --print("First lookback string")
        _Lookback = {}
        fsb.writeInt32(wf, 3)
    end
    local exists = nil
    for k, v in ipairs(_Lookback) do
        if v == str then exists = k end
    end
    if exists then
        local index = 0
        if isanumber then
            index = bit.bor(exists, 2147483648)
        else
            index = bit.bor(exists, 1073741824)
        end
        fsb.writeInt32(wf, index)
    else
        if isanumber then
            fsb.writeInt32(wf, 2147483648)
        else
            fsb.writeInt32(wf, 1073741824)
        end
        fsb.writeInt32(wf, string.len(str))
        wf:write(str)
        table.insert(_Lookback, str)
    end
end

function gbxutils.writeMetaInfo(wf, meta)
    gbxutils.writeLookbackString(wf, meta.id, true)
    gbxutils.writeLookbackString(wf, meta.collection, false)
    gbxutils.writeLookbackString(wf, meta.author, false)
    
end

function gbxutils.readMetaInfo(rf)
    local metainfo = {
        ['id'] = gbxutils.readLookbackString(rf),
        ['collection'] = gbxutils.readLookbackString(rf),
        ['author'] = gbxutils.readLookbackString(rf)
    }
    return metainfo
end

return gbxutils
