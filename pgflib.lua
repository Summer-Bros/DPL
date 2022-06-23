local function tobin(num)
    local result = ""
    while num > 0 do
        result = bit32.band(num, 1) .. result
        num = bit32.rshift(num, 1)
    end 
    while result:len() < 8 do
        result = "0" .. result
    end
    return result
end
local function tohex(num)
    return string.format("%x", num)
end
local function bintobol(str)
    local function bol(n)
        if n == "0" then
            return false
        elseif n == "1" then
            return true
        end
    end
    local a = {}
    for i = 1, str:len() do
        table.insert(a, bol(str:sub(i, i)))
    end
    return a
end
local function boltobin(tbl)
    local function bin(n)
        if n == false then
            return "0"
        elseif n == true then
            return "1"
        end
    end
    local a = ""
    for i = 1, #tbl do
        a = a .. bin(tbl[i])
    end
    return a
end
local function decode(filePath)
    local file = fs.open(filePath, "rb")
    local fileC = file.readAll()
    file.close()
    local height = fileC:byte(1)
    local width = fileC:byte(2)
    local backgroundC = {fileC:byte(3), fileC:byte(4), fileC:byte(5), fileC:byte(6)}
    local color1 = {fileC:byte(7), fileC:byte(8), fileC:byte(9), fileC:byte(10)}
    local color2 = {fileC:byte(11), fileC:byte(12), fileC:byte(13), fileC:byte(14)}
    local color3 = {fileC:byte(15), fileC:byte(16), fileC:byte(17), fileC:byte(18)}
    local color4 = {fileC:byte(19), fileC:byte(20), fileC:byte(21), fileC:byte(22)}
    local meta = {name = name, height = height, width = width, colors = {backgroundC, color1, color2, color3, color4}}
    local data = {}
    for i = 23, 22 + width * height do
        table.insert(data, {type = bintobol(tobin(fileC:byte(i)):sub(1, 6)), color = tonumber(tobin(fileC:byte(i)):sub(7), 2) + 1})
    end
    local extra = fileC:sub(23 + width * height)
    return {meta = meta, data = data, extra = extra}
end
local function encode(filePath, inData)
    local o = "" 
    local meta = inData.meta
    local data = inData.data
    local extra = inData.extra
    o = o .. string.char(meta.height)
    o = o .. string.char(meta.width)
    local eColors = meta.colors
    for ci = 1, 5 do
        for vi = 1, 4 do
            o = o .. string.char(eColors[ci][vi])
        end
    end
    for pi = 1, #data do
        o = o .. string.char(tonumber(boltobin(data[pi].type) .. tobin(data[pi].color - 1):sub(7), 2))
    end
    o = o .. extra
    file = fs.open(filePath, "wb")
    file.write(o)
    file.close()
end
local function char(iType)
    local aType = {}
    if iType[6] then
        for i = 1, 5 do
            aType[i] = not iType[i]
        end
    else
        for i = 1, 5 do
            aType[i] = iType[i]
        end
    end
    local ci = 128
    if aType[1] then
        ci = ci + 2 ^ 0
    end
    if aType[2] then
        ci = ci + 2 ^ 1
    end
    if aType[3] then
        ci = ci + 2 ^ 2
    end
    if aType[4] then
        ci = ci + 2 ^ 3
    end
    if aType[5] then
        ci = ci + 2 ^ 4
    end
    return string.char(ci), iType[6]
end
local function color(image, cIndex)
    return image.meta.colors[cIndex + 1]
end
-- height, width, background color, color 1, color 2, color 3, color 4, (extra). colors are in RGBA format ({R, G, B, A})
local function new(height, width, cB, c1, c2, c3, c4, extra)
    local dExtra
    if not extra then dExtra = "" else dExtra = tostring(extra) end
    return {
        meta = {
            height = height,
            width = width,
            colors = {
                cB,
                c1,
                c2,
                c3,
                c4,
            },
        },
        data = {},
        extra = dExtra,
    }
end
return {
    load = decode,
    save = encode,
    getChar = char,
    getColor = color,
    new = new,
}
