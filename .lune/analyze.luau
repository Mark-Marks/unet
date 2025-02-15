--!strict
local spawn = require("util/spawn")

spawn.start("lune run install-packages")
spawn.start("rojo sourcemap dev.project.json -o sourcemap.json")
spawn.start(
    "curl https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/refs/heads/main/scripts/globalTypes.RobloxScriptSecurity.d.luau -o globalTypes.d.luau"
)
spawn.start(
    "luau-lsp analyze --definitions=globalTypes.d.luau --base-luaurc=.luaurc --sourcemap=sourcemap.json --settings=luau_lsp_settings.json --no-strict-dm-types --ignore **/_Index/** --ignore lib/blink_client.luau --ignore lib/blink_server.luau lib/"
)
