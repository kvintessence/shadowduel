local class = require("lib/middleclass")
local tinyECS = require("lib/tiny-ecs")

local socket = require( "socket" )

local globals = require("code/globals")

local module = {}

local getIpAddress = function()
    local dummySocket = socket.udp()
    dummySocket:setpeername("74.125.115.104", 80)  -- Google website, not really important
    local ip, sock = dummySocket:getsockname()
    return ip
end

module.SecondPlayerFinderSystem = tinyECS.system(class('systems/secondPlayerFinder'))

function module.SecondPlayerFinderSystem:initialize()
    self.broadcastLastTime = 0
    self.broadcastMessage = "ShadowDuelClientBroadcast"
    self.broadcastPort = 44678

    self.multicastIp = "226.192.1.1"
    self.broadcastIp = "255.255.255.255"

    -- broadcast setup
    self.broadcastOutputSocket = socket.udp()
    self.broadcastOutputSocket:settimeout(0)

    self.broadcastInputSocket = socket.udp()
    self.broadcastInputSocket:setsockname(self.multicastIp, self.broadcastPort)  -- this only works if the device supports multicast

    if self.broadcastInputSocket:getsockname() then
        -- test to see if device supports multicast
        self.broadcastInputSocket:setoption("ip-add-membership", { multiaddr = self.multicastIp, interface = getIpAddress() })
    else
        -- the device doesn't support multicast so we'll listen for broadcast
        self.broadcastInputSocket:close()  -- first we close the old socket; this is important
        self.broadcastInputSocket = socket.udp()  -- make a new socket
        self.broadcastInputSocket:setsockname(getIpAddress(), self.broadcastPort)  -- set the socket name to the real IP address
    end

    self.broadcastInputSocket:settimeout(0)

    -- listening socket setup
    self.listenPort = self.broadcastPort + 1

    self.listenSocket = socket.tcp()
    self.listenSocket:bind(getIpAddress(), self.listenPort)
    self.listenSocket:close()

    self.listenSocket = socket.tcp()
    self.listenSocket:bind(getIpAddress(), self.listenPort)
    self.listenSocket:settimeout(0)
    self.listenSocket:listen(1)

    self.acknowledgeTimeout = 0
    self.acknowledgeMessage = "ShadowDuelClientAcknowledge"
end

function module.SecondPlayerFinderSystem:update(delta)
    if globals.socket then
        return
    end

    local currentTime = love.timer.getTime()

    self:checkIncomingConnections()
    self:checkInputMessages()

    if self.connectingClient and self.acknowledgeTimeout > currentTime then
        self:handleConnectingSocket()
        return
    end

    if self.foundClient and self.acknowledgeTimeout > currentTime then
        self:checkAcknowledgeMessage()
        return
    end

    if self.foundClient then
        self.foundClient:close()
    end
    self.acknowledgeTimeout = 0
    self.foundClient = nil

    if self.connectingClient then
        self.connectingClient:close()
    end
    self.connectingClient = nil
    self.connectingClientIp = nil
    self.connectingClientPort = nil

    if (currentTime - self.broadcastLastTime) > 1.0 then
        self:sendBroadcastMessage()
        self.broadcastLastTime = currentTime
    end
end

function module.SecondPlayerFinderSystem:onRemoveFromWorld(world)
    if self.broadcastOutputSocket then
        self.broadcastOutputSocket:close()
    end
    if self.broadcastInputSocket then
        self.broadcastInputSocket:close()
    end
    if self.listenSocket then
        self.listenSocket:close()
    end
    if self.foundClient then
        self.foundClient:close()
    end
end

function module.SecondPlayerFinderSystem:sendBroadcastMessage()
    -- multicast IP range from 224.0.0.0 to 239.255.255.255
    self.broadcastOutputSocket:sendto(self.broadcastMessage, self.multicastIp, self.broadcastPort)

    -- not all devices can multicast so it's a good idea to broadcast too
    -- however, for broadcast to work, the network has to allow it
    self.broadcastOutputSocket:setoption("broadcast", true)  -- turn on broadcast
    self.broadcastOutputSocket:sendto(self.broadcastMessage, self.broadcastIp, self.broadcastPort)
    self.broadcastOutputSocket:setoption("broadcast", false)  -- turn off broadcast
end

function module.SecondPlayerFinderSystem:checkInputMessages()
    local data, ip, port = self.broadcastInputSocket:receivefrom()

    if self.connectingClient or self.foundClient then
        return
    end

    if data and data == self.broadcastMessage then
        if ip ~= getIpAddress() then
            print("I hear a server: [" .. ip .. ":" .. port .. "]. Connecting...")
            self.acknowledgeTimeout = love.timer.getTime() + 1 + math.random()

            self.connectingClient = socket.tcp()
            self.connectingClient:settimeout(0)
            self.connectingClientIp = ip
        end
    end
end

function module.SecondPlayerFinderSystem:checkIncomingConnections()
    if self.foundClient then
        return
    end

    self.foundClient = self.listenSocket:accept()

    if self.foundClient then
        local ip, port = self.foundClient:getpeername()
        print("Got connection from another player: [" .. ip .. ":" .. port .. "].")
        self.acknowledgeTimeout = love.timer.getTime() + 1 + math.random()

        self.foundClient:settimeout(0)
        self.foundClient:setoption("tcp-nodelay", true)
        self.foundClient:send(self.acknowledgeMessage .. "\n")
    end
end

function module.SecondPlayerFinderSystem:handleConnectingSocket()
    local connected, error = self.connectingClient:connect(self.connectingClientIp, self.listenPort)

    if connected or error == "already connected" then
        local ip, port = self.connectingClient:getpeername()
        print("Connected to [" .. ip .. ":" .. port .. "]. Sending acknowledge message...")
        self.acknowledgeTimeout = love.timer.getTime() + 1 + math.random()

        self.foundClient = self.connectingClient
        self.foundClient:setoption("tcp-nodelay", true)
        self.foundClient:send(self.acknowledgeMessage .. "\n")

        self.connectingClient = nil
        self.connectingClientIp = nil
    end
end

function module.SecondPlayerFinderSystem:checkAcknowledgeMessage()
    if not self.foundClient then
        return
    end

    local data = self.foundClient:receive()

    if data and data == self.acknowledgeMessage then
        local ip, port = self.foundClient:getpeername()
        print("Connected: [" .. ip .. ":" .. port .. "].")

        local clientSocket = self.foundClient
        self.foundClient = nil
        --tinyECS.removeSystem(self.world, self)
        globals.socket = clientSocket  -- TODO: remove usage of global variable
    end
end

return module
