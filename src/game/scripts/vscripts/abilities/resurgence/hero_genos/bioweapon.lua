LinkLuaModifier("modifier_bioweapon_debuff", "heroes/hero_genos/modifiers/modifier_bioweapon_debuff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bioweapon_buff", "heroes/hero_genos/modifiers/modifier_bioweapon_buff.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: May 16, 2017
    ]]

function CheckMana(event)
	local caster = event.caster
	local ability = event.ability

	local level = (ability:GetLevel() - 1)

	local mana_needed = ability:GetManaCost(level) + 0.1*(caster:GetMaxMana()) --ability:GetLevelSpecialValueFor("mana", (ability:GetLevel() - 1))
	local mana_have = caster:GetMana()

	if mana_have < mana_needed then
		caster:Stop()
	end
end

-- 
function Launch( event )
	local caster = event.caster
    local ability = event.ability
    local land_point = event.target_points[1]

    caster:SetMana(caster:GetMana() - (caster:GetMaxMana())*0.1)

    local ability_level = ability:GetLevel() - 1
    local dur = ability:GetLevelSpecialValueFor("duration", ability_level)
    local speed = ability:GetLevelSpecialValueFor("speed", ability_level)
    local start_location = caster:GetAbsOrigin()
    local radius = ability:GetLevelSpecialValueFor("radius", ability_level)

    local land_time = ((land_point-start_location):Length2D())/speed

    caster:AddNewModifier(caster, ability, "modifier_bioweapon_buff", {duration = dur})
    caster.projectile_target = CreateUnitByName("eye_of_the_moon_dummy", land_point, false, caster, caster, caster:GetTeamNumber())
    caster:EmitSound("Hero_Brewmaster.ThunderClap.Target")

    local info = {
                    Target = caster.projectile_target,
                    Source = caster,
                    Ability = ability,
                    EffectName = "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_nasal_goo_proj.vpcf",--"particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_diving_helmet.vpcf",
                    bDodgeable = false,
                    bProvidesVision = true,
                    iMoveSpeed = speed,
                    iVisionRadius = 0,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                }
    ProjectileManager:CreateTrackingProjectile( info )

    Timers:CreateTimer(land_time, function ()

    	AddFOWViewer(caster:GetTeamNumber(), land_point, radius, 1, false)
        caster.projectile_target:EmitSound("Hero_Batrider.StickyNapalm.Impact")

        local hero_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                                 land_point,
                                 nil,
                                 radius,
                                 DOTA_UNIT_TARGET_TEAM_ENEMY,
                                 DOTA_UNIT_TARGET_HERO,
                                 DOTA_UNIT_TARGET_FLAG_NONE,
                                 FIND_ANY_ORDER,
                                 false)

        local creep_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                                 land_point,
                                 nil,
                                 radius,
                                 DOTA_UNIT_TARGET_TEAM_ENEMY,
                                 DOTA_UNIT_TARGET_BASIC,
                                 DOTA_UNIT_TARGET_FLAG_NONE,
                                 FIND_ANY_ORDER,
                                 false)

        for _,unit in pairs(hero_enemies) do
                if not unit:IsMagicImmune() then
                    unit:AddNewModifier(caster, ability, "modifier_bioweapon_debuff", {duration = dur})

                    unit:EmitSound("Hero_Brewmaster.ThunderClap.Target")

                    local info = {
                                    Target = unit,
                                    Source = caster.projectile_target,
                                    Ability = ability,
                                    EffectName = "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_nasal_goo_proj.vpcf",--"particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_diving_helmet.vpcf",
                                    bDodgeable = false,
                                        bProvidesVision = true,
                                        iMoveSpeed = 6000,
                                    iVisionRadius = 0,
                                    iVisionTeamNumber = caster:GetTeamNumber(),
                                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                                }
                    ProjectileManager:CreateTrackingProjectile( info )
                end
        end

        for _,unit in pairs(creep_enemies) do
                if not unit:IsMagicImmune() then
                    unit:AddNewModifier(caster, ability, "modifier_bioweapon_debuff", {duration = dur})

                    unit:EmitSound("Hero_Brewmaster.ThunderClap.Target")

                    --[[
                    local splash = ParticleManager:CreateParticle("particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_diving_helmet.vpcf", PATTACH_WORLDORIGIN, caster)
                    ParticleManager:SetParticleControl(splash,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))   
                    ParticleManager:SetParticleControl(splash,1,Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
                    ParticleManager:SetParticleControl(splash,3,Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
                    ParticleManager:SetParticleControl(splash,32,Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
                    --]]

                    local info = {
                                    Target = unit,
                                    Source = caster.projectile_target,
                                    Ability = ability,
                                    EffectName = "particles/econ/items/bristleback/ti7_head_nasal_goo/bristleback_ti7_nasal_goo_proj.vpcf",--"particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_diving_helmet.vpcf",
                                    bDodgeable = false,
                                        bProvidesVision = true,
                                        iMoveSpeed = 3000,
                                    iVisionRadius = 0,
                                    iVisionTeamNumber = caster:GetTeamNumber(),
                                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                                }
                    ProjectileManager:CreateTrackingProjectile( info )
                end
        end
        caster.projectile_target:RemoveSelf()
    end)
end