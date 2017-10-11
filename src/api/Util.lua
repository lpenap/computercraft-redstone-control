-- Utility functions
-- General utility functions used on both client and server.

os.loadAPI("api/Strings")
os.loadAPI("api/Log")
os.loadAPI("api/Json")
os.loadAPI("api/Comm")

--
-- Table used in the random string generator
--
local charset = {}
-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function booleanToString (booleanValue)
  if booleanValue then
    return Strings.TRUE
  else
    return Strings.FALSE
  end
end

-- Returns the first available side where a modem
-- is found.
-- Returns nil otherwise
function getModemSide ()
  local sides = redstone.getSides()
  local modemSide = nil
  for _, side in pairs(sides) do
    if peripheral.isPresent(side) and peripheral.getType(side) == Strings.MODEM then
      modemSide = side
      break
    end
  end
  return modemSide
end

-- Check computer for required components
function validateComputer()
  local messages = Strings.EMPTY_STRING
  if not term.isColor() then
    messages = ("%s\n%s"):format(messages, Strings.ADVANCED_COMPUTER_NEEDED)
  end
  if getModemSide == nil then
    messages = ("%s\n%s"):format(messages, Strings.MODEM_NEEDED)
  end
  if messages ~= Strings.EMPTY_STRING then
    error (mesages)
  end
end

-- Prints event info
function printTrace(event)
  Log.debug("Event Received.")
  for k, v in pairs(event) do
    Log.trace("   %s : %s", tostring(k), tostring(v))
  end
end

function length(table)
  local count = 0
  for _ in pairs(table) do
    count = count + 1
  end
  return count
end

--
-- Returns a random string of given length
--
function randomString(length)
  math.randomseed(os.time())
  if length > 0 then
    return randomString(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

