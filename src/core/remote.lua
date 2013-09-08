remote = {}

remote.uri = "http://50.116.63.25/public/vapor/games.json"
remote.file = "games.json"

-- @param force_local don't check remote server for new file
function remote.load(force_local)

  if force_local then
    print("Forcing local update.")
    local raw,_ = love.filesystem.read(remote.file)
    remote.data = json.decode(raw)

  else

    local success,r,e = pcall(http.request,remote.uri)
    if success and e == 200 then
      print(remote.file .. " successfully updated.")
      love.filesystem.write(remote.file,r)
      remote.data = json.decode(r)
    else
      print(remote.file.." failed to update.")
      local raw,_ = love.filesystem.read(remote.file)
      remote.data = json.decode(raw)
    end

  end

  table.sort(remote.data.games, function(a,b) return a.name:lower() < b.name:lower() end )

end

return remote
