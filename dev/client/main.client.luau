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

local receive_count = 0

local function print_person(person: fuzz.Person)
    if person == nil then
        return
    end
    --print(
    --    `[Client] Received person: name - {person.name}, age - {person.age}, height - {person.height}, sex - {person.sex}`
    --)
    receive_count += 1
end

RunService.Heartbeat:Connect(function(delta_time: number)
    for _, data in events.a.reliable_server.poll() do
        print_person(data)
    end
    for _, data in events.a.unreliable_server.poll() do
        print_person(data)
    end
    for _, data in events.b.reliable_server.poll() do
        print_person(data)
    end
    for _, data in events.b.unreliable_server.poll() do
        print_person(data)
    end
    for _, data in reliable_server.poll() do
        print_person(data)
    end
    for _, data in unreliable_server.poll() do
        print_person(data)
    end
end)

do
    events.a.loaded.send()
    print("sent loaded")

    events.a.reliable_server.listen(print_person)
    events.a.unreliable_server.listen(print_person)
    events.b.reliable_server.listen(print_person)
    events.b.unreliable_server.listen(print_person)

    reliable_server.listen(print_person)
    unreliable_server.listen(print_person)

    for _ = 1, 1_000 do
        debug.profilebegin("[Client] Sending 4 static events")
        events.a.reliable_client.send(fuzz.fuzz_person())
        events.a.unreliable_client.send(fuzz.fuzz_person())
        events.b.reliable_client.send(fuzz.fuzz_person())
        events.b.unreliable_client.send(fuzz.fuzz_person())
        debug.profileend()

        debug.profilebegin("[Client] Sending 2 dynamic events")
        reliable_client.send(fuzz.fuzz_person())
        unreliable_client.send(fuzz.fuzz_person())
        debug.profileend()
    end

    task.wait(5)
    print(`[Client] Total receive count: {receive_count}`)
end
