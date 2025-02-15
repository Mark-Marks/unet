--!strict
local unet = require("@unet")
local t = unet.data_types

local person_structure = t.record({
    name = t.string(20),
    age = t.uint(1),
    height = t.uint(1),
    sex = t.string(6),
})

return {
    a = unet.define_namespace("A", {
        reliable_server = unet.defined("server->client", person_structure),
        reliable_client = unet.defined("client->server", person_structure),

        unreliable_server = unet.defined("server->client", person_structure, "unreliable"),
        unreliable_client = unet.defined("client->server", person_structure, "unreliable"),

        loaded = unet.defined("client->server", t["nil"]()),
    }),

    b = unet.define_namespace("B", {
        reliable_server = unet.defined("server->client", person_structure),
        reliable_client = unet.defined("client->server", person_structure),

        unreliable_server = unet.defined("server->client", person_structure, "unreliable"),
        unreliable_client = unet.defined("client->server", person_structure, "unreliable"),
    }),
}
