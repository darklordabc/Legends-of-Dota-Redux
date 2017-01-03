LinkLuaModifier( "modifier_angel_arena_archmage_anomaly_thinker", "abilities/angel_arena_reborn/angel_arena_archmage_anomaly.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_archmage_anomaly", "abilities/angel_arena_reborn/angel_arena_archmage_anomaly.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
if angel_arena_archmage_anomaly == nil then angel_arena_archmage_anomaly = class({}) end

function angel_arena_archmage_anomaly:OnSpellStart()
	self.vTarget = self:GetCursorPosition()
	self.duration = self:GetSpecialValueFor("duration")
	local dummy = CreateUnitByName( "dummy_unit", self.vTarget, false, nil, nil, self:GetCaster():GetTeamNumber() )
	dummy:AddNewModifier(self:GetCaster(), self, "modifier_angel_arena_archmage_anomaly_thinker", {duration = self.duration})
end

function angel_arena_archmage_anomaly:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_angel_arena_archmage_anomaly				
--------------------------------------------------------------------------------------------------------
if modifier_angel_arena_archmage_anomaly_thinker == nil then modifier_angel_arena_archmage_anomaly_thinker = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_angel_arena_archmage_anomaly_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if IsServer() then
		self.auraTargetType = self:GetAbility():GetAbilityTargetType()
		self.auraTargetTeam = self:GetAbility():GetAbilityTargetTeam()
		self.auraTargetFlags = self:GetAbility():GetAbilityTargetFlags()
		self.FXIndex = ParticleManager:CreateParticle( "particles/econ/items/faceless_void/faceless_void_mace_of_aeons/fv_chronosphere_aeons.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 1, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
		ParticleManager:SetParticleControl( self.FXIndex, 4, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 6, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 10, self:GetParent():GetOrigin() )
	end
	self.AlreadyHit = {}
	self.blackList = {["shadow_shaman_shackles"] = true}
	EmitSoundOn("Hero_Warlock.ShadowWord", self:GetParent())
end

function modifier_angel_arena_archmage_anomaly_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:GetModifierAura()
	return "modifier_archmage_anomaly"
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:GetAuraSearchType()
	return self.auraTargetType
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:GetAuraSearchFlags()
	return self.auraTargetFlags
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_angel_arena_archmage_anomaly_thinker:IsPurgable()
    return false
end
--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_angel_arena_archmage_anomaly_thinker:OnAbilityFullyCast(params)
	if params.unit:GetTeamNumber() == self:GetCaster():GetTeamNumber() and IsServer() and params.ability ~= self:GetAbility() then
		local abName = params.ability:GetName()
		if params.unit:HasAbility(abName) and not self.blackList[abName] then -- check if caster owns ability and it's unit target
			self.AlreadyHit = {}
			if params.target then self.AlreadyHit[params.target] = true else return end
			local enemies = FindUnitsInRadius(params.target:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.aura_radius * 2, DOTA_UNIT_TARGET_TEAM_FRIENDLY, self.auraTargetType, self.auraTargetFlags, FIND_ANY_ORDER, false)
			for _,enemy in pairs(enemies) do
				if enemy:HasModifier("modifier_archmage_anomaly") then
					if params.ability:GetCursorTarget() and not self.AlreadyHit[enemy] then
						params.unit:SetCursorCastTarget(enemy)
						params.ability:OnSpellStart()
						self.AlreadyHit[enemy] = true
					-- elseif not self.AlreadyHit[enemy] and params.ability:GetCursorPosition() and (params.ability:GetCursorPosition() - self:GetParent():GetAbsOrigin()):Length2D() < self.aura_radius then -- I DEEM THIS TOO OP
						-- params.unit: SetCursorPosition(enemy:GetAbsOrigin())
						-- params.ability:OnSpellStart()
						-- self.AlreadyHit[enemy] = true
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_angel_arena_archmage_anomaly_thinker:OnDestroy( kv )
	StopSoundOn("Hero_Warlock.ShadowWord", self:GetParent())
	self:GetParent():RemoveSelf()
end

if modifier_archmage_anomaly == nil then modifier_archmage_anomaly = class({}) end
