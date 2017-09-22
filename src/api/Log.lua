-- Basic Log facility
-- Just prints logs to console based on log level

TRACE = 10
DEBUG = 20
INFO = 30
WARNING = 40
ERROR = 50

local logLevel = INFO

function setLogLevel(level)
  logLevel = level
end

local function printMsg (msg, ...)
  if msg == nil then
    print()
  else
    print (msg:format(...))
  end
end

function trace (msg, ...)
  if logLevel <= TRACE then
    printMsg(msg, ...)
  end
end

function debug (msg, ...)
  if logLevel <= DEBUG then
    printMsg(msg, ...)
  end
end

function info (msg, ...)
  if logLevel <= INFO then
    printMsg(msg, ...)
  end
end

function warn (msg, ...)
  if logLevel <= WARNING then
    printMsg(msg, ...)
  end
end

function error (msg, ...)
  if logLevel <= ERROR then
    printMsg(msg, ...)
  end
end

