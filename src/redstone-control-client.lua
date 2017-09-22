os.loadAPI("api/ClientAPI")
os.loadAPI("api/ClientHelperAPI")
os.loadAPI("api/Util")
os.loadAPI("api/Log")
os.loadAPI("api/Config")

local CONFIG_FILE = "client.conf"
-- Log.<TRACE|DEBUG|INFO|WARNING|ERROR>
local LOG_LEVEL = Log.INFO

-- Main client loop (after handshake)
local function clientLoop (client)
  local exit = false
  while not exit do
    local result, code = client:handleEvent()
    if code == ClientAPI.CODE_EXIT then
      exit = true
    end
    Log.info ("Code: %d , result: %s", code, Util.booleanToString(result))
  end
end

-- Client Program
Log.setLogLevel(LOG_LEVEL)
ClientHelperAPI.validateComputer()
ClientHelperAPI.printHeader(ClientAPI.VERSION)

local client = ClientAPI.ClientClass:new()
local code = client:loadConfig (CONFIG_FILE)
Config.printHelp (Log, code, CONFIG_FILE)

if code == Config.CONFIG_OK then
  ClientHelperAPI.printConfig(Log, client)
  Log.info ("Looking up server. This can take some time.")
  if not client:waitForHandshake() then
    Log.error ("Communications error (check modem and try again)")
  else
    Log.info ("Server found!, initiating client loop...")
    ClientHelperAPI.printMenu()
    clientLoop(client)
  end
end
print ("Exiting program.")
