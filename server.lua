-- v 000
local modemSide = "right" -- The side where the wireless modem is connected
local serverChannel = 123 -- The channel number used by the server
local password = "secretpassword" -- The password required to access the cloud storage

-- Set up the wireless modem
local modem = peripheral.wrap(modemSide)

-- Function to save a file to a floppy disk
local function saveFileToDisk(fileName, fileContents)
  local diskPath = "/mnt/floppy/" .. fileName
  local file = fs.open(diskPath, "w")
  file.write(fileContents)
  file.close()
end

-- Function to retrieve a file from a floppy disk
local function retrieveFileFromDisk(fileName)
  local diskPath = "/mnt/floppy/" .. fileName
  if fs.exists(diskPath) then
    local file = fs.open(diskPath, "r")
    local fileContents = file.readAll()
    file.close()
    return fileContents
  else
    return nil
  end
end

-- Function to list all files on the floppy disk
local function listFilesOnDisk()
  local fileList = ""
  local files = fs.list("/mnt/floppy")
  for _, fileName in ipairs(files) do
    fileList = fileList .. fileName .. "\n"
  end
  return fileList
end

-- Wait for client connections
while true do
  local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

  -- Check if the correct channel is used
  if senderChannel == serverChannel and message == password then
    -- Client provided correct password
    modem.transmit(replyChannel, senderChannel, "Access granted!")

    -- Allow client to perform cloud storage operations
    while true do
      modem.transmit(replyChannel, senderChannel, "Enter command [upload/download/list/exit]:")
      local event, modemSide, senderChannel, replyChannel, command, senderDistance = os.pullEvent("modem_message")

      if senderChannel == serverChannel then
        if command == "upload" then
          modem.transmit(replyChannel, senderChannel, "Enter file name:")
          local event, modemSide, senderChannel, replyChannel, fileName, senderDistance = os.pullEvent("modem_message")

          modem.transmit(replyChannel, senderChannel, "Enter file contents:")
          local event, modemSide, senderChannel, replyChannel, fileContents, senderDistance = os.pullEvent("modem_message")

          -- Save the file to the floppy disk
          saveFileToDisk(fileName, fileContents)

          modem.transmit(replyChannel, senderChannel, "File uploaded successfully.")
        elseif command == "download" then
          modem.transmit(replyChannel, senderChannel, "Enter file name:")
          local event, modemSide, senderChannel, replyChannel, fileName, senderDistance = os.pullEvent("modem_message")

          -- Retrieve the file from the floppy disk
          local fileContents = retrieveFileFromDisk(fileName)

          if fileContents then
            modem.transmit(replyChannel, senderChannel, fileContents)
          else
            modem.transmit(replyChannel, senderChannel, "File not found.")
          end
        elseif command == "list" then
          -- List all files on the floppy disk
          local fileList = listFilesOnDisk()
          modem.transmit(replyChannel, senderChannel, fileList)
        elseif command == "exit" then
          modem.transmit(replyChannel, senderChannel, "Connection closed.")
          break
        else
          modem.transmit(replyChannel, senderChannel, "Invalid command.")
        end
      end
    end
  elseif senderChannel == serverChannel then
    -- Client provided incorrect password
    modem.transmit(replyChannel, senderChannel, "Access denied.")
  end
end
