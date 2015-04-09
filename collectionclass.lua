local collection = {}

function collection:all()
  -- TODO (collectionclass.all.lcg.lua)
end

function collection:add()
  -- TODO (collectionclass.add.lcg.lua)
end

function collection:remove()
  -- TODO (collectionclass.remove.lcg.lua)
end

function collection:empty()
  -- TODO (collectionclass.empty.lcg.lua)
end

function collection:isEmpty()
  -- TODO (collectionclass.isEmpty.lcg.lua)
end

function collection:count()
  -- TODO (collectionclass.count.lcg.lua)
end

function collection:has()
  -- TODO (collectionclass.has.lcg.lua)
end

function collection:find()
  -- TODO (collectionclass.find.lcg.lua)
end

-- LuaClassGen pregenerated functions

function collection.new(init)
  init = init or {}
  local self={}
  self.all=collection.all
  self.add=collection.add
  self.remove=collection.remove
  self.empty=collection.empty
  self.isEmpty=collection.isEmpty
  self.count=collection.count
  self.has=collection.has
  self.find=collection.find
  return self
end

return collection
