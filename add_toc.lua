function Pandoc(doc)
   table.insert(doc.blocks, 1, pandoc.RawBlock("markdown", "[[_TOC_]]"))
   return pandoc.Pandoc(doc.blocks, doc.meta)
end

