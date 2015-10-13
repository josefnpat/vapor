local collection = {}

function collection:all()
  return self._data
end

function collection:add(val)
  table.insert(self._data,val)
  return val
end

function collection:remove(val)
  for i,v in pairs(self._data) do
    if v == val then
      return table.remove(self._data,i)
    end
  end
  return false
end

function collection:empty()
  self._data = {}
  return self._data
end

function collection:isEmpty()
  return #self._data == 0
end

function collection:count()
  return #self._data
end

function collection:has(val)
  for _,v in pairs(self._data) do
    if v == val then
      return true
    end
  end
  return false
end

function collection:find(f)
  local found = {}
  for _,v in pairs(self._data) do 
    if f(v) then
      table.insert(found,v)
    end
  end
  return found
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
  self._data=init.data or {}
  return self
end

return collection
