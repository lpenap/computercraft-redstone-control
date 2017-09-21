-- Utility functions
-- General utility functions used on both client and server.

CONFIG_OK = 10
CONFIG_NOT_FOUND = 11
CONFIG_SYNTAX_ERROR = 12
CONFIG_LOAD_ERROR = 13

local function interpolate(s, params)
  return s:gsub('($%b{})', function(w) return params[w:sub(3, -2)] or w end)
end

function printMessage (result, successMsg, failureMsg)
  if result then
    print (successMsg)
  else
    print (failureMsg)
  end
end

function booleanToString (booleanValue)
  if booleanValue then
    return "true"
  else
    return "false"
  end
end

function printConfigMessages (code, configFile)
  if code == CONFIG_NOT_FOUND then
    print ("Can't find cofiguration file.")
    print ()
    print ("A new configuration file was generated.")
    print ("Configuration located at " .. configFile)
    print ("You may edit this file to change default settings.")
    print ("Run the program again when done.")
  elseif code == CONFIG_SYNTAX_ERROR then
    print ("Syntax error in config file " .. configFile)
    print ("Try fixing it and restart the program.")
    print ()
    print ("Tip: You can delete the config file and")
    print ("     it will be created again!.")
  elseif code == CONFIG_LOAD_ERROR then
    print ("Could not find the necessary config.")
    print ("The file exists, but the config could not be")
    print ("loaded due to an unkown error.")
    print ("Try restarting the program again.")
    print ()
    print ("Tip: You can delete the config file and")
    print ("     it will be created again!.")
  else
    print ("Unknown error while loading config file.")
  end
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
