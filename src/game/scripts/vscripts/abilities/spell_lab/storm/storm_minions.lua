if spell_lab_storm_minions == nil then
	spell_lab_storm_minions = class({})
end
LinkLuaModifier("spell_lab_storm_modifier", "abilities/spell_lab/storm/storm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spell_lab_target_thinker_modifier", "abilities/spell_lab/storm/storm_minions.lua", LUA_MODIFIER_MOTION_NONE)
if spell_lab_target_thinker_modifier == nil then
	spell_lab_target_thinker_modifier = class({})
end
function spell_lab_storm_minions:GetIntrinsicModifierName() return "spell_lab_storm_modifier" end

function spell_lab_storm_minions:OnSpellStart()

	--local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/one_with_nothing.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	--ParticleManager:SetParticleControl( nFXIndex, 0,self:GetCaster():GetAbsOrigin())
	--ParticleManager:SetParticleControl( nFXIndex, 3,self:GetCaster():GetAbsOrigin())
  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Spell_Lab.Storm_Missile", self:GetCaster())
--  self:GetCaster():SpendMana(self:GetCaster():GetMana(),self)
if self.fc == nil then
	self.fc = 0.0
	self.alt = false
else
	self.fc = self.fc + 0.1
end
  --local vPos = Vector(math.sin(self.fc)*150,math.cos(self.fc)*150,0)
	--A Liner Projectile must have a table with projectile info
	local effect = "particles/spell_lab/storm_missile.vpcf"
	if self.alt then
		self.alt = false
		effect = "particles/spell_lab/storm_missile.vpcf"
	else
		self.alt = true
	end
	if self.fc == nil then
		self.fc = 0.0
	else
		self.fc = self.fc + 0.1
	end
	  local hCaster = self:GetCaster()
	 	local vPos = Vector(math.sin(self.fc)*50,math.cos(self.fc)*50,0)
		local hTarget = CreateModifierThinker(hCaster,self, "spell_lab_target_thinker_modifier", {}, self:GetCursorPosition()+vPos, hCaster:GetTeam(), false)

	local info =
	{
		Target = hTarget,
		Source = hCaster,
		Ability = self,
		EffectName = effect,
	        iMoveSpeed = 950,
		vSourceLoc= hCaster:GetAbsOrigin(),                -- Optional (HOW)
		bDrawsOnMinimap = false,                          -- Optional
	        bDodgeable = false,                                -- Optional
	        bIsAttack = false,                                -- Optional
	        bVisibleToEnemies = true,                         -- Optional
	        bReplaceExisting = false,                         -- Optional
	        flExpireTime = GameRules:GetGameTime() + 120,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 40,                              -- Optional
		iVisionTeamNumber = hCaster:GetTeamNumber()        -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)
  --hTarget:AddNewModifier(hCaster,self,"spell_lab_storm_minions_modifier",{duration = self:GetSpecialValueFor("duration")})
end
function spell_lab_storm_minions:OnProjectileHit(hTarget,vPoint)
  local hCaster = self:GetCaster()
	local vPos = hTarget:GetAbsOrigin()
	local sName = "npc_spell_lab_storm_minion_" .. self:GetLevel()
	PrecacheUnitByNameAsync(sName, function()
		CreateUnitByNameAsync(sName, vPos, true, hCaster, hCaster, hCaster:GetTeam(),function(hUnit)
			hUnit:AddNewModifier(hCaster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
			hUnit:SetControllableByPlayer(hCaster:GetPlayerID(), true)
			FindClearSpaceForUnit(hUnit,vPos,true)
			local hAbility = hUnit:FindAbilityByName("spell_lab_storm_minion_passive")
			hAbility:SetLevel(self:GetLevel())
		end)
  end)
	hTarget:ForceKill(false)
end
if spell_lab_storm_minion_passive == nil then
	spell_lab_storm_minion_passive = class({})
end

LinkLuaModifier("spell_lab_storm_minion_passive_modifier", "abilities/spell_lab/storm/storm_minions.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_storm_minion_passive:GetIntrinsicModifierName() return "spell_lab_storm_minion_passive_modifier" end
if spell_lab_storm_minion_passive_modifier == nil then
	spell_lab_storm_minion_passive_modifier = class({})
end

function spell_lab_storm_minion_passive_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_storm_minion_passive_modifier:IsPurgable()
	return false
end
function spell_lab_storm_minion_passive_modifier:IsHidden()
	return true
end
function spell_lab_storm_minion_passive_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function spell_lab_storm_minion_passive_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function spell_lab_storm_minion_passive_modifier:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent()  then
			if self:GetParent():PassivesDisabled() then return end
			local mana = self:GetParent():GetMana()
			self:GetParent():SpendMana(keys.damage,self:GetAbility())
			local mana_after = self:GetParent():GetMana()
			local mana_spent = mana - mana_after
			local no_heal = keys.damage - mana_spent
			local health = self:GetParent():GetHealth()
			if health - no_heal > 0 then
				self:GetParent():Heal(mana_spent,self:GetAbility())
			end
		end
	end
end
function spell_lab_storm_minion_passive_modifier:GetStatusEffectName()
	return "particles/spell_lab/status_effect_storm_minion_summon.vpcf"
end
function spell_lab_storm_minion_passive_modifier:OnCreated(kv)
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/passive_effect_storm_minion_summon.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
end
--[[

function spell_lab_storm_minion_passive_modifier:GetEffectName()
	return "particles/spell_lab/passive_effect_storm_minion_summon.vpcf"
end

]]--
