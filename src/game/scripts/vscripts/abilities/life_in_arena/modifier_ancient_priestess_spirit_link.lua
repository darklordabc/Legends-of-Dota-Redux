modifier_ancient_priestess_spirit_link = class({})

if IsServer() then
	require('utils')
end

function modifier_ancient_priestess_spirit_link:GetEffectName()
	return "particles/wisp_overcharge_custom.vpcf"
end

function modifier_ancient_priestess_spirit_link:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ancient_priestess_spirit_link:IsBuff() 
	return true 
end

function modifier_ancient_priestess_spirit_link:IsPurgable() 
	return true 
end

function modifier_ancient_priestess_spirit_link:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
 
	return funcs
end

function modifier_ancient_priestess_spirit_link:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_ancient_priestess_spirit_link:OnCreated(kv)
	self.health_regen = self:GetAbility():GetSpecialValueFor("heal_value")
	self.distr_factor = self:GetAbility():GetSpecialValueFor("distribution_factor")
end

if IsServer() then
	function modifier_ancient_priestess_spirit_link:OnDestroy()
		table.remove(self.tTargets,getIndex(self.tTargets, self:GetParent()))
	end


	function modifier_ancient_priestess_spirit_link:LinkDamage(attack_damage,damage_type,attacker,ability) --эта функция вызывается из фильтра урона и возращает кол-во заблокированного(переданого остальным юнитам) урона
		local parent = self:GetParent()
		local nLinkedUnits = #self.tTargets
		local damage = attack_damage*self.distr_factor
		local linked_damage = damage/nLinkedUnits
		local inflictor
		if ability then
			inflictor = ability 
		else 
			inflictor = self:GetAbility()
		end


		if nLinkedUnits == 1 then
			return 0
		end

		local blocked_damage = 0

		for _,unit in pairs(self.tTargets) do
			if unit ~= parent then 
				if unit:GetHealthPercent() > 25 then
					unit.spiritLink_damage = true
					--print("Link Damage by",parent:GetUnitName(),"to",unit:GetUnitName(),attacker:GetUnitName(),attack_damage,linked_damage)
					ApplyDamage({victim = unit, attacker = attacker, damage = linked_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = inflictor, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
					--print("Link Damage end")
					blocked_damage = blocked_damage + linked_damage
				end
			end
		end

		return blocked_damage
	end
	
end