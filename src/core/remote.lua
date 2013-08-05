remote = {}

remote.uri = "http://50.116.63.25/public/vapor/games.json"
remote.file = "games.json"

-- @param force_local don't check remote server for new file
function remote.load(force_local)

  local r,e
  if not force_local then
    r,e = http.request(remote.uri)
  end

  if e == 200 then
    print(remote.file .. " successfully updated.")
    love.filesystem.write(remote.file,r)
    remote.data = json.decode(r)
  else
    print(remote.file.." failed to update.")
    local raw,_ = love.filesystem.read(remote.file)
    remote.data = json.decode(raw)
  end

  table.sort(remote.data.games, function(a,b) return a.name < b.name end )

end

return remote
