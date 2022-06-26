require('whitelist')

local function suffixed(str, ending) -- Taken from bulk-teleport
	return ending == "" or str:sub(-#ending) == ending
end

local function swap(name, old, surface, player)
    local newBuilding = surface.create_entity({
        name = name,
        position = old.position,
        force = old.force,
        raise_built = false,
        create_build_effect_smoke = false,
        spawn_decorations = false
    })

    if old.to_be_deconstructed() then
        newBuilding.order_deconstruction(player.force, player)
    end

    return newBuilding
end

local Enabled = true

local function updatePlayerXray(playerIndex)
    if Enabled == true then
        local player = game.get_player(playerIndex)
        local radius = 9
        local surface = player.surface

        local machines = surface.find_entities_filtered{position = player.position, radius = radius}

        for _, machine in ipairs(machines) do
            for _, Whitelisted in pairs(xrayBuildingWhitelist) do
                if Whitelisted == machine.name then
                    local newMachine = swap(machine.name .. '-xray', machine, surface, player)

                    machine.destroy({raise_destroy = false})

                    if not global.players_xray[playerIndex] then
                        global.players_xray[playerIndex] = {}
                    end
                    table.insert(global.players_xray[playerIndex], newMachine)
                end
            end
        end

        if global.players_xray[playerIndex] then
            local player = game.get_player(playerIndex)
            for index, machine in pairs(global.players_xray[playerIndex]) do
                if machine.valid then
                    local dx = machine.position.x - player.position.x
                    local dy = machine.position.y - player.position.y

                    if dx * dx + dy * dy > radius * radius then
                        swap(machine.name:sub(1, -6), machine, surface, player)

                        machine.destroy({raise_destroy = false})

                        global.players_xray[playerIndex][index] = nil
                    end
                else
                    global.players_xray[playerIndex][index] = nil
                end
            end
        end
    else
        if global.players_xray[playerIndex] then
            local player = game.get_player(playerIndex)
            local surface = player.surface
            for index, machine in pairs(global.players_xray[playerIndex]) do
                if machine.valid then
                    swap(machine.name:sub(1, -6), machine, surface, player)
                    machine.destroy({raise_destroy = false})
                end
                global.players_xray[playerIndex][index] = nil
            end
        end
    end
end

local function init()
    global.players_xray = global.players_xray or {}
    global.moving_player = global.moving_player or {}
    global.player_xray_toggle = global.player_xray_toggle or {}
end

script.on_init(
    function()
        init()
    end
)

script.on_load(
    function()
        init()
    end
)

script.on_event(defines.events.on_lua_shortcut,
    function(event)
        if event.prototype_name == "x-ray-toggle" then
           Enabled = not Enabled
           updatePlayerXray(event.player_index)
        end
    end
)

script.on_event(defines.events.on_player_changed_position,
    function(event)
        updatePlayerXray(event.player_index)
    end
)