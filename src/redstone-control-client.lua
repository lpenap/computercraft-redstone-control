os.loadAPI("api/ClientAPI")
os.loadAPI("api/ClientHelperAPI")
os.loadAPI("api/Util")

-- Configuration file
local CONFIG_FILE = "client.conf"

-- If true, prints additional info on the client
local ADDITIONAL_INFO = true

local VERSION = "0.1a"

-- Client Program
term.clear()
ClientHelperAPI.printHeader()

local client = ClientAPI.ClientClass:new()
local code = client:loadConfig (CONFIG_FILE)

if code ~= Util.CONFIG_OK then
  Util.printConfigMessages (code, CONFIG_FILE)
else
  print ("Configuration loaded.")
  if ADDITIONAL_INFO then
    ClientHelperAPI.printConfig(client)
  end
  print ("Looking up server. This can take some time.")
  if not client:waitForHandshake() then
    print ("Communications error (check modem and try again)")
  else
    print ("Server found!, initiating client loop...")
    ClientHelperAPI.printMenu()
    local exit = false
    while not exit do
      local result, code = client:handleEvent()
      if code == ClientAPI.CODE_EXIT then
        exit = true
      end
      if ADDITIONAL_INFO then
        print ("Code: "..code .. " , result: ".. Util.booleanToString(result))
      end
    end
  end
end
print ("Exiting program.")
