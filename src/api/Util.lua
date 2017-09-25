-- Utility functions
-- General utility functions used on both client and server.

os.loadAPI("api/Strings")

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
