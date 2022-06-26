--ensure that we only create xrayed refinery entity when the mod is installed
if mods["248k"] then
    --248k refinery xray
    local fi_refinery_xray = table.deepcopy(data.raw['assembling-machine']['fi_refinery_entity'])
    fi_refinery_xray.name = 'fi_refinery_entity-xray'
    fi_refinery_xray.animation.draw_as_shadow = true
    data:extend{fi_refinery_xray}
end