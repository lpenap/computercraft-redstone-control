-- Client API

os.loadAPI("api/Util")

-- Global variables and constants
CODE_EXIT = 99
CODE_KEEP_ALIVE = 10
CODE_RECEIVE_MSG = 50

-- Local variables
local CONFIG_TEMPLATE = [[--
-- Remote Control Program by lpenap
-- https://github.com/lpenap/computercraft-redstone-control
-- luisau.mc@gmail.com

-- Tip: If you think the configuration file is
-- broken, You can delete it safely and the
-- program will generate a new file again.


-- Client Configuration:

-- Secret for your server
-- You will generate this when you run the
-- server for the first time.
SERVER_SECRET = "${serverSecret}"

-- Interval for reporting to server program
-- (in seconds)
KEEP_ALIVE = ${keepAlive}

-- Name of this client Instance
CLIENT_NAME = "${clientName}"

-- Initial state of redstone signal
-- 1 for ON, or 0 for OFF
REDSTONE_STATE = ${redstoneState}

-- Side for redstone signal
REDSTONE_SIDE = "${redstoneSide}"
]]

-- Class that implements all client functions
ClientClass = {
  keepAlive = 60,
  name = "Generic Client",
  redstoneState = 1,
  redstoneSide = "front",
  serverSecret = "Change_Me"
}

function ClientClass:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ClientClass:setKeepAlive(secs)
  self.keepAlive = secs
end

function ClientClass:getKeepAlive()
  return self.keepAlive
end

function ClientClass:getName()
  return self.name
end

function ClientClass:getRedstoneState()
  return self.redstoneState
end

function ClientClass:getRedstoneSide()
  return self.redstoneSide
end

function ClientClass:getServerSecret()
  return self.serverSecret
end

function ClientClass:saveConfig(configFile)
  local settings = {
    keepAlive = self.keepAlive,
    clientName = self.name,
    redstoneState = self.redstoneState,
    redstoneSide = self.redstoneSide,
    serverSecret = self.serverSecret
  }
  Util.saveConfig (configFile, CONFIG_TEMPLATE, settings)
end

function ClientClass:loadConfig(configFile)
  local code, config = Util.loadConfig (configFile)

  if code == Util.CONFIG_NOT_FOUND then
    self:saveConfig(configFile)

  elseif code == Util.CONFIG_OK then
    self.keepAlive = config.KEEP_ALIVE
    self.name = config.CLIENT_NAME
    self.redstoneState = config.REDSTONE_STATE
    self.redstoneSide = config.REDSTONE_SIDE
    self.serverSecret = config.SERVER_SECRET
  end
  return code
end

-- Handshake protocol overview:
-- 1:   Clients searchs for modem
-- 1.1: Clients aborts if there is no modem found
-- 2:   Client attempts a rednet lookup of the server
-- 2.1: If no server is found, Client sleeps and tries again 2
-- 3:   Client sends a HELLO message to the server with the initial state
-- 4:   Clients waits for ACK from the server
-- 5:   Clients returns true
function ClientClass:waitForHandshake()
  local result = true
  return result
end

function ClientClass:handleEvent()
  local result = true
  local code = CODE_EXIT

  return result, code
end


