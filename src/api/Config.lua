-- Configuration API for both client and server

CONFIG_OK = 10
CONFIG_NOT_FOUND = 11
CONFIG_SYNTAX_ERROR = 12
CONFIG_LOAD_ERROR = 13

local function interpolate(s, params)
  return s:gsub('($%b{})', function(w) return params[w:sub(3, -2)] or w end)
end

function saveConfig (configFile, template, values)
  local fp = fs.open ("/" .. configFile, "w")
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
    log.warn ("Can't find cofiguration file.")
    log.warn ()
    log.warn ("A new configuration file was generated.")
    log.warn ("Configuration located at %s", configFile)
    log.warn ("You may edit this file to change default settings.")
    log.warn ("Run the program again when done.")
  elseif code == CONFIG_SYNTAX_ERROR then
    log.warn ("Syntax error in config file %s", configFile)
    log.warn ("Try fixing it and restart the program.")
    log.warn ()
    log.warn ("Tip: You can delete the config file and")
    log.warn ("     it will be created again!.")
  elseif code == CONFIG_LOAD_ERROR then
    log.warn ("Could not find the necessary config.")
    log.warn ("The file exists, but the config could not be")
    log.warn ("loaded due to an unkown error.")
    log.warn ("Try restarting the program again.")
    log.warn ()
    log.warn ("Tip: You can delete the config file and")
    log.warn ("     it will be created again!.")
  elseif code == CONFIG_OK then
    log.info ("Configuration loaded.")
  else
    log.error ("Unknown fatal error while loading config file.")
  end
end
