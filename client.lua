local modemSide = "right" -- The side where the wireless modem is connected
local serverChannel = 123 -- The channel number used by the server

-- Set up the wireless modem
local modem = peripheral.wrap(modemSide)
modem.open(serverChannel)

-- Connect to the server
modem.transmit(serverChannel, serverChannel, "secretpassword") -- Replace "secretpassword" with the actual password

-- Wait for the server's response
local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

-- Check if the connection is successful
if message == "Access granted!" then
  print("Connection successful!")

  -- Perform cloud storage operations
  while true do
    print("Enter command [upload/download/list/exit]:")
    local command = read()

    -- Send the command to the server
    modem.transmit(serverChannel, serverChannel, command)

    -- Wait for the server's response
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

    -- Print the server's response
    print(message)

    if command == "exit" then
      -- Close the connection and exit the loop
      break
    elseif command == "upload" then
      print("Enter file name:")
      local fileName = read()
      print("Enter file contents:")
      local fileContents = read()

      -- Send the file name and contents to the server
      modem.transmit(serverChannel, serverChannel, fileName)
      modem.transmit(serverChannel, serverChannel, fileContents)

      -- Wait for the server's response
      local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

      -- Print the server's response
      print(message)
    elseif command == "download" then
      print("Enter file name:")
      local fileName = read()

      -- Send the file name to the server
      modem.transmit(serverChannel, serverChannel, fileName)

      -- Wait for the server's response
      local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

      -- Print the file contents or the server's response
      print(message)
    end
  end
else
  print("Access denied. Connection failed.")
end
