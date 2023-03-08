local fsb = {}

-- READ FUNCTIONS

function fsb.readInt8(file, signed)
    signed = signed or false

    local data = file:read(1)
    if signed then
        return love.data.unpack('b',data)
    else
        return love.data.unpack('B',data)
    end
end

function fsb.readInt16(file, signed, endian)
    signed = signed or false
    endian = endian or false

    local data = file:read(2)
    if endian then
        if signed then
            return love.data.unpack('>h',data)
        else
            return love.data.unpack('>H',data)
        end
    else
        if signed then
            return love.data.unpack('<h',data)
        else
            return love.data.unpack('<H',data)
        end
    end
end

function fsb.readInt32(file, signed, endian)
    signed = signed or false
    endian = endian or false
    local data = {0,0,0,0}
    if endian then
        for i=1,4,1 do
            data[i] = string.byte(file:read(1))
            if i ~= 4 and file:isEOF() then return nil end
        end
    else
        for i=4,1,-1 do
            data[i] = string.byte(file:read(1))
            if i ~= 1 and file:isEOF() then return nil end
        end        
    end
    local t1 = bit.bor(bit.lshift(data[1],24), bit.lshift(data[2],16))
    local t2 = bit.bor(bit.lshift(data[3],8), data[4])
    local out = bit.bor(t1,t2)
    if signed then
        if out > 2147483647 then out = -2147483648 + (out - 2147483648) end
    end   
    return out
end

function fsb.readFloat(file)
    local data = file:read(4)
    return love.data.unpack('f', data)
end

function fsb.readNullTermString(file)
    local outstr = ''
    while not file:isEOF() do
        local char = file:read(1)
        if string.byte(char) == 0 then break end
        outstr = outstr .. char
    end
    return outstr
end

function fsb.readSetLenString(file, length)
    local outstr = ''
    for i=1,length,1 do
        local char = file:read(1)
        outstr = outstr .. char
        if file:isEOF() then break end
    end
    return outstr
end

-- WRITE FUNCTIONS

function fsb.writeInt8(file, value)
    value = bit.band(value, 0xFF)
    file:write(string.char(value))
    return true
end

function fsb.writeInt16(file, value, endian)
    endian = endian or 'little'
    value = bit.band(value, 0xFFFF)
    local data = {0,0}
    data[1] = bit.rshift(value,8)
    data[2] = bit.bxor(bit.lshift(data[1],8),value)
    if endian == 'little' then
        file:write(string.char(data[2]))
        file:write(string.char(data[1]))
    elseif endian == 'big' then
        file:write(string.char(data[1]))
        file:write(string.char(data[2]))
    end
    return true
end

function fsb.writeInt32(file, value, endian)
    endian = endian or 'little'
    local data = {0,0,0,0}
    data[1] = bit.band(value, 0x000000FF)
    data[2] = bit.rshift(bit.band(value, 0x0000FF00), 8)
    data[3] = bit.rshift(bit.band(value, 0x00FF0000), 16)
    data[4] = bit.rshift(bit.band(value, 0xFF000000), 24)
    if endian == 'little' then
        file:write(string.char(data[1]))
        file:write(string.char(data[2]))
        file:write(string.char(data[3]))
        file:write(string.char(data[4]))
    elseif endian == 'big' then
        file:write(string.char(data[4]))
        file:write(string.char(data[3]))
        file:write(string.char(data[2]))
        file:write(string.char(data[1]))
    end
    return true
end

function fsb.writeFloat(file, value)
    file:write(love.data.pack('string','f',value))
    return true
end

return fsb
