local util = {}

local cwd = (...):gsub('%.[^%.]+$', '')

util.http = require "socket.http"
util.json = require(cwd..".json")

-- from https://gist.github.com/nrk/31175
util.print_r = function ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

-- modified from bobbyjones' unZipLove from addCompat
util.unzip = function ( fn )
  love.filesystem.mount( fn, string.gsub(fn, "%.([%w%-]+)$", "") )
  love.filesystem.createDirectory( "unzipped-"..string.gsub(fn, "%.([%w%-]+)$", "") )
  local path = string.gsub(fn, "%.([%w%-]+)$", "")
  local function callback(folder)
    --print('folder:',folder)
  end
  local folder = love.filesystem.getDirectoryItems(
    string.gsub(fn, "%.([%w%-]+)$", ""), callback )
  local function  recurseFolder( folder, path, prefix )
    for i,file in ipairs( folder ) do
      if love.filesystem.isDirectory( path .. "/".. file ) then
        local folder = love.filesystem.getDirectoryItems(path.."/"..file,callback)
        love.filesystem.createDirectory(prefix..path.."/"..file)
        recurseFolder( folder, path .. "/".. file, prefix )
      elseif love.filesystem.isFile( path .."/" .. file ) then
        local content = love.filesystem.read(path.."/"..file)
        love.filesystem.write(prefix..path.."/"..file, content)
      end
    end
    return prefix..path
  end
  return recurseFolder( folder, path, "unzipped-")
end

return util
