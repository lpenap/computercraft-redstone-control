-- ClientHelper API
-- Helper functions for the Client program
-- Usually output-related

os.loadAPI("api/Strings")

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

