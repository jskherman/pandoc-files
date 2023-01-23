-- Pandoc Lua-filter for Obsidian Callouts
-- By: Je Sian Keith Herman (@jskherman)
-- Based on: https://forum.obsidian.md/t/rendering-callouts-similarly-in-pandoc/40020/

-- Notes:
-- Original snippet modified to output Quarto callouts with collapse.
-- Make sure to have a blank line before and after the `> [!note]` line of the callout block.
-- The filter works recursively so if you want callouts within callouts, make sure to leave a blank line
-- before and after the `> [!note] Your title here` line of each callout.

-- Usage:
-- ```
-- pandoc -s input_obsidian.md --lua-filter quarto-callout.lua -t markdown -o input_quarto.qmd
-- ```


-- Source: https://stackoverflow.com/a/33511182
-- Function to check if array contains a specific value
local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- --


-- For getting the plain string use `stringify`.
-- local stringify = (require "pandoc.utils").stringify
local callouts = { 'note', 'warning', 'tip', 'important', 'caution' }

function BlockQuote(el)
    start = el.content[1]
    if (start.t == "Para" and start.content[1].t == "Str" and start.content[1].text:match("^%[!%w+%][-+]?%s?.*$")) then
        _, _, ctype = start.content[1].text:find("%[!(%w+)%]")
        _, _, collapse = start.content[1].text:find("%[!%w+%]([-+]?)")

        if (#start.content > 2 and start.content[2].t == "Space") then
            titletext = ""
            titletable = table.pack(table.unpack(start.content, 3))
            for i, v in ipairs(titletable) do
                if v.t == "Space" then
                    titletext = titletext .. " "
                else
                    titletext = titletext .. v.text
                end
            end
        else
            titletext = ctype:upper()
        end

        el.content:remove(1)
        start.content:remove(1)

        if has_value(callouts, ctype:lower()) then
            div = pandoc.Div(el.content, {class = "callout-" .. ctype:lower()})
        else
            div = pandoc.Div(el.content, {class = "callout-note"})
        end
        
        div.attributes["data-callout"] = ctype:lower()
        -- TODO: change title instead to be as a heading inside of the callout div
        div.attributes["data-title"] = titletext 
        if collapse == "-" then
            div.attributes["collapse"] = "true"
        elseif collapse == "+" then
            div.attributes["collapse"] = "false"
        end
        return div
    else
        return el
    end
end
