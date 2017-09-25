-- Client API

os.loadAPI("api/Config")
os.loadAPI("api/Strings")
os.loadAPI("api/Util")
os.loadAPI("api/Log")

-- Global variables and constants
CODE_EXIT = 99
CODE_KEEP_ALIVE = 10
CODE_RECEIVE_MSG = 50
VERSION = 1

-- Computercraft's os.loadAPI friendly creator
function create()
  return ClientClass:new()
end

-- Class that implements all client functions
ClientClass = {
  keepAlive = 60,
  name = Strings.GENERIC_CLIENT,
  redstoneState = 1,
  redstoneSide = Strings.FRONT,
  serverSecret = Strings.CHANGE_ME
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

function ClientClass:setRedstoneState(newState)
  self.redstoneState = newState
  local state = false
  if newState > 0 then
    state = true
  end
  redstone.setOutput(self.redstoneSide, state)
end

function ClientClass:saveConfig(configFile)
  local settings = {
    keepAlive = self.keepAlive,
    clientName = self.name,
    redstoneState = self.redstoneState,
    redstoneSide = self.redstoneSide,
    serverSecret = self.serverSecret
  }
  Config.saveConfig (configFile, Strings.CONFIG_TEMPLATE, settings)
end

function ClientClass:loadConfig(configFile)
  local code, config = Config.loadConfig (configFile)

  if code == Config.CONFIG_NOT_FOUND then
    self:saveConfig(configFile)

  elseif code == Config.CONFIG_OK then
    self.keepAlive = config.KEEP_ALIVE
    self.name = config.CLIENT_NAME
    self.redstoneSide = config.REDSTONE_SIDE
    self.serverSecret = config.SERVER_SECRET
    self:setRedstoneState(config.REDSTONE_STATE)
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
  local side = Util.getModemSide()
  if side == nil then
    result = false
  end
  return result
end

function ClientClass:sendKeepAlive()
  Log.debug(Strings.SENDING_KEEP_ALIVE)
end

function ClientClass:handleRednetMessage(event)
  Log.debug(Strings.REDNET_PROTOCOL_MSG_RECEIVED)
end

function ClientClass:handleEvent()
  local result = true
  local code = CODE_EXIT
  local keepAliveTimer = os.startTimer(self.keepAlive)
  while true do
    local event = {os.pullEvent()}
    Util.printInfo(event)
    if (event[1] == Strings.EVENT_TIMER and event[2] == keepAliveTimer) then
      self:sendKeepAlive()
    elseif (event[1] == Strings.EVENT_KEY and event[2] == keys.q) then
      break
    elseif (event[1] == Strings.EVENT_KEY and event[2] == keys.k) then
      self:sendKeepAlive()
    elseif (event[1] == Strings.EVENT_REDNET and event[3] == Strings.CONTROL_PROTOCOL) then
      self:handleRednetMessage(event)
    else
      Log.debug(Strings.UNKNOWN_EVENT, event[1])
    end
  end
  return result, code
end
