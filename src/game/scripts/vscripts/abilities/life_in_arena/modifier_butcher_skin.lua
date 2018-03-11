modifier_butcher_skin = class ({})
if IsServer() then
	require('abilities/life_in_arena/utils') 
end


function modifier_butcher_skin:IsHidden()
	return true
end

function modifier_butcher_skin:IsPurgable()
	return false
end

function modifier_butcher_skin:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
 
	return funcs
end

function modifier_butcher_skin:GetModifierPhysicalArmorBonus(params)
	return self.bonus_armor
end

function modifier_butcher_skin:OnCreated(kv)
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_butcher_skin:OnRefresh(kv)
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_butcher_skin:OnAttackLanded(params) 
	if IsServer() then
		if params.target == self:GetParent() and not self:GetParent():HasModifier("modifier_illusion") then 
			self.attack_record = params.record 
			self.ranged_attack = params.ranged_attack
		end 
	end
end


function modifier_butcher_skin:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() and not self:GetParent():HasModifier("modifier_illusion") and not IsFlagSet(params.damage_flags,DOTA_DAMAGE_FLAG_REFLECTION) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			if self.attack_record == params.record and not self.ranged_attack then
				local target = params.unit
				local return_damage = self:GetAbility():GetSpecialValueFor("damage_return")*0.01*params.damage
				ApplyDamage(
				{
					victim = params.attacker, 
					attacker = target, 
					damage = return_damage, 
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
					ability = params.ability
				})
			end
		end
	end
end