if spell_lab_bfg == nil then
	spell_lab_bfg = class({})
end

LinkLuaModifier("spell_lab_bfg_modifier", "abilities/spell_lab/bfg/bfg.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_bfg:OnSpellStart()
	self.active = true
	self.damage = 0
	self:GetCaster():EmitSound("Spell_Lab.BFG_Charge")
end

function spell_lab_bfg:OnChannelThink(fInterval)
	if (not self.active) then return end
	local fMana = fInterval * self:GetChannelledManaCostPerSecond(self:GetLevel())
	if self:GetCaster():GetMana() > fMana then
		self.damage = self.damage + fMana
		self:GetCaster():SpendMana(fMana,self)
	else
		self:GetCaster():InterruptChannel()
	end
end

function spell_lab_bfg:GetChannelledManaCostPerSecond (iLevel)
	return self:GetCaster():GetMaxMana()*0.1
end

function spell_lab_bfg:OnChannelFinish (bInterrupt)
	self.active = false
  local hCaster = self:GetCaster()
	hCaster:StopSound("Spell_Lab.BFG_Charge")
	if (self.proid == nil) then
		self.proid = 0
		self.capture = {}
	 end
	self.proid = self.proid + 1
	local extra = {id = self.proid, dmg = self.damage}
	self.capture[self.proid] = {}
	local fCastRange = self:GetCastRange(self:GetCursorPosition(),hCaster)
  local info =
  {
    Ability = self,
    EffectName = "particles/spell_lab/bfg_linear.vpcf",
    vSpawnOrigin = hCaster:GetAbsOrigin(),
    fDistance = fCastRange,
    fStartRadius = 225,
    fEndRadius = 225,
    Source = hCaster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    fExpireTime = GameRules:GetGameTime() + 20.0,
    bDeleteOnHit = false,
    vVelocity = hCaster:GetForwardVector() * fCastRange * 0.5,
    bProvidesVision = true,
    iVisionRadius = 1000,
    iVisionTeamNumber = hCaster:GetTeamNumber(),
		ExtraData = extra
  }
	projectile = ProjectileManager:CreateLinearProjectile(info)
	EmitSoundOn( "Spell_Lab.BFG_Hit", hTarget )
end

function spell_lab_bfg:OnProjectileHit_ExtraData(hTarget, vPosition, tExtra)
	if hTarget == nil then
		self:Explosion(vPosition,tExtra)
	else
		if hTarget:IsMagicImmune() or hTarget:IsInvulnerable() then return end
		table.insert(self.capture[tExtra.id],hTarget)
		hTarget:AddNewModifier(self:GetCaster(),self,"spell_lab_bfg_modifier",{})
		EmitSoundOn( "Spell_Lab.BFG_Hit", hTarget )
		local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/bfg_shock.vpcf", PATTACH_CUSTOMORIGIN, nil );
		ParticleManager:SetParticleControl(nFXIndex, 0, vPosition );
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
		local Colour = {100,255,0}
		ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3]))
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

function spell_lab_bfg:Explosion(vPosition, tExtra)
	local hCaster = self:GetCaster()
		for i=1,#self.capture[tExtra.id] do
			local hTarget = self.capture[tExtra.id][i]-- EntIndexToHScript(self.capture[tExtra.id])
			local hMod = hTarget:FindModifierByName("spell_lab_bfg_modifier")
			if (hMod) then
				hTarget:SetAbsOrigin(vPosition)
				FindClearSpaceForUnit(hTarget , vPosition, false)
				hMod:Destroy()
			end
		end
	local particleName = "particles/spell_lab/bfg_aoe.vpcf"
 local aoe = 350

	--silly field of view
	AddFOWViewer(hCaster:GetTeamNumber(), vPosition, 350, 1.0, false)
	local expl = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, hCaster )
	ParticleManager:SetParticleControl( expl, 0, vPosition )
	ParticleManager:SetParticleControl( expl, 1, Vector(350,100,200) )
	ParticleManager:SetParticleControl( expl, 2, Vector(2,0.35,1) )
	ParticleManager:SetParticleControl( expl, 3, Vector(100,255,0) )
	ParticleManager:SetParticleControl( expl, 4, Vector(100,255,0) )
 EmitSoundOnLocationWithCaster(vPosition, "Spell_Lab.BFG_Die", hCaster )
	 local tdamage = {
		 attacker = hCaster,
		 damage_type = self:GetAbilityDamageType(),
		 ability = self
	 }
	if hCaster:HasScepter() then
		tdamage.damage = self:GetSpecialValueFor("mana_pct")*tExtra.dmg
	else
		tdamage.damage = self:GetSpecialValueFor("mana_pct_scepter")*tExtra.dmg
	end
	 local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), vPosition, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	 print("BFG AOE:" .. #enemies .. " damage: " .. tdamage.damage)
	 if #enemies > 0 then
		 for _,enemy in pairs(enemies) do
			 if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
				 tdamage.victim = enemy
				 ApplyDamage( tdamage )
			 end
		 end
	 end
end

if spell_lab_bfg_modifier == nil then
	spell_lab_bfg_modifier = class({})
end

function spell_lab_bfg_modifier:OnCreated(kv)
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end
function spell_lab_bfg_modifier:OnRemoved()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
	end
end
function spell_lab_bfg_modifier:IsHidden()
	return true
end

function spell_lab_bfg_modifier:IsPurgable()
	return false
end

function spell_lab_bfg_modifier:CheckState()
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
