-- When running `pandoc -f markdown -t markdown_strict`, Pandoc will escape
-- `[[_TOC_]]`. To prevent this, this filter (temp.) wraps the `[[_TOC_]]` into
-- a raw `markdown_strict` block, which the corresponding writer translates back
-- to the original "plain" paragraph.

function Para(p)

   local i = pandoc.Para({pandoc.Str("[["), pandoc.Emph({pandoc.Str("TOC")}), pandoc.Str("]]")})
   local o = pandoc.RawBlock("markdown_strict", "[[_TOC_]]")

   -- if the paragraph matches
   if pandoc.utils.equals(p, i)
   then

      -- substitute it by a raw block
      return {o}
   end

   -- all other blocks will be left unchanged

   return p
end
