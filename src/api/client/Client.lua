-- Client API

os.loadAPI("api/Config")
os.loadAPI("api/Strings")
os.loadAPI("api/Util")
os.loadAPI("api/Log")

-- Global variables and constants
CODE_EXIT = 99
CODE_KEEP_ALIVE = 10
CODE_RECEIVE_MSG = 50
CODE_UNKNOWN_EVENT = 60
VERSION = 1

local UNKNOWN_SERVER_ID = -99
local COMM_RETRIES = 10
local COMM_INTERVAL = 5
local CLIENT_KEEPALIVE = 60
local REDSTONE_STATE = 1

-- Computercraft's os.loadAPI friendly creator
function create()
  return ClientClass:new()
end

-- Class that implements all client functions
ClientClass = {
  keepAlive = CLIENT_KEEPALIVE,
  _commInterval = COMM_INTERVAL,
  _commRetries = COMM_RETRIES,
  name = Strings.GENERIC_CLIENT,
  redstoneState = REDSTONE_STATE,
  redstoneSide = Strings.FRONT,
  serverSecret = Strings.CHANGE_ME,
  _keepAliveTimer = nil,
  _serverId = UNKNOWN_SERVER_ID,
  _modemSide = nil
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

--
-- Saves client configuration using a template
--
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

--
-- Loads configuration from the given file
--
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

--
-- Performs a server lookup until a valid server is found
--
function ClientClass:waitForServerLookup()
  local serverFound = false
  while not serverFound do
    local servers = {rednet.lookup(Strings.CONTROL_PROTOCOL, self.serverSecret)}
    Log.debug(Strings.SERVERS_FOUND, Util.length(servers))
    if Util.length(servers) > 0 then
      serverFound = true
      self._serverId = servers[1]
    else
      Log.debug(Strings.SERVER_UNAVAILABLE, self._commInterval)
      os.sleep(self._commInterval)
    end
  end
end

--
-- Waits for a valid available modem
--
function ClientClass:waitForModem()
  local side = nil
  repeat
    side = Util.getModemSide()
    if side == nil then
      Log.debug(Strings.WAITING_FOR_AVAILABLE_MODEM)
      os.sleep(self._commInterval)
    end
  until side ~= nil
  self._modemSide = side
end

--
-- Sends client data to the server
--
function sendClientData()
  local data = {
    client_name = self.name,
    redstone = self.redstoneState,
    side = self.redstoneSide,
    keep_alive = self.keepAlive
  }
  local messageSent = false
  local retries = self._commRetries
  while ((not messageSent) and (retries > 0)) do
    messageSent = rednet.send(self._serverId, Util.createMessage(VERSION, data), Strings.CONTROL_PROTOCOL)
    if messageSent then
      Log.debug(String.MESSAGE_SENT)
    else
      Log.debug (Strings.ERROR_SENDING_MESSAGE)
    end
    os.sleep (self._commInterval)
    retries = retries - 1
  end
  return messageSent
end


--
-- Process and a message received from server
--
function ClientClass:processMessage(raw)
  local version, message = Util.getDataFromMessage(raw)
  log.trace(Strings.PROCESSING_MESSAGE_VERSION, tostring(version))
end

--
-- Sends client state and waits for server ACK
--
function ClientClass:sendAndWaitResponse()
  local messageSent = self:sendClientData()

  -- receiving
  local messageReceived = false
  retries = _commRetries
  while ((not messageReceived) and (retries > 0)) do
    local senderId, rawMessage, protocol = rednet.receive(Strings.CONTROL_PROTOCOL)
    if ((protocol == Strings.CONTROL_PROTOCOL) and (senderId == self._serverId)) then
      Log.debug(Strings.MESSAGE_RECEIVED)
      Log.trace(rawMessage)
      messageReceived = true
      self:processMessage(rawMessage)
    else
      Log.debug(Strings.MESSAGE_RECEIVED_FROM_SENDER, tostring(senderId))
    end
    retries = retries - 1
  end

  return messageSent and messageReceived
end

--
-- Communicates with the server.
--
-- Communication protocol:
-- 1:   Clients waits for modem.
-- 2:   Client keeps looking up server.
-- 3:   Client sends data. (finite retries)
-- 4:   Clients waits ACK from the server
--      (finite retries)
--
function ClientClass:communicateWithServer()
  self:waitForModem()
  rednet.open(self._modemSide)
  self:waitForServerLookup()
  local result = self:sendAndWaitResponse()
  rednet.close()
  return result
end

--
-- Handshakes with the server.
--
-- The protocol followed is identical to every
-- communication made against the server.
-- This function keeps communicating with the
-- server until the protocol is fulfilled.
--
function ClientClass:waitForHandshake()
  Log.debug (Strings.HANDSHAKING)
  while not self:communicateWithServer() do
    os.sleep(self._commInterval)
  end
end

--
-- Sends a keep alive status message to the server
-- following the communication protocol.
--
function ClientClass:sendKeepAlive()
  Log.debug(Strings.SENDING_KEEP_ALIVE)
  return self:communicateWithServer()
end

--
-- Handles event receiving from server
--
function ClientClass:handleRednetEvent(event)
  Log.debug(Strings.REDNET_PROTOCOL_MSG_RECEIVED)
  if self._serverId == event[2] then
    Log.trace(Strings.RECEIVED_MSG_FROM_SERVER)
    processMessage(event[3])
  else
    Log.trace(Strings.RECEIVED_FROM_UNKNOWN_SERVER, tostring(event[2]))
  end
end

--
-- Handles all client events.
--
function ClientClass:handleEvent()
  local result = true
  local code = CODE_UNKNOWN_EVENT
  if self._keepAliveTimer == nil then
    self._keepAliveTimer = os.startTimer(self.keepAlive)
  end

  local event = {os.pullEvent()}
  Util.printTrace(event)
  if self:isEventKeepAlive(event) then
    self._keepAliveTimer = nil
    result = self:sendKeepAlive()
    code = CODE_KEEP_ALIVE
  elseif self:isEventExit(event) then
    code = CODE_EXIT
  elseif self:isEventRednet(event) then
    code = CODE_RECEIVE_MSG
    self:handleRednetEvent(event)
  else
    Log.debug(Strings.UNKNOWN_EVENT, event[1])
  end

  return result, code
end

function ClientClass:isEventKeepAlive(event)
  return ((event[1] == Strings.EVENT_TIMER and event[2] == self._keepAliveTimer)
    or (event[1] == Strings.EVENT_KEY and event[2] == keys.k))
end

function ClientClass:isEventExit(event)
  return (event[1] == Strings.EVENT_KEY and event[2] == keys.q)
end

function ClientClass:isEventRednet(event)
  return (event[1] == Strings.EVENT_REDNET and event[4] == Strings.CONTROL_PROTOCOL)
end
