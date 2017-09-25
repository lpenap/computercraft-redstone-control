-- Utility functions
-- General utility functions used on both client and server.

os.loadAPI("api/Strings")
os.loadAPI("api/Log")

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
  if Util.getModemSide == nil then
    messages = ("%s\n%s"):format(messages, Strings.MODEM_NEEDED)
  end
  if messages ~= Strings.EMPTY_STRING then
    error (mesages)
  end
end

-- Prints event info
function printInfo(event)
  Log.debug("Event Received:")
  for k, v in pairs(event) do
    Log.debug("   %s : %s", tostring(k), tostring(v))
  end
end
