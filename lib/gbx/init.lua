local gbx = {}

local fsb = require 'lib.fsbinary'
local lfs = love.filesystem
local gbxutils = require 'lib.gbx.utils'

local engines = require 'lib.gbx.engines'

local nodecount = 1

local function getValue(value)
    if type(value) == 'boolean' then
        if value then return 'true'
        else return 'false' end
    elseif type(value) == 'string' then
        return string.format('"%s"',value)
    elseif type(value) == 'number' then
        return value
    else return '<userdata>' end
end

local function printTable(tab,indent)
    indent = indent or ''
    for k,v in pairs(tab) do
        if type(v) == 'table' then
            if type(k) == 'string' then
                print(indent..'["'..k..'"]'..':')
            else
                print(indent..'['..k..']:')
            end
            printTable(v,indent..'    ')
        else
            if type(k) == 'string' then
                print(indent..'["'..k..'"] '..'= '..getValue(v))
            else
                print(indent..'['..k..'] = '..getValue(v))
            end
        end
    end
end

local function readEngineClassChunk(rf)
    local data = {}
    for i=0,3 do
        data[4-i] = rf:read(1)
    end
    local str = ''
    for k,v in ipairs(data) do
        local value = string.byte(v)
        if value < 10 then
            str = str .. '0' .. string.format('%x',value)
        else
            str = str .. string.format('%x',value)
        end
    end
    local out = {
        ['engine'] = string.sub(str,1,2),
        ['class'] = string.sub(str,3,5),
        ['chunk'] = string.sub(str,6,8)
    }
    return out
end

function gbx.open(rf, readbody)
    readbody = readbody or true
    _Lookback = nil
    _LookbackGlob = {}
    if type(rf) == 'string' then
        rf = lfs.newFile(rf)
    end
    local gbxobj = {}
    rf:open('r')
    local magic = rf:read(3)
    if magic ~= 'GBX' then
        rf:close()
        return nil
    end
    local gbxver = fsb.readInt16(rf)
    gbxobj.version = gbxver
    if gbxver >= 3 then
        gbxobj.ftype = rf:read(1)
        gbxobj.hcomp = rf:read(1)
        gbxobj.bcomp = rf:read(1)
        if gbxver >= 4 then
            gbxobj.unknre = rf:read(1)
        end
        gbxobj.classid = readEngineClassChunk(rf)
        if gbxver >= 6 then
            local userdatasize = fsb.readInt32(rf)
            if userdatasize > 0 then
                local numheaderchunks = fsb.readInt32(rf)
                local userdatahead = {}
                for i=1,numheaderchunks do
                    userdatahead[i] = {
                        ['chunkid'] = readEngineClassChunk(rf),
                        ['chunksize'] = fsb.readInt32(rf),
                        ['heavy'] = false
                    }
                    if bit.band(userdatahead[i]['chunksize'], bit.lshift(1,31)) ~= 0 then
                        userdatahead[i]['heavy'] = true
                    end
                    userdatahead[i]['chunksize'] = userdatahead[i]['chunksize'] - bit.band(userdatahead[i]['chunksize'], bit.lshift(1,31))
                end
                --printTable(userdatahead)
                local userdatabody = {}
                for i=1,numheaderchunks do
                    local engine = engines[userdatahead[i]['chunkid']['engine']]
                    local class = engine[userdatahead[i]['chunkid']['class']]
                    local chunk = class[userdatahead[i]['chunkid']['chunk']]
                    local chunknode = chunk(rf,userdatahead[i]['chunksize'],userdatahead[i]['chunkid'])
                    if chunknode then
                        userdatabody[i] = chunknode
                    else
                        return nil
                    end
                end
                gbxobj.userdata = userdatabody
                printTable(userdatabody)
            end
        end
        local numofnodes = fsb.readInt32(rf)
        gbxobj.numberofnodes = numofnodes
    end
    gbxobj.numberofexternalnodes = fsb.readInt32(rf)
    if gbxobj.numberofexternalnodes > 0 then
        error('Referance tables not implemented!')
    end
    local bytes1 = {}
    local bytes2 = {}
    if readbody then
        if gbxobj.bcomp == 'C' then
            --error("Compressed files not supported!")
        else
            gbxobj.restofdata = rf:read()
        end
    end
    
    gbxobj.path = rf:getFilename()
    
    rf:close()
    return gbxobj
end

local function writeFlagNode(wf, name, challenges)
    fsb.writeInt32(wf, nodecount)
    fsb.writeInt32(wf, 50917376)

    fsb.writeInt32(wf, 50917378)
    fsb.writeInt32(wf, string.len(name))
    wf:write(name)

    fsb.writeInt32(wf, 50917382)
    fsb.writeInt32(wf, 0)
    fsb.writeInt32(wf, #challenges)
    for k, chal in pairs(challenges) do
        gbxutils.writeMetaInfo(wf, chal.userdata[2].trackmeta)
    end
    fsb.writeInt32(wf, -87368191)   -- facede01
    nodecount = nodecount + 1
end

function gbx.saveCampaign(challenges, params)
    
    _Lookback = nil
    _LookbackGlob = {}
    nodecount = 1
    local trackcount = 0
    for fk,fv in ipairs(challenges) do
        for ck, cv in ipairs(fv) do
            trackcount = trackcount + 1
        end
    end
    print(trackcount, 'Track(s)')
    local wf = lfs.newFile(params.name..'.Campaign.Gbx')
    wf:open('w')
    wf:write('GBX')
    fsb.writeInt16(wf, 6)
    wf:write('BUUE')
    fsb.writeInt32(wf, 50921472) -- Main class
    fsb.writeInt32(wf, 0)
    fsb.writeInt32(wf, 6)   -- Number of nodes
    fsb.writeInt32(wf, 0)   -- Number of ex nodes
    -- BODY --
    fsb.writeInt32(wf, 50921472) -- Main class
    fsb.writeInt32(wf, 10)  -- ?
    fsb.writeInt32(wf, #challenges) -- Number of flags

    writeFlagNode(wf, 'White', challenges[1])
    writeFlagNode(wf, 'Green', challenges[2])
    writeFlagNode(wf, 'Blue', challenges[3])
    writeFlagNode(wf, 'Red', challenges[4])
    writeFlagNode(wf, 'Black', challenges[5])

    fsb.writeInt32(wf, 50921476)
    fsb.writeInt32(wf, string.len(params.name))
    wf:write(params.name)
    fsb.writeInt32(wf, 1)
    fsb.writeInt32(wf, 0)
    fsb.writeInt32(wf, 0)
    fsb.writeInt32(wf, 0)

    fsb.writeInt32(wf, 50921478)
    gbxutils.writeLookbackString(wf, params.ident, false)
    --fsb.writeInt32(wf, -1)

    fsb.writeInt32(wf, 50921481)
    wf:write('PIKS')
    fsb.writeInt32(wf, 5)
    fsb.writeInt8(wf, 1)
    gbxutils.writeLookbackString(wf, params.collection, false)

    fsb.writeInt32(wf, 50921482)
    wf:write('PIKS')
    fsb.writeInt32(wf, 4)
    fsb.writeInt32(wf, params.index) -- campaign order

    fsb.writeInt32(wf, 50921483)
    wf:write('PIKS')
    fsb.writeInt32(wf, 8)
    fsb.writeInt32(wf, 0)
    fsb.writeInt32(wf, 0)

    fsb.writeInt32(wf, 50921484)
    wf:write('PIKS')
    fsb.writeInt32(wf, 4)
    gbxutils.writeLookbackString(wf, params.icon, false)

    fsb.writeInt32(wf, 50921485)
    fsb.writeInt32(wf, params.unlockorder)

    fsb.writeInt32(wf, -87368191)   -- facede01
    wf:close()
end

return gbx
