-- Server API

os.loadAPI("api/Config")
os.loadAPI("api/Strings")
os.loadAPI("api/Util")
os.loadAPI("api/Log")
os.loadAPI("api/Comm")

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
--local MONITOR_UPDATE = 2
local MONITOR_UPDATE = 200

local DEFAULT_REDSTONE_STATE = 0
local NEVER = -1

--
-- Internal class to store data from client
--
local ClientData = {
  state = DEFAULT_REDSTONE_STATE,
  lastUpdated = NEVER,
  name = Strings.GENERIC_CLIENT
}

function ClientData:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ClientData:setState(newState)
  self.state = newState
  self.lastUpdated = os.clock()
end

function ClientData:getState()
  return self.state
end

function ClientData:setName (newName)
  self.name = newName
end

function ClientData:getLastUpdatedString()
  local str = Strings.NEVER
  
  if self.lastUpdated ~= NEVER then
    -- TODO allow for more units
    str = (Strings.TIME_AGO):format(os.clock() - self.lastUpdated, "s")
  end
  return str
end

--
-- Computercraft's os.loadAPI friendly creator
-- for ServerClass
--
function create()
  return ServerClass:new()
end

--
-- Class that implements all server functions
--
ServerClass = {
  name = Strings.DEFAULT_SERVER_NAME,
  serverSecret = Strings.CHANGE_ME,
  monitorUpdate = MONITOR_UPDATE,

  _monitorUpdateTimer = nil,
  _commInterval = COMM_INTERVAL,
  _commRetries = COMM_RETRIES,
  _modemSide = nil,

  clients = {}
}

--
-- ServerClass constructor
--
function ServerClass:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--
-- Getters and setters used
--
function ServerClass:getName()
  return self.name
end

function ServerClass:getServerSecret()
  return self.serverSecret
end

function ServerClass:getMonitorUpdate()
  return self.monitorUpdate
end

function ServerClass:addOrUpdateClient(id, state, name)
  local client = ClientData:new()
  client:setState(state)
  client:setName(name)
  self.clients[id] = client
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
  return side
end

--
-- Opens communications channels
--
function ServerClass:start()
  local side = self:waitForModem()
  self._modemSide = side
  rednet.close()
  rednet.open(self._modemSide)
  rednet.host(self.serverSecret, Strings.SERVER_HOSTNAME)
end

--
-- Closes communications channels
--
function ServerClass:finalize()
  rednet.unhost(self.serverSecret, Strings.SERVER_HOSTNAME)
  rednet.close()
end

--
-- Sends client data to the server
--
function ServerClass:sendRedstoneStateToClient(clientId, messageId)
  local data = {
    redstone = self.clients[clientId]:getState()
  }
  Log.trace(Strings.SENDING_MESSAGE_TO, clientId, messageId)
  local messageSent, createdMessageId = Comm.sendData(VERSION, messageId, data, clientId, self.serverSecret)
  return messageSent, createdMessageId
end

--
-- Do a monitor update
--
function ServerClass:doMonitorUpdate()
  Log.trace(Strings.UPDATING_MONITOR)
end

--
-- Process and a message received from client
--
function ServerClass:processMessage(data)
  -- TODO process message on server
  Log.trace(Strings.PROCESSING_MESSAGE)
end

--
-- Handles event receiving message from client
--
function ServerClass:handleRednetEvent(event)
  Log.debug(Strings.REDNET_PROTOCOL_MSG_RECEIVED)
  local clientId = event[2]
  local jsonMessage = event[3]
  local clientVersion, messageId, data = Comm.getDataFromMessage(jsonMessage)
  Log.trace(Strings.MESSAGE_RECEIVED_FROM_SENDER, tostring(clientId), messageId)
  if VERSION ~= clientVersion then
    Log.error (Strings.WRONG_PROTOCOL_VERSION_FROM_CLIENT, clientId, VERSION, clientVersion)
  else
    self:addOrUpdateClient(clientId, data.redstone, data.client_name)
    self:processMessage(data)
    -- TODO expand the protocol to allow for more data to be transmitted like keepAlive times
    self:sendRedstoneStateToClient(clientId, messageId)
  end

end

--
-- Sends a redstone(ON) update message to all clients
--
function ServerClass:turnAllOn()
  -- TODO turn all ON
  local result = true
  Log.debug(Strings.SEND_ON_TO_ALL)

  return result
end

--
-- Sends a redstone(OFF) update message to all clients
--
function ServerClass:turnAllOff()
  -- TODO turn all OFF
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
  return (event[1] == Strings.EVENT_REDNET and event[4] == self.serverSecret)
end
