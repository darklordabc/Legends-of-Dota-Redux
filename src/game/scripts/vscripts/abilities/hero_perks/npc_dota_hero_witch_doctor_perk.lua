--------------------------------------------------------------------------------------------------------
--
--		Hero: Witch Doctor
--		Perk: Increases Witch Doctor's healing effectiveness by 25%. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_witch_doctor_perk", "abilities/hero_perks/npc_dota_hero_witch_doctor_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_witch_doctor_perk == nil then npc_dota_hero_witch_doctor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_witch_doctor_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_witch_doctor_perk == nil then modifier_npc_dota_hero_witch_doctor_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsHidden()
	return true
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
function modifier_npc_dota_hero_witch_doctor_perk:OnHealReceived(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local inflictor = keys.inflictor -- Heal ability
		local unit = keys.unit 
		local amount = keys.gain -- Amount healed

		if inflictor then
			-- vscript error occurs saying this is nil, but it is not
			local healer = inflictor:GetCaster()
			if healer then
				if healer == caster then
					amount = amount * 0.25
					if unit:GetHealthPercent() < 100 then
						unit:PopupNumbers(unit, "heal", Vector(10, 255, 10), 3.0, math.floor(amount), 0, nil)
					end
					unit:Heal(amount, caster)
				end
			end
		end	
	end
	return true
end
--------------------------------------------------------------------------------------------------------
