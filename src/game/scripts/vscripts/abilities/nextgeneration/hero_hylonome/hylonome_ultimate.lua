function Ultimate( keys )
    local caster = keys.caster
    local ability = keys.ability
    local unit_name = "npc_dota_hylonome_tentacle"
    local unit_count = 1
    local caster_origin = caster:GetAbsOrigin()

    --[[local vSpawnPos = {
        Vector( 150, -150, 0 ),
        Vector( 350, 0, 0 ),
        Vector( 150, 150, 0 ),
        Vector( -150, 150, 0 ),
        Vector( -350, 0, 0 ),
        Vector( -150, -150, 0 ),
        Vector( 0, 350, 0 ),
        Vector( 0, -350, 0 ),
    }]]

    for i=1, unit_count do
        --local origin = caster_origin + table.remove( vSpawnPos, 1 )
        --local unit = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
        unit = CreateUnitByName(unit_name, caster_origin, false, caster, nil, caster:GetTeamNumber())
        ability:ApplyDataDrivenModifier(caster, unit, "modifier_hylonome_unit", {})
        unit:AddNewModifier(unit, ability, "modifier_kill", {duration = 10, })
    end
end

function Chronosphere( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability
    local target_point = keys.target_points[1]

    -- Special Variables
    local duration = 10 --ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

    -- Dummy
    local dummy_modifier = keys.dummy_aura
    local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
    dummy:AddNewModifier(caster, nil, "modifier_phased", {})
    ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})

    -- Vision
    --AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), 400, duration, false)
end

function killDummy( keys )
    keys.target:RemoveSelf()
end