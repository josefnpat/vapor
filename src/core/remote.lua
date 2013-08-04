remote = {}

remote.uri = "http://50.116.63.25/public/vapor/games.json"

function remote.load()

  r,e = http.request(remote.uri)
  if e == 200 then
    print("games.json successfully updated.")
    love.filesystem.write("games.json",r)
    remote.data = json.decode(r)
  else
    print("games.json failed to update.")
    local raw,_ = love.filesystem.read("games.json")
    remote.data = json.decode(raw)
  end

  table.sort(remote.data.games, function(a,b) return a.name < b.name end )

end

return remote
