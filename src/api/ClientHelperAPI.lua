-- ClientHelperAPI
-- Helper functions for the Client program

function printHeader (version)
  term.clear()
  print ("Client for Redstone Control v".. version)
  print ("Check repo for more info or instructions")
  print ("github.com/lpenap/computercraft-redstone-control")
end

function printMenu()
  print ("Available options:")
  print ("  q : Quit")
  print ("  k : Force keep alive now")
end

function printConfig(log, client)
  log.debug ("  Keep alive:     %d sec", client:getKeepAlive())
  log.debug ("  Name:           %q", client:getName())
  log.debug ("  Redstone state: %d - %q", client:getRedstoneState(), client:getRedstoneSide())
end

function validateComputer()
  if not term.isColor() then
    error ("An advanced computer is needed for this to run")
  end
end
