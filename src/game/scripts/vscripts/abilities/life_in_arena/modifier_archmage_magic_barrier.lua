modifier_archmage_magic_barrier = class({})

function modifier_archmage_magic_barrier:IsHidden()
	--if self:GetAbility().barrierMana <= 0 then
	--	return true 
	--else 
		return false 
	--end
end

function modifier_archmage_magic_barrier:IsPurgable()
	return false
end

function modifier_archmage_magic_barrier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH,
	}
 
	return funcs
end

function modifier_archmage_magic_barrier:OnCreated(kv)
	self.barrierManaPercent = self:GetAbility():GetSpecialValueFor("lol")*0.01
	self.barrierManaLoss = self:GetAbility():GetSpecialValueFor("lol1")/2
	self:StartIntervalThink(0.5)

	if not self:GetAbility().barrierMana then
		self:GetAbility().barrierMana = 0
	end
end

function modifier_archmage_magic_barrier:OnRefresh(kv)
	self.barrierManaPercent = self:GetAbility():GetSpecialValueFor("lol")*0.01
	self.barrierManaLoss = self:GetAbility():GetSpecialValueFor("lol1")/2
end

function modifier_archmage_magic_barrier:GetBlockedDamage(attack_damage)
	local ability = self:GetAbility()
	local blocked_damage = 0 
	
	if ability.barrierMana == 0 then
		return 0 
	end

	if ability.barrierMana > attack_damage then 
		blocked_damage = attack_damage
	else
		blocked_damage = ability.barrierMana
	end

	ability.barrierMana = ability.barrierMana - blocked_damage
	CustomNetTables:SetTableValue("custom_modifier_state", tostring( ability:GetEntityIndex() ) ,{ barrierMana = ability.barrierMana })

	return blocked_damage
end

function modifier_archmage_magic_barrier:OnAbilityExecuted(params)
	if params.unit == self:GetCaster() then
		local eventAbility = params.ability 

		if eventAbility:IsItem() then
			return 
		end

		self:GetAbility().barrierMana = self:GetAbility().barrierMana + eventAbility:GetManaCost(-1)*self.barrierManaPercent
		CustomNetTables:SetTableValue("custom_modifier_state",tostring(self:GetAbility():GetEntityIndex()),{ barrierMana = self:GetAbility().barrierMana })
		--print("Archmage[Mana barrier]: Added "..eventAbility:GetManaCost(-1)*self.barrierManaPercent.." mana",self:GetAbility().barrierMana)
	end
end

function modifier_archmage_magic_barrier:OnIntervalThink()
	local ability = self:GetAbility()

	if IsServer() then
		if ability.barrierMana < self.barrierManaLoss then
			ability.barrierMana = 0
		else
			ability.barrierMana = ability.barrierMana - self.barrierManaLoss
		end

		local parent = self:GetParent()

		if ability.barrierMana > 0 then
			local shield_size = 75
			
			if parent.magicBarrerParticle == nil then
				local particle = ParticleManager:CreateParticle("particles/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			
				ParticleManager:SetParticleControl(particle, 1, Vector(shield_size,0,shield_size))
				ParticleManager:SetParticleControl(particle, 2, Vector(shield_size,0,shield_size))
				ParticleManager:SetParticleControl(particle, 4, Vector(shield_size,0,shield_size))
				ParticleManager:SetParticleControl(particle, 5, Vector(shield_size,0,0))
				ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
				
				parent.magicBarrerParticle = particle

			end	
		elseif ability.barrierMana == 0 and parent.magicBarrerParticle ~= nil then
			ParticleManager:DestroyParticle(parent.magicBarrerParticle,true)
			parent.magicBarrerParticle = nil
		end

		CustomNetTables:SetTableValue("custom_modifier_state", tostring( ability:GetEntityIndex() ) ,{ barrierMana = ability.barrierMana })
	else
		local netTable = CustomNetTables:GetTableValue("custom_modifier_state", tostring( ability:GetEntityIndex() ) )

		if netTable then
			self.barrierMana = netTable.barrierMana
		end
		--print(ability.barrierMana,"client side")
	end


	return 0.5
end


function modifier_archmage_magic_barrier:OnDeath(params)
	if self:GetParent().magicBarrerParticle ~= nil then
		ParticleManager:DestroyParticle(self:GetParent().magicBarrerParticle,true)
		self:GetParent().magicBarrerParticle = nil
	end
	if params.unit == self:GetParent() then
		self:GetAbility().target = nil
		CustomNetTables:SetTableValue("custom_modifier_state", tostring( self:GetAbility():GetEntityIndex().."behavior" ), 
			{ behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET } )
		if self:GetCaster():IsAlive() then
			self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_archmage_magic_barrier",nil)
		end
	end
end



function modifier_archmage_magic_barrier:OnTooltip(params)
	return self.barrierMana
end

function modifier_archmage_magic_barrier:OnDestroy()
	if self:GetParent().magicBarrerParticle ~= nil then
		ParticleManager:DestroyParticle(self:GetParent().magicBarrerParticle,true)
		self:GetParent().magicBarrerParticle = nil
	end
end