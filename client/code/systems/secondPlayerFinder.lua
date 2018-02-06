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

    self.broadcastSocket = socket.udp()
    self.broadcastSocket:settimeout(0)

    self.listenSocket = socket.udp()
    self.listenSocket:setsockname(self.multicastIp, self.broadcastPort)  -- this only works if the device supports multicast

    if self.listenSocket:getsockname() then
        -- test to see if device supports multicast
        self.listenSocket:setoption("ip-add-membership", { multiaddr = self.multicastIp, interface = getIpAddress() })
    else
        -- the device doesn't support multicast so we'll listen for broadcast
        self.listenSocket:close()  -- first we close the old socket; this is important
        self.listenSocket = socket.udp()  -- make a new socket
        self.listenSocket:setsockname(getIpAddress(), self.broadcastPort)  -- set the socket name to the real IP address
    end

    self.listenSocket:settimeout(0)
end

function module.SecondPlayerFinderSystem:update(delta)
    local currentTime = love.timer.getTime()

    if currentTime - self.broadcastLastTime > 1.0 then
        self:sendBroadcastMessage()
        self.broadcastLastTime = currentTime
    end

    self:checkInputMessages()
end

function module.SecondPlayerFinderSystem:onRemoveFromWorld(world)
    if self.broadcastSocket then self.broadcastSocket:close() end
    if self.listenSocket then self.listenSocket:close() end
end

function module.SecondPlayerFinderSystem:sendBroadcastMessage()
    -- multicast IP range from 224.0.0.0 to 239.255.255.255
    self.broadcastSocket:sendto(self.broadcastMessage, self.multicastIp, self.broadcastPort)

    -- not all devices can multicast so it's a good idea to broadcast too
    -- however, for broadcast to work, the network has to allow it
    self.broadcastSocket:setoption("broadcast", true)  -- turn on broadcast
    self.broadcastSocket:sendto(self.broadcastMessage, self.broadcastIp, self.broadcastPort)
    self.broadcastSocket:setoption("broadcast", false)  -- turn off broadcast
end

function module.SecondPlayerFinderSystem:checkInputMessages()
    local data, ip, port = self.listenSocket:receivefrom()

    if data and data == self.broadcastMessage then
        if ip ~= getIpAddress() then
            print("I hear a server: [" .. ip .. ":" .. port .. "].")
        else
            print("I hear myself.")
        end
    end
end

return module
