local function lex(contents)
    local words = {}
    
    do
        local word = ""
        local char = ""
        local quotea = false
        local quoteb = false
        local quotec = false
        local list = false
        for pos = 1, contents:len() do
            char = contents:sub(pos, pos)
            if ((char == " ") or (char == "\n")) and (not (quotea or quoteb or quotec)) then
                table.insert(words, word)
                word = ""
            else
                word = word .. char
                if ((char == "\"") and not (quoteb or quotec)) then
                    quotea = not quotea
                end
                if ((char == "'") and not (quotea or quotec)) then
                    quoteb = not quoteb
                end
                if ((char == "`") and not (quotea or quoteb)) then
                    quotec = not quotec
                end
            end
        end
        table.insert(words, word)
    end

    do
        local new_words = {}
        for i = 1, #words do
            if not words[i]:find("`") then
                table.insert(new_words, words[i])
            end
        end
        words = new_words
    end

    return words
end

return lex