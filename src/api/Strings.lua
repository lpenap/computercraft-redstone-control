-- All the strings and used messages

--
-- These strings could be changed or localized
--

SEND_ON_TO_ALL = "Sending redstone state ON to all clients."

SEND_OFF_TO_ALL = "Sending redstone state OFF to all clients."

WAITING_FOR_AVAILABLE_MODEM = "Waiting for available modem."

MESSAGE_SENT = "Message sent."

MESSAGE_RECEIVED = "Message received."

MESSAGE_RECEIVED_FROM_SENDER = "Message received from: %s"

MESSAGE_RECEIVED_FROM_UNKNOWN_SENDER = "Message received from unknown client: %s"

PROCESSING_MESSAGE_VERSION = "Processing message version %s"

ERROR_SENDING_MESSAGE = "Error sending message. Retrying."

SENDING_KEEP_ALIVE = "Sending keep alive to server."

HANDSHAKING = "Handshaking with server."

RECEIVED_MSG_FROM_SERVER = "Received message from my configured server."

RECEIVED_FROM_UNKNOWN_SERVER =  "Received message from unknown server: %s"

REDNET_PROTOCOL_MSG_RECEIVED = "Received rednet message from redstone control protocol."

EXITING_PROGRAM = "Exiting program."

SERVER_FOUND = "Server found!, initiating client loop..."

SERVERS_FOUND = "Servers found: %s"

SERVER_UNAVAILABLE = "Server unavailable, retrying in %s seconds"

COMMUNICATIONS_ERROR = "Communications error (check modem and try again)"

LOOKING_UP_SERVER = "Looking up server. This can take some time."

KEEP_ALIVE =     "  Keep alive:     %d sec"

NAME =            "  Name:           %q"

REDSTONE_STATE = "  Redstone state: %d - %q"

MONITOR_UPDATE = "  Monitor update: %d sec"

ADVANCED_COMPUTER_NEEDED = "An advanced computer is needed for this to run."
MODEM_NEEDED = "A modem is needed attached to this computer."

HEADER = [[
Client for Redstone Control v%s
Check repo for more info or instructions
github.com/lpenap/computercraft-redstone-control
]]

SERVER_HEADER = [[
Server for Redstone Control v%s
Check repo for more info or instructions
github.com/lpenap/computercraft-redstone-control
]]


MENU = [[
Available options:
  q : Quit
  k : Force keep alive now
]]

SERVER_MENU = [[
Available options:
  q : Quit
  1 : Turn all clients ON
  0 : Turn all clients OFF
]]

GENERIC_CLIENT = "Generic Client"

DEFAULT_SERVER_NAME = "Redstone Control"

CHANGE_ME = "Change_Me"

MSG_CONFIG_NOT_FOUND = [[
  Can't find configuration file.

  A new configuration file was generated.
  Configuration located at %s
  You may edit this file to change default
  settings.
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

UNKNOWN_EVENT = "Unknown event received: %s"

-- End of localizable Strings.

--
-- Program specific messages. These strings should
-- be changed only by advanced users.
-- Keep in mind that there could be variable
-- names that could not be changed without
-- affecting the program behavior.
--
CONFIG_TEMPLATE = [[
-- Remote Control Program by lpenap
-- https://github.com/lpenap/computercraft-redstone-control
-- luisau.mc@gmail.com

-- Client Configuration

-- Tip: If you think this configuration file is
-- broken, You can delete it safely and the
-- program will generate a new file and you
-- will need to write your settings again.

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

SERVER_CONFIG_TEMPLATE = [[
-- Remote Control Program by lpenap
-- https://github.com/lpenap/computercraft-redstone-control
-- luisau.mc@gmail.com

-- Server Configuration

-- Tip: If you think this configuration file is
-- broken, You can delete it safely and the
-- program will generate a new file and you
-- will need to write your settings again.

-- Secret for your server
-- You will generate this when you run the
-- server for the first time.
-- Also, You can change it here too. You will need
-- this secret in your clients so they can 
-- communicate with this server without
-- interference.
SERVER_SECRET = "${serverSecret}"

-- Interval for updating monitors
-- (in seconds)
MONITOR_UPDATE = ${monitorUpdate}

-- Name of this Server Instance
SERVER_NAME = "${serverName}"
]]

SERVER_HOSTNAME = "lpenap/redstone-control-server"

--
-- Computercraft specific Strings. These should
-- not be changed or translated unless you know
-- what you are doing.
--
MODEM = "modem"

EVENT_TIMER = "timer"

EVENT_KEY = "key"

EVENT_REDNET = "rednet_message"

TRUE = "true"

FALSE = "false"

FRONT = "front"

DIR_SEP = "/"

EMPTY_STRING = ""
