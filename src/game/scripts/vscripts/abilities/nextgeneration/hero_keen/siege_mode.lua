LinkLuaModifier("modifier_siege_mode_no_movement","abilities/nextgeneration/hero_keen/modifiers/modifier_siege_mode_no_movement.lua",LUA_MODIFIER_MOTION_NONE)

function MinAttackRange (keys)
	local caster = keys.caster
	local target = keys.target

	if target and caster:HasModifier("modifier_siege_mode") and (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() < 400 then
		caster:Hold()
	end
end

function SplashAttack (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = caster:FindAbilityByName("keen_commander_siege_mode")
	local radius = ability:GetLevelSpecialValueFor("splash_radius",ability:GetLevel() -1 )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, 0, 0, false )
	
	for _,unit in pairs( units ) do
		if unit ~= target then
			local DamageTable = 
			{
				attacker = caster,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage = caster:GetAverageTrueAttackDamage(unit),
				victim = unit
			}
			ApplyDamage(DamageTable)
		end
	end
end

--[[
function GetGuerrillaModeSpell (keys)
	local caster = keys.caster
	local ability = "keen_commander_siege_mode"
	local swapability = "keen_commander_guerrilla_mode"
	local mortar_shot = "keen_commander_mortar_shot"
	local mortar_shot_siege = "keen_commander_mortar_shot_siege"

	model = caster:GetModelName()
	print(model)

	caster:SwapAbilities(ability,swapability,false,true)
	--caster:AddNewModifier(caster,nil,"modifier_siege_mode_no_movement",{})

end

function GetSiegeModeSpell (keys)
	local caster = keys.caster
	local swapability = "keen_commander_siege_mode"
	local ability = "keen_commander_guerrilla_mode"
	local mortar_shot = "keen_commander_mortar_shot"
	local mortar_shot_siege = "keen_commander_mortar_shot_siege"

	caster:SwapAbilities(ability,swapability,false,true)
	--caster:RemoveModifierByName("modifier_siege_mode_no_movement")
end
]]--