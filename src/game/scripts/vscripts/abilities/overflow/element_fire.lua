if element_fire == nil then
	element_fire = class({})
end

function element_fire:OnCreated( kv )
	if IsServer() then
		if kv.stacks ~= nil then
		self:SetStackCount(kv.stacks)
	else
		self:SetStackCount(1)
	end
		self.nFXIndex = ParticleManager:CreateParticle( "particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 14, Vector( 1, 1, 1 ) )
		ParticleManager:SetParticleControl( self.nFXIndex, 15, Vector( 255, 50, 0 ) )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
		self:CalculateDuration()
		self:StartIntervalThink(0.5)
	end
end

function element_fire:OnRefresh( kv )
	if IsServer() then
		local stacks = self:GetStackCount() + kv.stacks
		if stacks > 999 then stacks = 999 end
		self:SetStackCount(stacks)
		self:CalculateDuration()
	end
end

function element_fire:CalculateDuration()
	self:SetDuration( self:GetStackCount()*0.5, true )
end

function element_fire:GetTexture()
	return "custom/element_fire"
end

function element_fire:OnIntervalThink()
	if IsServer() then
		local nDamageCalc = self:GetStackCount() * 2
		local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = nDamageCalc,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		--print("Fire Damage: " .. 2*self:GetStackCount())
		local hAbility = self:GetAbility()
		if hAbility and hAbility.DamageReport then
		hAbility.DamageReport = hAbility.DamageReport + nDamageCalc
		end

		if not self:GetParent():HasModifier("element_water") then ApplyDamage(damageTable) end

		self:DecrementStackCount()
		if self:GetParent():HasModifier("element_water") and self:GetStackCount() > 0 then self:DecrementStackCount() end
		if self:GetStackCount() < 1 then
			if hAbility and hAbility.DamageReport then
			print("Damage report: " .. hAbility.DamageReport)
			end
			self:Destroy()
		end
	end
end

function element_fire:IsHidden()
	return false
end

function element_fire:IsPurgable()
	return true
end

function element_fire:DestroyOnExpire()
	return false
end
