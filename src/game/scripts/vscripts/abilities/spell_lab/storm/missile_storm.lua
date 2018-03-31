if spell_lab_missile_storm == nil then
	spell_lab_missile_storm = class({})
end

LinkLuaModifier("spell_lab_storm_modifier", "abilities/spell_lab/storm/storm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_missile_storm:GetIntrinsicModifierName() return "spell_lab_storm_modifier" end

function spell_lab_missile_storm:OnSpellStart()

  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Spell_Lab.Storm_Missile", self:GetCaster())
if self.fc == nil then
	self.fc = 0.0
else
	self.fc = self.fc + 0.1
end
  local hCaster = self:GetCaster()
  local hTarget = self:GetCursorTarget()
  local vPos = Vector(math.sin(self.fc)*150,math.cos(self.fc)*150,0)
local info =
{
	Target = hTarget,
	Source = hCaster,
	Ability = self,
	EffectName = "particles/spell_lab/storm_missile.vpcf",
        iMoveSpeed = 950,
	vSourceLoc= hCaster:GetAbsOrigin()+vPos,                -- Optional (HOW)
	bDrawsOnMinimap = false,                          -- Optional
        bDodgeable = true,                                -- Optional
        bIsAttack = false,                                -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bReplaceExisting = false,                         -- Optional
        flExpireTime = GameRules:GetGameTime() + 120,      -- Optional but recommended
	bProvidesVision = true,                           -- Optional
	iVisionRadius = 40,                              -- Optional
	iVisionTeamNumber = hCaster:GetTeamNumber()        -- Optional
}
ProjectileManager:CreateTrackingProjectile(info)
  --hTarget:AddNewModifier(hCaster,self,"spell_lab_missile_storm_modifier",{duration = self:GetSpecialValueFor("duration")})
end
function spell_lab_missile_storm:OnProjectileHit(hTarget,vPoint)
  local hCaster = self:GetCaster()
local damageTable = {
  victim = hTarget,
  attacker = hCaster,
  damage = self:GetSpecialValueFor("damage"),
  damage_type = DAMAGE_TYPE_MAGICAL,
}
  ApplyDamage(damageTable)
  if (hTarget ~= nil) then
    hTarget:AddNewModifier(hCaster,self,"generic_lua_stun",{duration = self:GetSpecialValueFor("duration")})
    EmitSoundOnLocationWithCaster( vPoint, "Roshan.Bash", hCaster )
  end

end
function spell_lab_missile_storm:CastFilterResultTarget( hTarget )
	return UnitFilter(hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		self:GetCaster():GetTeamNumber() )
end
