-- All the strings and messages used

EXITING_PROGRAM = "Exiting program."

SERVER_FOUND = "Server found!, initiating client loop..."

COMMUNICATIONS_ERROR = "Communications error (check modem and try again)"

LOOKING_UP_SERVER = "Looking up server. This can take some time."

KEEP_ALIVE = "  Keep alive:     %d sec"

NAME = "  Name:           %q"

REDSTONE_STATE = "  Redstone state: %d - %q"

ADVANCED_COMPUTER_NEEDED = "An advanced computer is needed for this to run"

HEADER = [[
Client for Redstone Control v%s
Check repo for more info or instructions
github.com/lpenap/computercraft-redstone-control
]]

MENU = [[
Available options:
  q : Quit
  k : Force keep alive now
]]

MODEM = "modem"

TRUE = "true"

FALSE = "false"

GENERIC_CLIENT = "Generic Client"

FRONT = "front"

CHANGE_ME = "Change_Me"

CONFIG_TEMPLATE = [[--
-- Remote Control Program by lpenap
-- https://github.com/lpenap/computercraft-redstone-control
-- luisau.mc@gmail.com

-- Tip: If you think the configuration file is
-- broken, You can delete it safely and the
-- program will generate a new file again.

-- Client Configuration:

-- Secret for your server
-- You will generate this when you run the
-- server for the first time.
SERVER_SECRET = "${serverSecret}"

-- Interval for reporting to server program
-- (in seconds)
KEEP_ALIVE = ${keepAlive}

-- Name of this client Instance
CLIENT_NAME = "${clientName}"

-- Initial state of redstone signal
-- 1 for ON, or 0 for OFF
REDSTONE_STATE = ${redstoneState}

-- Side for redstone signal
REDSTONE_SIDE = "${redstoneSide}"
]]

DIR_SEP = "/"

EMPTY_STRING = ""

MSG_CONFIG_NOT_FOUND = [[
  Can't find configuration file.

  A new configuration file was generated.
  Configuration located at %s
  You may edit this file to change default settings.
  Run the program again when done.
]]

MSG_CONFIG_SYNTAX_ERROR = [[
  Syntax error in config file %s
  Try fixing it and restart the program.

  Tip: You can delete the config file and
       it will be created again!.
]]

MSG_CONFIG_LOAD_ERROR = [[
  Could not find the necessary config.
  The file exists, but the config could not be
  loaded due to an unkown error.
  Try restarting the program again.
  
  Tip: You can delete the config file and
       it will be created again!.
]]

MSG_CONFIGURATION_LOADED = "Configuration loaded."

MSG_ERROR_LOADING_CONFIG = "Unknown fatal error while loading config file."
