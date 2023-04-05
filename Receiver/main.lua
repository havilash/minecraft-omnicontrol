constants = require ("constants")
os.loadAPI("json")  -- pastebin get 4nRg9CHU json

function setOutputAll(value)
    local sides = {"top","bottom","left","right","front","back"}
    for i = 1,#sides do
        redstone.setOutput(sides[i], value)
    end
end

function getOutputAll()
    local sides = {"top","bottom","left","right","front","back"}
    for i = 1,#sides do
        if redstone.getOutput(sides[i]) == false then
            return false
        end
    end
    return true
end

rednet.open("top")
print("[STARTING] receiver is starting (id: "..os.getComputerID()..") ...")
print("[LISTENING] receiver is listening on protocol: "..constants.PROTOCOL.." ...")

while true do
    senderID, msg = rednet.receive(constants.PROTOCOL)
    print("message received #"..senderID..": "..msg)
    msg = json.decode(msg)
    if msg.request == "control" then
        local signal = false
        if msg.action == "toggle" then
            signal = (getOutputAll() == false)
        elseif msg.action == "on" then
            signal = true
        elseif msg.action == "off" then
            signal = false
        else
            signal = getOutputAll()
        end

        setOutputAll(signal)
        local msg = {
            state = signal,
        }
        rednet.send(senderID, json.encode(msg), constants.PROTOCOL)
    end
end

rednet.close("top")