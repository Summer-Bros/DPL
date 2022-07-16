local function lex(contents)
    local words = {}
    do
        local word = ""
        local char = ""
        for pos = 1, contents:len() do
            char = contents:sub(pos, pos)
            if char == " " then
                table.insert(words, word)
                word = ""
            else
                word = word .. char
            end
        end
        table.insert(words, word)
    end
    return words
end

return lex