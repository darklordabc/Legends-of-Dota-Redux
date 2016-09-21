--------------------------------------------------------------------------------------------------------
--
--		Hero: Antimage
--		Perk: After Anti-Mage blinks he will silence enemies within 200 radius for 2 seconds.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_antimage_perk", "abilities/hero_perks/npc_dota_hero_antimage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_antimage_silence", "abilities/hero_perks/npc_dota_hero_antimage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_antimage_perk == nil then npc_dota_hero_antimage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_antimage_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_antimage_perk == nil then modifier_npc_dota_hero_antimage_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:OnCreated()
	self.radius = 300
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
		if params.unit == self:GetParent() and ( params.ability:HasAbilityFlag("blink") or params.ability:GetName() == "item_blink" ) then
			local silence = params.ability -- For modifier icon
			local cursorPos = params.ability:GetCursorPosition()
			local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), cursorPos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,target in pairs(targets) do
				target:AddNewModifier(self:GetParent(), silence, "modifier_npc_dota_hero_antimage_silence", {duration = self.duration})
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
--		Phase Modifier: 	modifier_npc_dota_hero_spectre_phased		
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_antimage_silence == nil then modifier_npc_dota_hero_antimage_silence = class({}) end
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
