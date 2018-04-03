-- Common communications library

os.loadAPI("api/Strings")
os.loadAPI("api/Log")
os.loadAPI("api/Json")
os.loadAPI("api/Util")

local MESSAGE_ID_SIZE = 16

function createMessage(protocolVersion, messageId, dataTable)
  local id = messageId or Util.randomString(MESSAGE_ID_SIZE)
  local message = {
    version = protocolVersion,
    message_id = id,
    data = dataTable
  }
  return Json.encode(message), id
end

function getDataFromMessage(json)
  local message = Json.decode(json)
  return message.version, message.message_id, message.data
end

function createAck()
  local data = {
    message_type = Strings.ACK
  }
  return data
end

function sendData(version, messageId, data, receiverId, protocol)
  local createdMessageId = nil
  local message = ""
  local messageSent = true
  message, createdMessageId = createMessage(version, messageId, data)
  Log.trace(Strings.SENDING_MESSAGE_TO, receiverId, createdMessageId)
  messageSent = rednet.send(receiverId, message, protocol)
  Log.trace("rednet.send result: ".. tostring(messageSent))
  if messageSent then
    Log.debug(Strings.MESSAGE_SENT)
  else
    Log.debug (Strings.ERROR_SENDING_MESSAGE)
  end
  return messageSent, createdMessageId
end

