settings = {}

settings.file = "settings.json"
settings.padding = 22
settings.offset = (love.graphics.getWidth()-settings.padding*2) / (16/9) + settings.padding -- 16:9

function settings.load()
  if love.filesystem.exists(settings.file) then
    local rawjson = love.filesystem.read(settings.file)
    settings.data = json.decode(rawjson)
  else
    settings.data = {}
    settings.data.games = {}
    for i,v in ipairs(remote.data.games) do
      settings.data.games[v.id] = {}
      settings.data.games[v.id].favorite = false
    end
  end
end

return settings
