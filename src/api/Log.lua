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

function trace (msg, ...)
  if logLevel <= TRACE then
    if msg ~= nil then
      arg = arg or {}
      print(string.format(msg, unpack(arg)))
    else
      print()
    end
  end
end

function debug (msg, ...)
  print ("hhey: "..msg)
  if logLevel <= DEBUG then
    if msg ~= nil then
      if arg == nil then
        print ("es nil")
      end
      print(string.format(msg, unpack(arg)))
    else
      print()
    end
  end
end

function info (msg, ...)
  if logLevel <= INFO then
    if msg ~= nil then
      arg = arg or {}
      print(string.format(msg, unpack(arg)))
    else
      print()
    end
  end
end

function warn (msg, ...)
  if logLevel <= WARNING then
    if msg ~= nil then
      arg = arg or {}
      print(string.format(msg, unpack(arg)))
    else
      print()
    end
  end
end

function error (msg, ...)
  if logLevel <= ERROR then
    if msg ~= nil then
      arg = arg or {}
      print(string.format(msg, unpack(arg)))
    else
      print()
    end
  end
end

