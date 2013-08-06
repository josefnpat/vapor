settings = {}
settings.appver = 1
settings.file = "settings.json"
settings.padding = 22
settings.offset = (love.graphics.getWidth()-settings.padding*2) / (16/9) + settings.padding -- 16:9

function settings.load()
  settings.rows = #remote.data.games
  if love.filesystem.exists(settings.file) then
    local rawjson = love.filesystem.read(settings.file)
    settings.data = json.decode(rawjson)
    if (settings.data.appver ~= settings.appver) then
      settings.data = nil
      print("App version does not match: clearing "..settings.file)
    end
  end
  if not settings.data then
    settings.data = {}
    settings.data.appver = settings.appver
    settings.data.games = {}
    for i,v in ipairs(remote.data.games) do
      settings.data.games[v.id] = {}
      settings.data.games[v.id].favorite = false
    end
  end
end

return settings
