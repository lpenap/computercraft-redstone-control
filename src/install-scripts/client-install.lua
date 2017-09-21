-- ComputerCraft Redstone Control Client Installer
-- Bootstrapped by

local tree = select(1,...)
if not tree then
  tree = 'master'
end

local repo = 'lpenap/computercraft-redstone-control'
local romPath = 'redstone-control.rom/'
local retries = 3
local FILES = {
  ['src/api/ClientAPI.lua'] = 'api/ClientAPI',
  ['src/api/ClientHelperAPI.lua'] = 'api/ClientHelperAPI',
  ['src/api/Util.lua'] = 'api/Util',
  ['src/startup/client-startup.lua'] = 'startup',
  ['src/redstone-control-client.lua'] = 'redstoneclient'
}
local PROGRAM_NAME= "Redstone Control Client"

local REPO_BASE = ('https://raw.githubusercontent.com/%s/%s/'):format(repo, tree)

local function request(urlPath)
  local request = http.get(REPO_BASE..urlPath)
  local status = request.getResponseCode()
  local response = request.readAll()
  request.close()
  return status, response
end

local function makeFile(filePath, data)
  local file = fs.open(romPath..filePath,'w')
  file.write(data)
  file.close()
end

local function rewriteDofiles()
  for file,_ in pairs(FILES) do
    local filename = (romPath..file)
    local r = fs.open(filename, 'r')
    local data = r.readAll()
    r.close()
    local w = fs.open(filename, 'w')
    data = data:gsub('dofile%("', ('dofile("%s'):format(romPath))
    w.write(data)
    w.close()
  end
end

local function moveFiles()
  for romFilename, finalFilename in pairs(FILES) do
    fs.delete(finalFilename)
    fs.move(romPath..romFilename, finalFilename)
  end
end

-- install the FILES for redstone control program
local function doInstall()
  print ("Fetching " .. PROGRAM_NAME)
  print ("Using repo: " .. REPO_BASE)
  local isDownloadOk = true
  for path,_ in pairs(FILES) do
    local try = 0
    local status, response = request(path)
    print ("  Fetching " .. path)
    while status ~= 200 and try <= retries do
      status, response = request(path)
      try = try + 1
    end
    if status then
      print ("    OK")
      makeFile(path, response)
    else
      isDownloadOk = false
      print (('Unable to download %s'):format(path))
      for romFilename, finalFilename in pairs(FILES) do
        fs.delete(finalFilename)
        fs.delete(romPath..romFilename)
        fs.delete(romPath)
      end
      break
    end
  end
  rewriteDofiles()
  if isDownloadOk then
    moveFiles()
    print(PROGRAM_NAME.." installed!")
    print("Going to reboot the computer in 5 seconds...")
    os.sleep(5)
    os.reboot()
  else
    print("There was a problem installing the files.")
  end
end

doInstall()
