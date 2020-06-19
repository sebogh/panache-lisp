--[[
see:
- https://pandoc.org/lua-filters.html
- https://www.lua.org/pil/2.5.html
- https://pandoc.org/lua-filters.html#module-pandoc
]]

function RawBlock(p)

   -- a tex-block only containing a \pagebreak 
   if p.format == "tex" and p.text == "\\pagebreak"
   then

      -- will be replaced by an empty list, which is spliced in -> removed 
      return {}
   end

   -- all other blocks will be left unchanged
   return p
end
