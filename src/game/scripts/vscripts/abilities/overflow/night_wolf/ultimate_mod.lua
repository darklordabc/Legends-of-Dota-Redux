if night_wolf_mod == nil then
	night_wolf_mod = class({})
end

function night_wolf_mod:OnCreated( kv )	
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetOrigin()) 
		ParticleManager:ReleaseParticleIndex(nFXIndex)
		self.AttackBonus = (self:GetParent():Script_GetAttackRange() - self:GetAbility():GetSpecialValueFor("attack_range")) * -1
		self.OriginalAtkCap = self:GetParent():GetAttackCapability() 
		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK) 
		self:StartIntervalThink( 1 )
		local hCaster = self:GetParent()
		hCaster:StartGesture(ACT_DOTA_SPAWN)
		EmitSoundOnLocationWithCaster( self:GetCaster():GetAbsOrigin(), "Hero_Lycan.Shapeshift.Cast", self:GetCaster() )
	end
end

function night_wolf_mod:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability(self.OriginalAtkCap) 
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetOrigin()) 
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
end
 
function night_wolf_mod:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_MODEL_CHANGE,
MODIFIER_PROPERTY_MODEL_SCALE,
MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
--MODIFIER_PROPERTY_MOVESPEED_MAX,
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	return funcs
end

function night_wolf_mod:IsHidden()
	return false
end

function night_wolf_mod:IsPurgable() 
	return false
end

function night_wolf_mod:IsPurgeException()
	return false
end

function night_wolf_mod:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function night_wolf_mod:AllowIllusionDuplicate() 
	return true
end

function night_wolf_mod:GetModifierModelChange() return "models/heroes/lycan/lycan_wolf.vmdl" end
function night_wolf_mod:GetModifierModelScale() return 0.25 end
function night_wolf_mod:GetModifierAttackRangeBonus() return self.AttackBonus end
function night_wolf_mod:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("move_speed") end
function night_wolf_mod:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attack_speed") end
--function night_wolf_mod:GetModifierMoveSpeed_Max()
--	return self:GetAbility():GetSpecialValueFor("max")
--end
function night_wolf_mod:GetBonusNightVision()
	if self:GetParent():HasScepter() then
	return self:GetAbility():GetSpecialValueFor("bonus_vision_scepter")
	else
	return 0
	end
end