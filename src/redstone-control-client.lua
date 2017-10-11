-- Computercraft Redstone Control Client by lpenap
-- Available from repo:
-- https://github.com/lpenap/computercraft-redstone-control

os.loadAPI("api/client/Client")
os.loadAPI("api/client/ClientHelper")
os.loadAPI("api/Util")
os.loadAPI("api/Log")
os.loadAPI("api/Config")
os.loadAPI("api/Strings")

local CONFIG_FILE = "client.conf"

-- Log.<TRACE|DEBUG|INFO|WARNING|ERROR>
local LOG_LEVEL = Log.TRACE

-- Main client loop (after handshake)
local function clientLoop (client)
  local exit = false
  while not exit do
    local result, code = client:handleEvent()
    if code == Client.CODE_EXIT then
      exit = true
    end
    Log.info ("Code: %d , result: %s", code, Util.booleanToString(result))
  end
end

-- Client Program
Log.setLogLevel(LOG_LEVEL)
ClientHelper.printHeader(Client.VERSION)
Util.validateComputer()

local client = Client.create()
local code = client:loadConfig (CONFIG_FILE)
Config.printHelp (Log, code, CONFIG_FILE)

if code == Config.CONFIG_OK then
  ClientHelper.printConfig(Log, client)
  client:start()
  Log.info (Strings.LOOKING_UP_SERVER)
  if not client:waitForHandshake() then
    Log.error (Strings.COMMUNICATIONS_ERROR)
  else
    Log.info (Strings.SERVER_FOUND)
    ClientHelper.printMenu()
    clientLoop(client)
  end
  client:finalize()
end
print (Strings.EXITING_PROGRAM)
