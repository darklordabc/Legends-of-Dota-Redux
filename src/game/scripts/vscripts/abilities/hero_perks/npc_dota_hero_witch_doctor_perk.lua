--------------------------------------------------------------------------------------------------------
--
--		Hero: Witch Doctor
--		Perk: Healing abilities have 25% extra effectiveness when used by Witch Doctor.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_witch_doctor_perk", "abilities/hero_perks/npc_dota_hero_witch_doctor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_witch_doctor_perk ~= "" then npc_dota_hero_witch_doctor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_witch_doctor_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_witch_doctor_perk ~= "" then modifier_npc_dota_hero_witch_doctor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:DeclareFunctions()
	return { MODIFIER_EVENT_ON_HEAL_RECEIVED }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:OnCreated()
	if IsServer() then
		self.bonusHealPercent = 25
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:OnHealReceived(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local inflictor = keys.inflictor -- Heal ability
		local unit = keys.unit 
		local amount = keys.gain -- Amount healed

		if inflictor and inflictor ~= self:GetAbility() then
			local healSpell = caster:FindAbilityByName(inflictor:GetName())
			if not healSpell then return end
			local healer = inflictor:GetCaster()
			if healer then
				if healer == caster then
					amount = amount * (self.bonusHealPercent / 100)
					if unit:GetHealthPercent() < 100 then
						SendOverheadEventMessage( unit, OVERHEAD_ALERT_HEAL , unit, amount, nil )
						-- unit:PopupNumbers(unit, "heal", Vector(10, 255, 10), 3.0, math.floor(amount), 0, nil)
					end
					unit:Heal(amount, self:GetAbility())
				end
			end
		end	
	end
	return true
end
--------------------------------------------------------------------------------------------------------
