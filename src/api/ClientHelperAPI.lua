-- ClientHelperAPI
-- Helper functions for the Client program

function printHeader ()
  print ("Running Client for Redstone Control")
  print ("Check repo for more info or instructions")
  print ("github.com/lpenap/computercraft-redstone-control")
end

function printMenu()
  print ("Available options:")
  print ("  q : Quit")
  print ("  k : Force keep alive now")
end

function printConfig(client)
  print ("  Keep alive:     ".. client:getKeepAlive())
  print ("  Name:           ".. client:getName())
  print ("  Redstona state: ".. client:getRedstoneState() .. " - ".. client:getRedstoneSide())
end

--local additionalInfo = {
	--[ClientAPI.CODE_KEEP_ALIVE] = function (x) printMessage (x, "")
	--CODE_RECEIVE_MSG

--}
