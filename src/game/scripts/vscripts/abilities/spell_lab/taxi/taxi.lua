if spell_lab_taxi == nil then
	spell_lab_taxi = class({})
end

LinkLuaModifier("spell_lab_taxi_modifier", "abilities/spell_lab/taxi/taxi.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_taxi:OnSpellStart()
  local hCaster = self:GetCaster()
	local vOrigin = hCaster:GetAbsOrigin() --Our units's location
	if (self.proid == nil) then
		self.proid = 0
		self.capture = {}
	 end
	self.proid = self.proid + 1
	local extra = {id = self.proid}
	self.capture[self.proid] = {}
	local fCastRange = self:GetCastRange(self:GetCursorPosition(),hCaster)
	local fAttemptRange = (self:GetCursorPosition()-vOrigin):Length2D()
	if (hCaster:HasScepter()) then
		fCastRange = fAttemptRange
	else
		fCastRange = math.min(fCastRange,fAttemptRange)
	end

  local info =
  {
    Ability = self,
    EffectName = "particles/spell_lab/taxi_linear.vpcf",
    vSpawnOrigin = hCaster:GetAbsOrigin(),
    fDistance = fCastRange,
    fStartRadius = 250,
    fEndRadius = 250,
    Source = hCaster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    fExpireTime = GameRules:GetGameTime() + 20.0,
    bDeleteOnHit = false,
    vVelocity = hCaster:GetForwardVector() * 1000,
    bProvidesVision = true,
    iVisionRadius = 1000,
    iVisionTeamNumber = hCaster:GetTeamNumber(),
		ExtraData = extra
  }
	projectile = ProjectileManager:CreateLinearProjectile(info)
	EmitSoundOn( "Spell_Lab.BFG_Hit", hTarget )
end

function spell_lab_taxi:OnProjectileHit_ExtraData(hTarget, vPosition, tExtra)
	if hTarget == nil then
		self:Explosion(vPosition,tExtra)
	else
		if hTarget:IsMagicImmune() or hTarget:IsInvulnerable() then return end

		local nTargetID = hTarget:GetPlayerOwnerID() --getting targets owner id
		local nCasterID = self:GetCaster():GetPlayerOwnerID() --getting casters owner id
		if nTargetID and nCasterID then --making sure they both exist
			if PlayerResource:IsDisableHelpSetForPlayerID(nTargetID, nCasterID) then --target hates having caster help him out.
				return
			end
		end
		table.insert(self.capture[tExtra.id],hTarget)
		hTarget:AddNewModifier(self:GetCaster(),self,"spell_lab_taxi_modifier",{})
		EmitSoundOn( "Spell_Lab.BFG_Hit", hTarget )
		local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/taxi_shock.vpcf", PATTACH_CUSTOMORIGIN, nil );
		ParticleManager:SetParticleControl(nFXIndex, 0, vPosition );
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
		local Colour = {0,0,0}
		ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3]))
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

function spell_lab_taxi:Explosion(vPosition, tExtra)
	local hCaster = self:GetCaster()
		for i=1,#self.capture[tExtra.id] do
			local hTarget = self.capture[tExtra.id][i]-- EntIndexToHScript(self.capture[tExtra.id])
			local hMod = hTarget:FindModifierByName("spell_lab_taxi_modifier")
			if (hMod) then
				hTarget:SetAbsOrigin(vPosition)
				FindClearSpaceForUnit(hTarget , vPosition, false)
				hMod:Destroy()
			end
		end
 EmitSoundOnLocationWithCaster(vPosition, "Spell_Lab.BFG_Die", hCaster )
end

if spell_lab_taxi_modifier == nil then
	spell_lab_taxi_modifier = class({})
end

function spell_lab_taxi_modifier:OnCreated(kv)
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end
function spell_lab_taxi_modifier:OnRemoved()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
	end
end
function spell_lab_taxi_modifier:IsHidden()
	return true
end

function spell_lab_taxi_modifier:IsPurgable()
	return false
end

function spell_lab_taxi_modifier:CheckState()
	local state = {
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	[MODIFIER_STATE_UNSELECTABLE] = true,
	[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_FROZEN] = true,
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_OUT_OF_GAME] = true,
	[MODIFIER_STATE_BLIND] = true,
	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end
