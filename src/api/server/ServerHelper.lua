-- ClientHelper API
-- Helper functions for the Client program
-- Usually output-related

os.loadAPI("api/Strings")
os.loadAPI("api/Log")

function printHeader (version)
  term.clear()
  print ((Strings.SERVER_HEADER):format(version))
end

function printMenu()
  print (Strings.SERVER_MENU)
end

function printConfig(server)
  Log.debug (Strings.NAME, server:getName())
  Log.debug (Strings.MONITOR_UPDATE, server:getMonitorUpdate())
end

