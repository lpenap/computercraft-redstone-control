-- Basic Log facility
-- Just prints logs to console based on log level

TRACE = 10
DEBUG = 20
INFO = 30
WARNING = 40
ERROR = 50

CONSOLE_LOGGER = 10
FILE_LOGGER = 20

local logFile = "logger.log"

local logLevel = INFO
local loggerType = CONSOLE_LOGGER
local fp = nil

function start()
  fp = io.open (logFile, "w")
end

function finalize()
  if fp ~= nil then
    fp:flush()
    fp:close()
  end
end

function setLogger (type)
  loggerType = type
end

function setLogFile(filename)
  logFile = filename
end

function setLogLevel(level)
  logLevel = level
end

local function printFile (msg, ...)
  if fp == nil then
    openFile()
  end
  if msg ~= nil then
    fp:write(string.format(msg.."\n", unpack(arg)))
  else
    fp:write("\n")
  end
end

local function printConsole (msg, ...)
  if msg ~= nil then
    print(string.format(msg, unpack(arg)))
  else
    print()
  end
end

local function printMessage (msg, ...)
  if loggerType == FILE_LOGGER then
    printFile (msg, unpack(arg))
  else
    printConsole(msg, unpack(arg))
  end
end

function trace (msg, ...)
  if logLevel <= TRACE then
    printMessage(msg, unpack(arg))
  end
end

function debug (msg, ...)
  if logLevel <= DEBUG then
    printMessage(msg, unpack(arg))
  end
end

function info (msg, ...)
  if logLevel <= INFO then
    printMessage(msg, unpack(arg))
  end
end

function warn (msg, ...)
  if logLevel <= WARNING then
    printMessage(msg, unpack(arg))
  end
end

function error (msg, ...)
  if logLevel <= ERROR then
    printMessage(msg, unpack(arg))
  end
end

