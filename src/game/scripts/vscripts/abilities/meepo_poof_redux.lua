if meepo_poof_redux == nil then
	meepo_poof_redux = class({})
end

function meepo_poof_redux:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function meepo_poof_redux:OnSpellStart()
	self.point = self:GetCursorPosition()
	--create effect at point
	local hCaster = self:GetCaster()
  local tHeroes = HeroList:GetAllHeroes()
  local sCasterModel = hCaster:GetModelName()
  local iTeam = hCaster:GetTeamNumber()
  local cdist = 999999
  self.target = hCaster
  for i=1,#tHeroes do
    if tHeroes[i]:GetModelName() ~= sCasterModel or iTeam ~= tHeroes[i]:GetTeamNumber() then goto continue  end
    local _d = (self.point - tHeroes[i]:GetAbsOrigin()):Length2D()
    if _d < cdist then
      cdist = _d
      self.target = tHeroes[i]
    end
    ::continue::
  end

	local particleName = "particles/units/heroes/hero_meepo/meepo_poof_start.vpcf"
	self.start_fx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, hCaster )
	ParticleManager:SetParticleControl( self.start_fx, 0, hCaster:GetAbsOrigin()  )
		EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin() , "Hero_Meepo.Poof.Channel", hCaster )
		--self:StartCooldown(self:GetCooldown(self:GetLevel()))
end

function meepo_poof_redux:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES + DOTA_ABILITY_BEHAVIOR_AOE
	return behav
end

function meepo_poof_redux:OnChannelFinish( bInterrupted )
	if not bInterrupted then
    self.point = self.target:GetAbsOrigin()
    self:DamageRadius(self:GetCaster():GetAbsOrigin())
    self:TeleportToPoint(self.point)
		--teleport!
		--soundevents/game_sounds_heroes/game_sounds_furion.vsndevts
		--soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts
		--Hero_Furion.Teleport_Disappear
		--Hero_Wisp.Relocate
    self:DamageRadius(self.point)
	end
	--end effect
  ParticleManager:DestroyParticle(self.start_fx, false)
	self.point = nil
  self.target = nil
end

function meepo_poof_redux:TeleportToPoint (point)
  local hCaster = self:GetCaster()
  local particleName = "particles/units/heroes/hero_meepo/meepo_poof_end.vpcf"
  self.end_fx_1 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, hCaster )
  ParticleManager:SetParticleControl( self.end_fx_1, 0, point )
  self.end_fx_2 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, hCaster )
  ParticleManager:SetParticleControl( self.end_fx_2, 0, hCaster:GetAbsOrigin() )
  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin() , "Hero_Meepo.Poof", hCaster )
  EmitSoundOnLocationWithCaster(point, "Hero_Meepo.Poof", hCaster )
  self:GetCaster():SetAbsOrigin( point ) --We move the caster instantly to the location
  FindClearSpaceForUnit(self:GetCaster(), point, false)
  -- body...
end

function meepo_poof_redux:DamageRadius (point)
  local hCaster = self:GetCaster()
		local dmg = self:GetAbilityDamage()
    local dtype = self:GetAbilityDamageType()
		local aoe = self:GetSpecialValueFor("radius")
		local damage = {
			attacker = hCaster,
			damage = dmg,
			damage_type = dtype,
			ability = self
		}
  local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), point, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
  if #enemies > 0 then
    for _,enemy in pairs(enemies) do
      if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
        damage.victim = enemy
        ApplyDamage( damage )
      end
    end
  end
end
