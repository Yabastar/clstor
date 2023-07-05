local modemSide = "right"  -- The side where the wireless modem is connected
local diskDriveSide = "left" -- The side where the disk drive is connected
local password = "secretpassword" -- The password required to access the cloud storage

local channel = 123 -- Custom channel number, change it as per your preference

-- Set up the wireless modem
local modem = peripheral.wrap(modemSide)
modem.open(channel)

-- Wait for client connections
while true do
  local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

  -- Check if the correct channel is used
  if senderChannel == channel then
    if message == password then
      -- Client provided correct password
      modem.transmit(replyChannel, channel, "Access granted!")
      
      -- Allow client to perform cloud storage operations
      while true do
        modem.transmit(replyChannel, channel, "Enter command [upload/download/list/exit]:")
        local _, _, _, _, command = os.pullEvent("modem_message")
        
        if command == "upload" then
          modem.transmit(replyChannel, channel, "Enter file name:")
          local _, _, _, _, fileName = os.pullEvent("modem_message")
          
          modem.transmit(replyChannel, channel, "Enter file contents:")
          local _, _, _, _, fileContents = os.pullEvent("modem_message")
          
          -- Save the file on the disk drive
          local diskDrive = peripheral.wrap(diskDriveSide)
          if diskDrive then
            local file = fs.open(fileName, "w")
            file.write(fileContents)
            file.close()
            
            modem.transmit(replyChannel, channel, "File uploaded successfully.")
          else
            modem.transmit(replyChannel, channel, "Disk drive not found.")
          end
        elseif command == "download" then
          modem.transmit(replyChannel, channel, "Enter file name:")
          local _, _, _, _, fileName = os.pullEvent("modem_message")
          
          -- Read the file from the disk drive
          local diskDrive = peripheral.wrap(diskDriveSide)
          if diskDrive then
            local file = fs.open(fileName, "r")
            if file then
              local fileContents = file.readAll()
              file.close()
              
              modem.transmit(replyChannel, channel, fileContents)
            else
              modem.transmit(replyChannel, channel, "File not found.")
            end
          else
            modem.transmit(replyChannel, channel, "Disk drive not found.")
          end
        elseif command == "list" then
          -- List all files in the cloud storage
          local diskDrive = peripheral.wrap(diskDriveSide)
          if diskDrive then
            local files = fs.list("/")
            local fileList = ""
            for _, file in ipairs(files) do
              fileList = fileList .. file .. "\n"
            end
            
            modem.transmit(replyChannel, channel, fileList)
          else
            modem.transmit(replyChannel, channel, "Disk drive not found.")
          end
        elseif command == "exit" then
          -- Close the connection and exit the loop
          modem.transmit(replyChannel, channel, "Connection closed.")
          break
        else
          modem.transmit(replyChannel, channel, "Invalid command.")
        end
      end
    else
      -- Client provided incorrect password
      modem.transmit(replyChannel, channel, "Access denied.")
    end
  end
end
