if spell_lab_void_step == nil then
	spell_lab_void_step = class({})
end

LinkLuaModifier("spell_lab_void_step_modifier", "abilities/spell_lab/void_step/void_step.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_void_step:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	return behav
end

function spell_lab_void_step:OnSpellStart()

	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_FacelessVoid.TimeWalk", self:GetCaster() )
  local mana_void = self:GetCaster():GetMaxMana() - self:GetCaster():GetMana()
	if self:GetCaster():HasScepter() then
		mana_void = mana_void * self:GetSpecialValueFor("speed_scepter");
	else
		mana_void = mana_void * self:GetSpecialValueFor("speed");
	end
	local illusions = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #illusions > 0 then
		local ownerid = self:GetCaster():GetPlayerOwnerID()
		for _,illusion in pairs(illusions) do
			if illusion ~= nil and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == ownerid then
				illusion:AddNewModifier( self:GetCaster(), self, "spell_lab_void_step_modifier", { duration = self:GetSpecialValueFor("duration"), stacks = mana_void } )
			end
		end
	end
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "spell_lab_void_step_modifier", { duration = self:GetSpecialValueFor("duration"), stacks = mana_void } )
end

if spell_lab_void_step_modifier == nil then
	spell_lab_void_step_modifier = class({})
end

function spell_lab_void_step_modifier:OnCreated( kv )
	if IsServer() then
    self:SetStackCount(kv.stacks)
	  ProjectileManager:ProjectileDodge(self:GetCaster())
   	self:GetParent():AddNoDraw()
		local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/void_step_end.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0,self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 6,self:GetParent():GetForwardVector())
		ParticleManager:ReleaseParticleIndex(nFXIndex)
		if not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
			self.local_thirst = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_bloodseeker_thirst", {})
		end
	end
end

function spell_lab_void_step_modifier:OnDestroy()
	if IsServer() then
	  ProjectileManager:ProjectileDodge(self:GetCaster())
		self:GetParent():RemoveNoDraw()
		local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/void_step_end.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0,self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex(nFXIndex)
		if self.local_thirst then
			self.local_thirst:Destroy()
		end
	end
end

function spell_lab_void_step_modifier:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
MODIFIER_PROPERTY_MOVESPEED_MAX,
MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
	return funcs
end

function spell_lab_void_step_modifier:GetModifierMoveSpeedBonus_Constant()
  return self:GetStackCount()
end
function spell_lab_void_step_modifier:GetModifierMoveSpeed_Max()
	return self:GetStackCount()
end

----------------------------------------------------------------------------------------------------------
function spell_lab_void_step_modifier:GetModifierMoveSpeed_Limit()
	return self:GetStackCount()
end

function spell_lab_void_step_modifier:IsHidden()
	return true
end

function spell_lab_void_step_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function spell_lab_void_step_modifier:AllowIllusionDuplicate()
	return false
end

function spell_lab_void_step_modifier:CheckState()
	local state = {
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_DISARMED] = true,
  [MODIFIER_STATE_OUT_OF_GAME] = true,
  [MODIFIER_STATE_ATTACK_IMMUNE] = true,
  [MODIFIER_STATE_INVULNERABLE] = true,
  [MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end
--------------------------------------------------------------------------------

function spell_lab_void_step_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
