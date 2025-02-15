--!strict
local RunService = game:GetService("RunService")

local events = require("@shared/events")
local fuzz = require("@shared/fuzz")
local unet = require("@unet")

local reliable_server: unet.ServerEvent<fuzz.Person> = unet.undefined("server->client", "server_reliable")
local unreliable_server: unet.ServerEvent<fuzz.Person> =
    unet.undefined("server->client", "server_unreliable", "unreliable")

local reliable_client: unet.ClientEvent<fuzz.Person> = unet.undefined("client->server", "client_reliable")
local unreliable_client: unet.ClientEvent<fuzz.Person> =
    unet.undefined("client->server", "client_unreliable", "unreliable")

local NetTest = {}
NetTest.priority = math.huge

local receive_count = 0

local function print_person(person: fuzz.Person, player: Player?)
    if person == nil then
        return
    end
    assert(player, "[Server] Player doesn't exist wtf?")
    --print(
    --    `[Server] Received person from {player.Name}: name - {person.name}, age - {person.age}, height - {person.height}, sex - {person.sex}`
    --)
    receive_count += 1
end

RunService.Heartbeat:Connect(function(delta_time: number)
    for _, data, player in events.a.reliable_client.poll() do
        print_person(data, player)
    end
    for _, data, player in events.a.unreliable_client.poll() do
        print_person(data, player)
    end
    for _, data, player in events.b.reliable_client.poll() do
        print_person(data, player)
    end
    for _, data, player in events.b.unreliable_client.poll() do
        print_person(data, player)
    end
    for _, data, player in reliable_client.poll() do
        print_person(data, player)
    end
    for _, data, player in unreliable_client.poll() do
        print_person(data, player)
    end
end)

do
    events.a.reliable_client.listen(print_person)
    events.a.unreliable_client.listen(print_person)
    events.b.reliable_client.listen(print_person)
    events.b.unreliable_client.listen(print_person)

    reliable_client.listen(print_person)
    unreliable_client.listen(print_person)

    events.a.loaded.listen(function(_, player)
        assert(player, "where player")
        print("Player loaded in")
        for _ = 1, 1_000 do
            debug.profilebegin("[Server] Sending 4 static events")
            events.a.reliable_server.send(player, fuzz.fuzz_person())
            events.a.unreliable_server.send(player, fuzz.fuzz_person())
            events.b.reliable_server.send(player, fuzz.fuzz_person())
            events.b.unreliable_server.send(player, fuzz.fuzz_person())
            debug.profileend()

            debug.profilebegin("[Server] Sending 2 dynamic events")
            reliable_server.send(player, fuzz.fuzz_person())
            unreliable_server.send(player, fuzz.fuzz_person())
            debug.profileend()
        end
    end)

    task.wait(5)
    print(`[Server] Total receive count: {receive_count}`)
end
