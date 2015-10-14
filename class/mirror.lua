local mirror = {}

-- LuaClassGen pregenerated functions

function mirror.new(init)
  init = init or {}
  local self=vapor.class.download.new(init)

  -- TODO: make mirrors fs safe
  self:setFilenamePrefix("mirror")
  self:setIdentifier(init.uri)

  local download_update = self.update
  self.update = function()
    local ret = download_update(self)
    if self:getStatus() == vapor.status.downloaded then
      -- TODO: make async
      self:setStatus(vapor.status.processing)
      -- This is the basic validation function for 1.0 api.
      local success,data = pcall(function()

        local os = "win"

        local data = vapor.util.json.decode( self._data )
        assert(data.api_version == "1.0","invalid api version")
        local r = {}

        r.games = {}
        for _,game in pairs(data.games) do
          local g = {}
          assert(game.id)
          g.identifier = tonumber(game.id)
          assert(game.name)
          g.name = game.name
          assert(game.framework)
          g.framework = game.framework
          assert(game.image)
          g.image = game.image
          g.description = game.description or "N/A"
          g.author = game.author or "N/A"
          g.website = game.website or "N/A"

          g.release = {}
          g.release.stable = game.release.stable
          g.release.versions = {}
          for _,version in pairs(game.release.versions) do
            local v = {}
            assert(version.id)
            v.identifier = tonumber(version.id)
            assert(version.uri)
            v.uri = version.uri
            assert(version.size)
            v.size = version.size
            assert(version.hash)
            v.hash = version.hash
            table.insert(g.release.versions,v)
          end
          table.insert(r.games,g)
        end

        r.frameworks = {}
        for _,framework in pairs(data.frameworks) do
          local f = {}
          assert(framework.id)
          f.identifier = tonumber(framework.id)
          assert(framework.name)
          f.name = framework.name
          assert(framework.image)
          f.image = framework.image
          f.author = framework.author or "N/A"
          f.website = framework.website or "N/A"
          table.insert(r.frameworks,f)

          f.release = {}
          f.release.stable = framework.release.stable
          f.release.versions = {}
          for _,version in pairs(framework.release.versions) do
            local v = {}
            assert(version.id)
            v.identifier = tonumber(version.id)
            assert(version[os.."-uri"])
            v.uri = version[os.."-uri"]
            assert(version[os.."-size"])
            v.size = version[os.."-size"]
            assert(version[os.."-hash"])
            v.hash = version[os.."-hash"]
            v.unzip = version[os.."-unzip"] or false
            assert(version[os.."-exec"])
            v.exec = version[os.."-exec"]
            table.insert(f.release.versions,v)
          end
        end

        return r
      end)

      if success then
        --vapor.util.print_r(data)
        self:setStatus(vapor.status.processed)
        self._processedData = data
      else
        print("error: "..data)
        self:setStatus(vapor.status.fail)
      end

    end
    return ret
  end

  return self
end

return mirror
