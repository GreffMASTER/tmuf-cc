local lmu = {}

local lmuversion = 1

local fsb = require 'lib.fsbinary'
local bfile = require 'lib.bfile'

local lfs = love.filesystem

local types_w = {}
local types_r = {}

local table_refs = {}

local function writeHeader(file)
    file:write('LMU')                       -- LMU magic
    fsb.writeInt16(file,lmuversion)         -- LMU version
end

local function readTable(file)
    local settcount = fsb.readInt16(file)           -- number of entries in table
    print(settcount)
    local tab = {}
    for i=1,settcount,1 do
        local varnametype = file:read(1)            -- index (number) or key (string) (I or K)
        local varname = ''
        if varnametype == 'K' then                  -- is a key
            varname = fsb.readNullTermString(file)  -- read key name
        elseif varnametype == 'I' then              -- is a index
            varname = fsb.readInt16(file)           -- read index
        else return nil end                         -- incorrect
        print(varname)
        local vtype = fsb.readInt8(file)            -- get variable type
        tab[varname] = types_r[vtype](file)         -- read data depending on variable type
        print(tab[varname])
        local setterm = fsb.readInt8(file)          -- check if table ends with 'FF'
        if setterm ~= 255 then return nil end       -- incorrect
    end
    return tab
end

local function writeTable(file, tab)
    if tab == _G then print("tried to save _G!"); return false end
    local counter = 0
    for k,v in pairs(tab) do
        if type(v) ~= 'function' then
            counter = counter + 1
        end
    end
    fsb.writeInt16(file,counter)
    for k,v in pairs(tab) do
        if type(v) ~= 'function' then
            if type(k) == 'string' then
                file:write('K')
                file:write(k) -- string
                fsb.writeInt8(file,0) -- null term
            elseif type(k) == 'number' then
                file:write('I')
                fsb.writeInt16(file,k)  -- index
            end
            types_w[type(v)](file,v)
            fsb.writeInt8(file, 255)
        end
    end
end

types_w = {
    ['boolean'] = function(file,value)
        local n = 0
        if value then n = 1 end
        fsb.writeInt8(file,n)
    end,
    ['number'] = function(file,value)
        local _, decimal = math.modf(value)
        if decimal == 0.0 then
            fsb.writeInt8(file,2)
            fsb.writeInt32(file,value)
        else
            fsb.writeInt8(file,4)
            fsb.writeFloat(file,value)
        end
    end,
    ['string'] = function(file,value)
        fsb.writeInt8(file,3)
        fsb.writeInt16(file,#value)
        file:write(value)
    end,
    ['table'] = function(file,value)
        for k,v in ipairs(table_refs) do
            if value == v then
                fsb.writeInt8(file,6)
                fsb.writeInt16(file,k)
                return
            end
        end
        table.insert(table_refs,value)
        fsb.writeInt8(file,5)
        writeTable(file,value)
    end,
    ['userdata'] = function(file,value)
        if value.type then
            local lovetype = value:type()
            if lovetype == 'ImageData' then
                local filedata = value:encode('png')
                fsb.writeInt8(file,7)
                fsb.writeInt32(file,string.len(filedata:getString()))
                file:write(filedata:getString())
            end
            if lovetype == 'Canvas' then
                local imgdata = value:newImageData()
                local filedata = imgdata:encode('png')
                fsb.writeInt8(file,7)
                fsb.writeInt32(file,string.len(filedata:getString()))
                file:write(filedata:getString())
            end
        end
    end
}

types_r = {
    [0] = function(file)                    -- BOOLEAN FALSE
        return false
    end,
    [1] = function(file)                    -- BOOLEAN TRUE
        return true
    end,
    [2] = function(file)                    -- INTEGER
        return fsb.readInt32(file,true)
    end,
    [3] = function(file)                    -- STRING
        local strlen = fsb.readInt16(file)
        return file:read(strlen)
    end,
    [4] = function(file)                    -- FLOAT
        return fsb.readFloat(file)
    end,
    [5] = function(file)                    -- TABLE
        local tab = readTable(file)
        table.insert(table_refs,tab)
        return tab
    end,
    [6] = function(file)                    -- TABLE REFERENCE
        local index = fsb.readInt16(file)
        return table_refs[index]
    end,
    [7] = function(file)                    -- PNG IMAGE
        local size = fsb.readInt32(file)
        local rawdata = love.data.newByteData(file:read(size))
        return love.graphics.newImage(love.image.newImageData(rawdata))
    end,
}

local functab_meta = {
    __index = function()
        return function() end
    end
}

setmetatable(types_w, functab_meta)
setmetatable(types_r, functab_meta)

function lmu.loadLMUFile(path)
    local file
    if path == 'string' then
        file = lfs.newFile(path)
        file:open('r')
    else
        file = bfile:new()
        file.data = path:read()
        file.fpointer = 1
    end
    table_refs = {}
    local h = file:read(3)
    print(h)
    if h ~= 'LMU' then return nil, 'Err: incorrect format magic' end
    local ver = fsb.readInt16(file)
    if ver > lmuversion then return nil, 'Err: unsupported version' end
    local ct = fsb.readInt32(file)
    local mt = fsb.readInt32(file)
    print(ct)
    print(mt)
    local compress = file:read(1)
    local tab = {}
    if compress == 'C' then
        print('File compressed')
        local tabdata = bfile:new()
        local size = fsb.readInt32(file)
        local comped = file:read(size)
        tabdata.data = love.data.decompress('string','lz4',comped)
        tab = readTable(tabdata)
    elseif compress == 'U' then
        print('File uncompressed')
        tab = readTable(file)
    else return nil, 'Err: incorrect compression mode' end
    local fileterm = file:read(6)       -- fileterminator
    print(fileterm)
    file:close()
    if fileterm ~= 'LMUEND' then return nil, 'Err: incorrect terminator' end
    if tab then
        return tab, 'OK'
    else
        return nil, 'Err: parser error'
    end
end

function lmu.saveLMUFile(path, tab, compress)
    table_refs = {}
    compress = compress or false
    local exists = false
    if type(tab) ~= 'table' then return false end
    local ct = os.time()
    local mt = os.time()

    local file = lfs.newFile(path)

    if love.filesystem.getInfo( path ) then
        file:open('r')
        file:read(5)
        ct = fsb.readInt32(file)
        file:close()
    end

    file:open('w')
    writeHeader(file)
    fsb.writeInt32(file,ct)
    fsb.writeInt32(file,mt)
    local tabdata = bfile:new()
    writeTable(tabdata, tab)
    if compress then
        file:write('C')
        local comped = love.data.compress('string','lz4',tabdata.data,9)
        local size = string.len(comped)
        fsb.writeInt32(file,size)
        file:write(comped)
    else
        file:write('U')
        file:write(tabdata.data)
    end
    file:write('LMUEND') -- write file terminator
    file:close()
    return true
end

return lmu
