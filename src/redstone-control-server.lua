-- Computercraft Redstone Control Server by lpenap
-- Available from repo:
-- https://github.com/lpenap/computercraft-redstone-control

os.loadAPI("api/server/Server")
os.loadAPI("api/server/ServerHelper")
os.loadAPI("api/Util")
os.loadAPI("api/Log")
os.loadAPI("api/Config")
os.loadAPI("api/Strings")

local CONFIG_FILE = "server.conf"

-- Log.<TRACE|DEBUG|INFO|WARNING|ERROR>
local LOG_LEVEL = Log.TRACE

-- Main server loop
local function serverLoop (server)
  local exit = false
  while not exit do
    local result, code = server:handleEvent()
    if code == Server.CODE_EXIT then
      exit = true
    end
    Log.info ("Code: %d , result: %s", code, Util.booleanToString(result))
  end
end

-- Server Program
Log.setLogLevel(LOG_LEVEL)
ServerHelper.printHeader(Server.VERSION)
Util.validateComputer()

local server = Server.create()
local code = server:loadConfig (CONFIG_FILE)
Config.printHelp (Log, code, CONFIG_FILE)

if code == Config.CONFIG_OK then
  ServerHelper.printConfig(server)
  ServerHelper.printMenu()
  serverLoop(server)
end
print (Strings.EXITING_PROGRAM)
