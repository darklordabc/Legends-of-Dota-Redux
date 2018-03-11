ancient_priestess_ritual_protection = class({})
LinkLuaModifier("modifier_ancient_priestess_ritual_protection", "abilities/life_in_arena/modifier_ancient_priestess_ritual_protection.lua",LUA_MODIFIER_MOTION_NONE)

function ancient_priestess_ritual_protection:OnSpellStart() 
	local caster = self:GetCaster() 

	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")

	local targets = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false )

	for _,unit in pairs(targets) do 
		unit:AddNewModifier(caster, self, "modifier_ancient_priestess_ritual_protection", {duration = duration})
		ParticleManager:CreateParticle("particles/mirana_moonlight_ray_custom.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)

	end

	EmitSoundOn("Ability.MoonlightShadow", caster)
end