--------------------------------------------------------------------------------------------------------
--
--		Hero: Antimage
--		Perk: After Anti-Mage blinks he will silence enemies within 200 radius for 2 seconds.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_antimage_perk", "abilities/hero_perks/npc_dota_hero_antimage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_antimage_silence", "abilities/hero_perks/npc_dota_hero_antimage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_antimage_perk ~= "" then npc_dota_hero_antimage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_antimage_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_antimage_perk ~= "" then modifier_npc_dota_hero_antimage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:OnCreated()
	self.radius = 200
	self.duration = 2
end

function modifier_npc_dota_hero_antimage_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_npc_dota_hero_antimage_perk:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit ~= self:GetParent() then return end
		if params.ability:HasAbilityFlag("blink") then
			local silence = params.ability -- For modifier icon
			Timers:CreateTimer(function()
				if not silence or silence:IsNull() then return end
				local pos = self:GetParent():GetAbsOrigin()
				local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
				for _,target in pairs(targets) do
					target:AddNewModifier(self:GetParent(), silence, "modifier_npc_dota_hero_antimage_silence", {duration = self.duration})
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------------------------------
--		Phase Modifier: 	modifier_npc_dota_hero_antimage_silence		
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_antimage_silence ~= "" then modifier_npc_dota_hero_antimage_silence = class({}) end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_antimage_silence:CheckState()
	local state = {
	[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end

function modifier_npc_dota_hero_antimage_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_npc_dota_hero_antimage_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
