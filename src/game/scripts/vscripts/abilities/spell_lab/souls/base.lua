if spell_lab_souls_base_modifier == nil then
	spell_lab_souls_base_modifier = class({})
end

function spell_lab_souls_base_modifier:GetSoulsBonus()
if self:GetParent():PassivesDisabled() then return 0 end
local max = self:GetAbility():GetSpecialValueFor("max")
if (max > 0) then return math.min(max,self:GetStackCount()) end
return self:GetStackCount()
end

function spell_lab_souls_base_modifier:OnDeath(kv)
  if IsServer() then
		if self:GetAbility():GetLevel() < 1 then return end
		if self.bDrop then
			if kv.unit == self:GetCaster() then
				if (not self.bPickedup) then
					ParticleManager:DestroyParticle(self.nFXIndex,false)
				end
				self:GetParent():ForceKill(false)
			end
		else
	    if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
				if (self:GetStackCount() < 1) then return end
				if (kv.unit:IsIllusion()) then
					return
				else
					local max = self:GetAbility():GetSpecialValueFor("max")
					local remove = self:GetStackCount()
					if (max > 0) then remove = math.min(max, self:GetStackCount()) end
					self:DropSouls(remove)
					self:SetStackCount(self:GetStackCount()-remove)
					self:GetParent():CalculateStatBonus()
				end
	    elseif kv.unit ~= self:GetParent() and kv.attacker == self:GetParent() then
				if (kv.unit:IsRealHero() and kv.unit:GetTeam() == self:GetParent():GetTeam()) then return end
				self:GainSoul(kv.unit)
			end
		end
  end
end

function spell_lab_souls_base_modifier:GainSoul (hTarget)
	if hTarget:IsRealHero() then
		self:SetStackCount(self:GetStackCount()+10)
	elseif not hTarget:IsIllusion() then
		self:IncrementStackCount()
	end
	self:GetParent():CalculateStatBonus()
	local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/souls_gain.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	local Colour = self:GetColour()
	ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3]))
end

function spell_lab_souls_base_modifier:GainSouls (iAmount)
	self:SetStackCount(self:GetStackCount()+iAmount)
	self:GetParent():CalculateStatBonus()
end

function spell_lab_souls_base_modifier:GetColour ()
	return {0,0,0}
end

function spell_lab_souls_base_modifier:GiveSouls (hTarget)
	if (self.bPickedup) then return end
	ParticleManager:DestroyParticle(self.nFXIndex,false)
	self.bPickedup = true
	hTarget:FindModifierByName(self:GetName()):GainSouls(self:GetStackCount())
	local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/souls_gain.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
	local Colour = self:GetColour()
	ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3]))
	--self:GetParent():Kill(self:GetAbility(),nil)
end

function spell_lab_souls_base_modifier:DropSouls (count)
	if (self:GetStackCount() > 0) then
		local keys = {stacks = count}
		--print("Souls Drop: " .. self:GetStackCount() .. " modifier_name: " .. self:GetName())
		local hDrop = CreateModifierThinker(self:GetCaster(), self:GetAbility(), self:GetName(), keys, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeam(), false)
	end
end

function spell_lab_souls_base_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_souls_base_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_souls_base_modifier:IsPurgable()
	return false
end

function spell_lab_souls_base_modifier:OnCreated(kv)

	--DeepPrintTable(kv)
	self.bDrop = (kv.stacks ~= nil and kv.stacks > 0)
	self.bPickedup = false
	if IsServer() then
		local hOwner = self:GetParent()
		if (self.bDrop) then
			self.fFoundTime = 0
			--DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255,0,0),1.0,128, true, 300)
			self.nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/soul_remnant.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
			local Colour = self:GetColour()
			ParticleManager:SetParticleControlEnt( self.nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
			ParticleManager:SetParticleControlEnt(self.nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
			ParticleManager:SetParticleControl(self.nFXIndex , 2, Vector(1,0.5,0))
			ParticleManager:SetParticleControl(self.nFXIndex , 15, Vector(Colour[1],Colour[2],Colour[3]))
			self:AddParticle( self.nFXIndex, false, false, -1, false, false )
			self:SetStackCount(kv.stacks)
			self.fInterval = 0.5
			self.fTime = 0
			self.bDrop = true
			self:StartIntervalThink(self.fInterval)
		end
	end
end

function spell_lab_souls_base_modifier:OnIntervalThink()
	if IsServer() then
		self.fTime = self.fTime + self.fInterval
		if (self.fTime > 80) then
			if (not self.bPickedup) then
				ParticleManager:DestroyParticle(self.nFXIndex,false)
			end
			self:GetParent():ForceKill(false)
			return
		end
		local bFound = false
		local tUnits = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, 256, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_ANY_ORDER, false)
		if #tUnits > 0 then
			for i=1,#tUnits do
				if tUnits[i] == self:GetCaster() then
					bFound = tUnits[i]
				end
			end
		end
		if bFound then
			self.fFoundTime = self.fFoundTime + self.fInterval
			local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/souls_gain.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
			ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin() )
			ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )

			local Colour = self:GetColour()
			ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3]))
			if self.fFoundTime > 5.0 then
				self:GiveSouls(bFound)
				self:StartIntervalThink(-1)
				self:GetParent():ForceKill(false)
			end
		else
			self.fFoundTime = 0
		end
	end
end

function spell_lab_souls_base_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
return spell_lab_souls_base_modifier
