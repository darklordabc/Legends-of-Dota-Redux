--------------------------------------------------------------------------------------------------------
--
--		Hero: Enchantress
--		Perk: Enchantress can creates plants without the health penalty. 
--		Note: Perk code is located in the Cherub's abilities, like Flower Garden, code. 
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_enchantress_perk", "abilities/hero_perks/npc_dota_hero_enchantress_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_enchantress_perk ~= "" then npc_dota_hero_enchantress_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_enchantress_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_enchantress_perk ~= "" then modifier_npc_dota_hero_enchantress_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enchantress_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_enchantress_perk:DeclareFunctions() 
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_npc_dota_hero_enchantress_perk:OnAttackLanded(k)
	if k.attacker ~= self:GetParent() then return end
	if k.target:IsHero() then
		if self:GetStackCount() <= 5 then
			self:IncrementStackCount()
			Timers:CreateTimer(10,function()
				self:DecrementStackCount()
			end)
		end
	end
end

function modifier_npc_dota_hero_enchantress_perk:GetModifierAttackRangeBonus()
	return self:GetStackCount() * 50
end

