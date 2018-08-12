--------------------------------------------------------------------------------------------------------
--
--		Hero: Doom Bringer
--		Perk: Doom will always cast doom as if he has scepter, with scepter cooldown reduced by 50%
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_doom_bringer_perk", "abilities/hero_perks/npc_dota_hero_doom_bringer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_doom_bringer_perk_dummy", "abilities/hero_perks/npc_dota_hero_doom_bringer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_doom_bringer_perk ~= "" then npc_dota_hero_doom_bringer_perk = class({}) end

function npc_dota_hero_doom_bringer_perk:GetIntrinsicModifierName()
	return "modifier_npc_dota_hero_doom_bringer_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_doom_bringer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_doom_bringer_perk ~= "" then modifier_npc_dota_hero_doom_bringer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:OnCreated(keys)
	self.cooldownPercentReduction = 50
	self.cooldownReduction = self.cooldownPercentReduction / 100
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:DeclareFunctions()
	local funcs = {
	  MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:GetAbilityName() == "doom_bringer_doom" then
    	if hero:HasScepter() then
		  	local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
	      	ability:EndCooldown()
	      	ability:StartCooldown(cooldown)
	    else
	    	Timers:CreateTimer(1,function()
	    		local modifier = target:AddNewModifier(hero,ability,"modifier_npc_dota_hero_doom_bringer_perk_dummy",{duration = -1 + ability:GetSpecialValueFor("duration")})
	    	end)
	    end
	end
  end
end

--------------------------------------------------------------------------------------------------------

modifier_npc_dota_hero_doom_bringer_perk_dummy = class({})

function modifier_npc_dota_hero_doom_bringer_perk_dummy:IsHidden() return true end
function modifier_npc_dota_hero_doom_bringer_perk_dummy:IsPurgable() return false end

function modifier_npc_dota_hero_doom_bringer_perk_dummy:OnCreated()
	if IsClient() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_npc_dota_hero_doom_bringer_perk_dummy:OnIntervalThink()
	local hero = self:GetCaster()
	local unit = self:GetParent()
	local ability = self:GetAbility()	

	if hero:GetRangeToUnit(unit) < 900 then
		local modifier = unit:FindModifierByNameAndCaster("modifier_doom_bringer_doom",hero)
		if modifier then
			modifier:SetDuration(modifier:GetRemainingTime()+FrameTime(),true)
			self:SetDuration(modifier:GetRemainingTime()+FrameTime(),false)
		else
			self:Destroy()
		end
	end
end

function modifier_npc_dota_hero_doom_bringer_perk_dummy:CheckState()
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
end