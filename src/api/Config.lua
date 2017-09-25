-- Configuration API for both client and server

os.loadAPI("api/Strings")

CONFIG_OK = 10
CONFIG_NOT_FOUND = 11
CONFIG_SYNTAX_ERROR = 12
CONFIG_LOAD_ERROR = 13

local function interpolate(s, params)
  return s:gsub('($%b{})', function(w) return params[w:sub(3, -2)] or w end)
end

function saveConfig (configFile, template, values)
  local fp = fs.open (Strings.DIR_SEP .. configFile, "w")
  fp.write (interpolate(template, values))
  fp.close()
end

function loadConfig (configFile)
  local errorCode = CONFIG_OK
  local config = nil
  if fs.exists (configFile) == false then
    errorCode = CONFIG_NOT_FOUND
  else
    os.unloadAPI (configFile)
    if os.loadAPI (configFile) == false then
      errorCode = CONFIG_SYNTAX_ERROR
    else
      for k, v in pairs(_G) do
        if k == configFile then
          config = v
          break
        end
      end
      if config == nil then
        errorCode = CONFIG_LOAD_ERROR
      end
    end
  end
  return errorCode, config
end

function printHelp (log, code, configFile)
  if code == CONFIG_NOT_FOUND then
    log.warn(Strings.MSG_CONFIG_NOT_FOUND, configFile)

  elseif code == CONFIG_SYNTAX_ERROR then
    log.warn(Strings.MSG_CONFIG_SYNTAX_ERROR, configFile)

  elseif code == CONFIG_LOAD_ERROR then
    log.warn(Strings.MSG_CONFIG_LOAD_ERROR)

  elseif code == CONFIG_OK then
    log.warn(Strings.MSG_CONFIGURATION_LOADED)

  else
    log.error (Strings.MSG_ERROR_LOADING_CONFIG)
  end
end
