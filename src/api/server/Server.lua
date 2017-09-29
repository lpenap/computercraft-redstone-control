-- Server API

os.loadAPI("api/Config")
os.loadAPI("api/Strings")
os.loadAPI("api/Util")
os.loadAPI("api/Log")

-- Global variables and constants
VERSION = 1
CODE_EXIT = 99
CODE_MONITOR_UPDATE = 10
CODE_RECEIVE_MSG = 50
CODE_UNKNOWN_EVENT = 60
CODE_TURN_ALL_ON = 70
CODE_TURN_ALL_OFF = 80

local COMM_RETRIES = 10
local COMM_INTERVAL = 5
local MONITOR_UPDATE = 2
local DEFAULT_REDSTONE_STATE = 0
local NEVER = -1

-- Computercraft's os.loadAPI friendly creator
function create()
  return ServerClass:new()
end

-- TODO use this class per each registered client
ClientData = {
  state = DEFAULT_REDSTONE_STATE,
  lastUpdated = NEVER,
  name = Strings.GENERIC_CLIENT
}

-- Class that implements all server functions
ServerClass = {
  name = Strings.DEFAULT_SERVER_NAME,
  -- TODO use protocol as server secret, and no the hostname
  serverSecret = Strings.CHANGE_ME,
  monitorUpdate = MONITOR_UPDATE,
  _monitorUpdateTimer = nil,
  _commInterval = COMM_INTERVAL,
  _commRetries = COMM_RETRIES,

  clients = {}
}

function ServerClass:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ServerClass:getName()
  return self.name
end

function ServerClass:getServerSecret()
  return self.serverSecret
end

function ServerClass:getMonitorUpdate()
  return self.monitorUpdate
end

--
-- Saves server configuration using a template
--
function ServerClass:saveConfig(configFile)
  local settings = {
    serverName = self.name,
    monitorUpdate = self.monitorUpdate,
    serverSecret = self.serverSecret
  }
  Config.saveConfig (configFile, Strings.SERVER_CONFIG_TEMPLATE, settings)
end

--
-- Loads configuration from the given file
--
function ServerClass:loadConfig(configFile)
  local code, config = Config.loadConfig (configFile)

  if code == Config.CONFIG_NOT_FOUND then
    self:saveConfig(configFile)

  elseif code == Config.CONFIG_OK then
    self.monitorUpdate = config.MONITOR_UPDATE
    self.name = config.SERVER_NAME
    self.serverSecret = config.SERVER_SECRET
  end
  return code
end

--
-- Waits for a valid available modem
--
function ServerClass:waitForModem()
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
function ServerClass:sendRedstoneStateToClient(clientId, state)
  local data = {
    redstone = state
  }
  local messageSent = false
  local retries = self._commRetries
  while ((not messageSent) and (retries > 0)) do
    messageSent = rednet.send(clientId, Util.createMessage(VERSION, data), Strings.CONTROL_PROTOCOL)
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
-- Sends client state and waits for server ACK
--
--function ClientClass:sendAndWaitResponse()
--  local messageSent = self:sendClientData()
--
--  -- receiving
--  local messageReceived = false
--  retries = _commRetries
--  while ((not messageReceived) and (retries > 0)) do
--    local senderId, rawMessage, protocol = rednet.receive(Strings.CONTROL_PROTOCOL)
--    if ((protocol == Strings.CONTROL_PROTOCOL) and (senderId == self._serverId)) then
--      Log.debug(Strings.MESSAGE_RECEIVED)
--      Log.trace(rawMessage)
--      messageReceived = true
--      self:processMessage(rawMessage)
--    else
--      Log.debug(Strings.MESSAGE_RECEIVED_FROM_SENDER, tostring(senderId))
--    end
--    retries = retries - 1
--  end
--
--  return messageSent and messageReceived
--end

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
--function ClientClass:communicateWithServer()
--  self:waitForModem()
--  rednet.open(self._modemSide)
--  self:waitForServerLookup()
--  local result = self:sendAndWaitResponse()
--  rednet.close()
--  return result
--end

--
-- Handshakes with the server.
--
-- The protocol followed is identical to every
-- communication made against the server.
-- This function keeps communicating with the
-- server until the protocol is fulfilled.
--
--function ClientClass:waitForHandshake()
--  Log.debug (Strings.HANDSHAKING)
--  while not self:communicateWithServer() do
--    os.sleep(self._commInterval)
--  end
--end

--
-- Sends a keep alive status message to the server
-- following the communication protocol.
--
--function ClientClass:sendKeepAlive()
--  Log.debug(Strings.SENDING_KEEP_ALIVE)
--  return self:communicateWithServer()
--end

--
-- Do a monitor update
--
function ServerClass:doMonitorUpdate()
  print("Updating monitor...")
end

--
-- Process and a message received from client
-- and sends back an ACK
--
function ServerClass:processMessage(raw)
  local version, message = Util.getDataFromMessage(raw)
  log.trace(Strings.PROCESSING_MESSAGE_VERSION, tostring(version))
end


--
-- Handles event receiving from server
--
function ServerClass:handleRednetEvent(event)
  Log.debug(Strings.REDNET_PROTOCOL_MSG_RECEIVED)
  local clientId = event[2]
  local jsonMessage = event[3]
  if self.clients[clientId] ~= nill then
    Log.trace(Strings.MESSAGE_RECEIVED_FROM_SENDER)
    self:processMessage(jsonMessage)
    self:sendRedstoneStateToClient(clientId, self.clients[client])
  else
    Log.trace(Strings.MESSAGE_RECEIVED_FROM_UNKNOWN_SENDER, tostring(clientId))
  end
end

--
-- Sends a redstone(ON) update message to all clients
--
function ServerClass:turnAllOn()
  local result = true
  Log.debug(Strings.SEND_ON_TO_ALL)

  return result
end

--
-- Sends a redstone(OFF) update message to all clients
--
function ServerClass:turnAllOff()
  local result = true
  Log.debug(Strings.SEND_OFF_TO_ALL)

  return result
end

--
-- Handles all client events.
--
function ServerClass:handleEvent()
  local result = true
  local code = CODE_UNKNOWN_EVENT
  if self._monitorUpdateTimer == nil then
    self._monitorUpdateTimer = os.startTimer(self.monitorUpdate)
  end

  local event = {os.pullEvent()}
  Util.printTrace(event)
  if self:isEventMonitorUpdate(event) then
    result = self:doMonitorUpdate()
    code = CODE_MONITOR_UPDATE
    self._monitorUpdateTimer = nil
  elseif self:isEventExit(event) then
    code = CODE_EXIT
  elseif self:isEventRednet(event) then
    code = CODE_RECEIVE_MSG
    self:handleRednetEvent(event)
  elseif self:isEventTurnAllOn(event) then
    code = CODE_TURN_ALL_ON
    result = self:turnAllOn()
  elseif self:isEventTurnAllOff(event) then
    code = CODE_TURN_ALL_OFF
    result = self:turnAllOff()
  else
    Log.debug(Strings.UNKNOWN_EVENT, event[1])
  end

  return result, code
end

function ServerClass:isEventTurnAllOn(event)
  return (event[1] == Strings.EVENT_KEY and event[2] == keys.one)
end

function ServerClass:isEventTurnAllOff(event)
  return (event[1] == Strings.EVENT_KEY and event[2] == keys.zero)
end

function ServerClass:isEventMonitorUpdate(event)
  return (event[1] == Strings.EVENT_TIMER and event[2] == self._monitorUpdateTimer)
end

function ServerClass:isEventExit(event)
  return (event[1] == Strings.EVENT_KEY and event[2] == keys.q)
end

function ServerClass:isEventRednet(event)
  return (event[1] == Strings.EVENT_REDNET and event[4] == Strings.CONTROL_PROTOCOL)
end
