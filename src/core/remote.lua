remote = {}

remote.uri = "http://50.116.63.25/public/vapor/games.json"
remote.file = "games.json"

function remote.en_sort(a,b)
  -- Lower case the input
  local a_f,b_f = string.lower(a.name),string.lower(b.name)
  -- Remove "the"
  if string.sub(a_f,1,4) == "the " then
    a_f = string.sub(a_f,5,-1)
  end
  if string.sub(b_f,1,4) == "the " then
    b_f = string.sub(b_f,5,-1)
  end
  -- remove all non-alphanumeric characters
  a_f,b_f = string.gsub(a_f,'%W',''),string.gsub(b_f,'%W','')
  return a_f < b_f
end

-- @param force_local don't check remote server for new file
function remote.load(force_local)
  
  local success, r, e
  
  if not force_local then
    success,r,e = pcall(http.request,remote.uri)
    if success and e == 200 then
      print(remote.file .. " successfully updated.")
      love.filesystem.write(remote.file,r)
      remote.data = json.decode(r)
    else
      print(remote.file.." failed to update")
    end
  end
  
  if force_local or not success then
    print('Updated from local '..remote.file)
    local raw,_ = love.filesystem.read(remote.file)
    remote.data = json.decode(raw)
  end

  table.sort(remote.data.games,remote.en_sort)

end

return remote
