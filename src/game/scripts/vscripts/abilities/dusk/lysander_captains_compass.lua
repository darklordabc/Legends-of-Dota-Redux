lysander_captains_compass = class({})

LinkLuaModifier("modifier_captains_compass","abilities/dusk/lysander_captains_compass",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_captains_compass_buff_show","abilities/dusk/lysander_captains_compass",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_captains_compass_buff","abilities/dusk/lysander_captains_compass",LUA_MODIFIER_MOTION_NONE)

function lysander_captains_compass:OnSpellStart()
	local t = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")

	if t:TriggerSpellAbsorb(self) then return end
	t:TriggerSpellReflect(self)

	local mod = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_captains_compass_buff", {Duration=duration}) --[[Returns:void
	No Description Set
	]]

	local tmod = t:AddNewModifier(self:GetCaster(), self, "modifier_captains_compass", {Duration=duration}) --[[Returns:void
	No Description Set
	]]
	t:AddNewModifier(self:GetCaster(), self, "modifier_truesight", {Duration=duration}) --[[Returns:void
	No Description Set
	]]
end

modifier_captains_compass_buff = class({})

function modifier_captains_compass_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_captains_compass_buff:GetModifierMoveSpeedBonus_Percentage()
	local movespeed = self:GetAbility():GetSpecialValueFor("movespeed")

	if IsServer() then
		local en = FindUnitsInRadius( self:GetParent():GetTeamNumber(),
	                            self:GetParent():GetAbsOrigin(),
	                            nil,
	                            1700,
	                            DOTA_UNIT_TARGET_TEAM_ENEMY,
	                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
	                            DOTA_UNIT_TARGET_FLAG_NONE,
	                            FIND_CLOSEST,
	                            false)

		local t = nil

		for k,v in pairs(en) do
			if v:HasModifier("modifier_captains_compass") then
				t = v
			end
		end

		if t then

			local d = self:GetParent():GetRangeToUnit(t) --[[Returns:float
			No Description Set
			]]

			local max_distance = 1700

			local f = (1 - (d/max_distance)) * 100

			f = math.floor(f)

			if f < 0 then f = 0 end

			self:SetStackCount(f)
		end
	end

	return (self:GetStackCount()/100) * movespeed
end

function modifier_captains_compass_buff:GetModifierAttackSpeedBonus_Constant()
	local attackspeed = self:GetAbility():GetSpecialValueFor("movespeed")
	
	return attackspeed * (self:GetStackCount()/100)
end

function modifier_captains_compass_buff:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_captains_compass_buff_show", {Duration=self:GetDuration()}) --[[Returns:void
		No Description Set
		]]
	end
end

function modifier_captains_compass_buff:IsHidden()
	return true
end

modifier_captains_compass_buff_show = class({})

modifier_captains_compass = class({})

function modifier_captains_compass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end

function modifier_captains_compass:GetModifierProvidesFOWVision()
	return 1
end

function modifier_captains_compass:IsDebuff()
	return true
end

function modifier_captains_compass:GetEffectName()
	return "particles/units/heroes/hero_lysander/captains_compass.vpcf"
end