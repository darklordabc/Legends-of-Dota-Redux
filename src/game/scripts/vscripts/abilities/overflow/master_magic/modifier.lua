if master_magic_mod == nil then
	master_magic_mod = class({})
end

function master_magic_mod:OnCreated( kv )	
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/master_magic.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(self.nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true) 
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
		if not kv.stacks then kv.stacks = 1 end
		self:SetStackCount(kv.stacks)
	end
end
 
function master_magic_mod:OnRefresh( kv )	
	if IsServer() then
		local old = self:GetStackCount()
		local hAbility = self:GetAbility()
		self:SetDuration(self:GetDuration()+hAbility:GetSpecialValueFor("duration"), true) 
		if not kv.stacks then kv.stacks = 1 end
		self:SetStackCount(kv.stacks + old)
	end
end

function master_magic_mod:OnDestroy()
	if IsServer() then
	end
end
 
function master_magic_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end

function master_magic_mod:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			if params.ability ~= self:GetAbility() and  params.ability:GetAbilityName() ~= "item_refresher" and params.ability:GetAbilityName() ~= "item_hand_of_midas" and bit.band(DOTA_ABILITY_BEHAVIOR_AUTOCAST , params.ability:GetBehavior() ) ~= DOTA_ABILITY_BEHAVIOR_AUTOCAST and bit.band(DOTA_ABILITY_BEHAVIOR_TOGGLE , params.ability:GetBehavior() ) ~= DOTA_ABILITY_BEHAVIOR_TOGGLE then
			
			local isUltimate = false
			-- If its an ultimate, there needs to be two charges, if not, return
			if params.ability:GetAbilityType() == 1 and self:GetStackCount() < 3 then
				return
			elseif params.ability:GetAbilityType() == 1 and self:GetStackCount() >= 3 then
				isUltimate = true
			end

			params.ability:EndCooldown()
			if self:GetParent():HasScepter() and RandomInt(1, 100) < self:GetAbility():GetSpecialValueFor("chance_scepter") then
				EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Brewmaster_Storm.DispelMagic", self:GetCaster() )
			else
				self:DecrementStackCount()
				-- If its an ultimate reduce 2 extra stack
				if isUltimate == true then
					self:DecrementStackCount()
					self:DecrementStackCount()
				end
			end
			end
			if self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
	end
end

function master_magic_mod:IsHidden()
	return false
end

function master_magic_mod:IsPurgable() 
	return true
end

function master_magic_mod:IsPurgeException()
	return true
end

function master_magic_mod:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function master_magic_mod:AllowIllusionDuplicate() 
	return false
end
