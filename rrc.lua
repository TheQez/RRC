req = {}

local retryCount = 3
local receiveTimeout = 1
local count = 0

function req.__init__ ()
  self = {}
  setmetatable (self, {__index=req})
  print("Request created")
  return self
end

setmetatable (req, {__call = req.__init__})

function req:connect (modemSide, targetID)
  rednet.open(modemSide)
  while count < retryCount do
    rednet.send(targetID, "connect")
    id, message = rednet.receive(1)
    if id == targetID and message == "ack" then
      break
    else
      count = count+1
    end
  end
	if count >= retryCount then
		return 1
	else
		rednet.send(targetID, "ack")
		print ("connected")
		count = 0
		return 0
	end
end

rec = {}

function rec.__init__ ()
  self = {}
  setmetatable (self, {__index=rec})
  print("Receive created")
  return self
end

setmetatable (rec, {__call = rec.__init__})

function rec:getConnect (modemSide)
	rednet.open(modemSide)
	while true do
		id, message = rednet.receive()
		if message == "connect" then
			targetID = id
			break
		end
	end
	while count < retryCount do
    rednet.send(id, "ack")
    id, message = rednet.receive(1)
    if id == targetID and message == "ack" then
      break
    else
      count = count+1
    end
  end
	if count >= retryCount then
		return 1
	else
		print("Got connection")
		count = 0
		return 0
	end
end
