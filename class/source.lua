local source = {}

-- LuaClassGen pregenerated functions

function source.new(init)
  init = init or {}
  local self=vapor.class.download.new(init)
  self._playPingUri=init.playPingUri
  self.getPlayPingUri=source.getPlayPingUri
  self.setPlayPingUri=source.setPlayPingUri
  self._downloadPingUri=init.downloadPingUri
  self.getDownloadPingUri=source.getDownloadPingUri
  self.setDownloadPingUri=source.setDownloadPingUri
  return self
end

function source:getPlayPingUri()
  return self._playPingUri
end

function source:setPlayPingUri(val)
  self._playPingUri=val
end

function source:getDownloadPingUri()
  return self._downloadPingUri
end

function source:setDownloadPingUri(val)
  self._downloadPingUri=val
end

return source
