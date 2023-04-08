local bfile = {}

function bfile:write(strdata)
    self.data = self.data .. strdata
    return string.len(strdata)
end

function bfile:read(amount)
    local out = string.sub(self.data, self.fpointer, self.fpointer + amount - 1)
    self.fpointer = self.fpointer + amount
    return out
end

function bfile:isEOF()
    if self.fpointer < string.len(self.data) then return false else return true end
end

function bfile:close()
    self.data = nil
    self.fpointer = nil
end

function bfile:new(new)
    local new = new or {}
    new.data = ""
    new.fpointer = 1
    setmetatable(new,self)
    self.__index = self
    return new
end

return bfile