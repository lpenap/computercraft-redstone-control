-- ClientHelperAPI
-- Helper functions for the Client program

os.loadAPI("api/Strings")
os.loadAPI("api/Util")

function printHeader (version)
  term.clear()
  print ((Strings.HEADER):format(version))
end

function printMenu()
  print (Strings.MENU)
end

function printConfig(log, client)
  log.debug (Strings.KEEP_ALIVE, client:getKeepAlive())
  log.debug (Strings.NAME, client:getName())
  log.debug (Strings.REDSTONE_STATE, client:getRedstoneState(), client:getRedstoneSide())
end

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
