LinkLuaModifier("modifier_recon_systems_bot_aura","abilities/nextgeneration/hero_keen/keen_commander_recon_systems.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_recon_systems_bot_shock","abilities/nextgeneration/hero_keen/keen_commander_recon_systems.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_recon_systems_bot_slow","abilities/nextgeneration/hero_keen/keen_commander_recon_systems.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_recon_systems_null","abilities/nextgeneration/hero_keen/keen_commander_recon_systems.lua",LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------------------------------
--		Ability: keen_commander_recon_systems																
--------------------------------------------------------------------------------------------------------
if keen_commander_recon_systems == nil then keen_commander_recon_systems = class({}) end
--------------------------------------------------------------------------------------------------------
function keen_commander_recon_systems:GetCastAnimation() return ACT_DOTA_CAST_ABILITY_1 end
--------------------------------------------------------------------------------------------------------
function keen_commander_recon_systems:GetBehavior() return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
--------------------------------------------------------------------------------------------------------
function keen_commander_recon_systems:GetAbilityTargetType() return DOTA_UNIT_TARGET_TREE end
--------------------------------------------------------------------------------------------------------
function keen_commander_recon_systems:GetAbilityDamageType() return DAMAGE_TYPE_MAGICAL end
--------------------------------------------------------------------------------------------------------

function keen_commander_recon_systems:OnSpellStart()
	--print("keen_commander_recon_systems:OnSpellStart()")
	local vCursorPos = self:GetCursorTarget():GetOrigin()
	local fBotDuration = self:GetSpecialValueFor("shock_bot_duration")
	local tTrees = GridNav:GetAllTreesAroundPoint(vCursorPos, 10, false)

	--print(#tTrees)
	-- tTrees[1]:AddNewModifier(self:GetCaster(), self, "modifier_recon_systems_bot_aura", { duration = fBotDuration })
	reconunit = CreateUnitByName("npc_dota_unit_recon",vCursorPos,false,self:GetCaster(),nil,self:GetCaster():GetTeamNumber())
	reconunit:SetOwner(self:GetCaster())
	--reconunit:AddNoDraw()
	reconunit:AddNewModifier(reconunit, self,"modifier_kill",{duration = fBotDuration})
	reconunit:AddNewModifier(reconunit, self,"modifier_recon_systems_bot_aura",{duration = fBotDuration})
	--CreateModifierThinker(self:GetCaster(), self, "modifier_recon_systems_bot_aura", { duration = fBotDuration }, vCursorPos, self:GetCaster():GetTeamNumber(), false)
	EmitSoundOn("Hero_Tinker.RearmStart", reconunit)
	reconunit:NoHealthBar()
end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_recon_systems_bot_aura													
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_bot_aura == nil then modifier_recon_systems_bot_aura = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:RemoveOnDeath() return true end

function modifier_recon_systems_bot_aura:CheckState()
 	 local state = {
      [MODIFIER_STATE_INVULNERABLE] = true,
      [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
      [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
      [MODIFIER_STATE_STUNNED] = true,
      [MODIFIER_STATE_NO_HEALTH_BAR] = true
  }

  return state
end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetModifierAura()	return "modifier_recon_systems_bot_shock" end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("shock_range") or 0 end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:OnCreated(kv)
	if IsServer() then
		--print("modifier_recon_systems_bot_aura:OnCreated")	
		local fBotRadius = self:GetAbility():GetSpecialValueFor("shock_range")		
		--DebugDrawCircle(self:GetParent():GetOrigin(), Vector(255,255,0), 1, fBotRadius, false, self:GetDuration())
		self:StartIntervalThink(0.1)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:OnIntervalThink()
	if IsServer() then
		local tTrees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetOrigin(), 10, false)
		if #tTrees < 1 then self:GetParent():ForceKill(false) end

		--local fBotRadius = self:GetAbility():GetSpecialValueFor("shock_range")
		--local tEnemyUnits = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, fBotRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 2, false)
		--DebugDrawCircle(self:GetParent():GetOrigin(), Vector(255,255,0), 1, fBotRadius, false, 1/30)

		--[[
		if #tEnemyUnits > 0 then
			for i=1, #tEnemyUnits do
				tEnemyUnits[i]:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_recon_systems_bot_shock", {Duration = 0.1})
			end
		end
		]]--
	end
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_recon_systems_bot_shock													
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_bot_shock == nil then modifier_recon_systems_bot_shock = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_shock:IsHidden() return true end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_shock:OnCreated()
	if IsServer() then
		--print("modifier_recon_systems_bot_shock:OnCreated")
		local fBotRadius = self:GetAbility():GetSpecialValueFor("shock_range")	
		local fShockDamage = self:GetAbility():GetLevelSpecialValueFor("shock_damage", self:GetAbility():GetLevel()-1)
		local fSlowDuration = self:GetAbility():GetLevelSpecialValueFor("slow_duration", self:GetAbility():GetLevel()-1)
		local fNullDuration = self:GetAbility():GetLevelSpecialValueFor("shock_null_duration", self:GetAbility():GetLevel()-1)
		local particleName = "particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf"

		local null_modifier = self:GetParent():FindModifierByName("modifier_recon_systems_null")

		if not null_modifier then
			local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, self)
			ParticleManager:SetParticleControl(lightningBolt,0,Vector(self:GetCaster():GetAbsOrigin().x,self:GetCaster():GetAbsOrigin().y,self:GetCaster():GetAbsOrigin().z + self:GetCaster():GetBoundingMaxs().z ))	
			ParticleManager:SetParticleControl(lightningBolt,1,Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,self:GetParent():GetAbsOrigin().z + self:GetParent():GetBoundingMaxs().z ))
			self:GetParent():EmitSound("Hero_ShadowShaman.EtherShock.Target")

			ApplyDamage({
				victim = self:GetParent(),
				attacker = self:GetCaster():GetOwner(),
				damage = fShockDamage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility()
				})
			self:GetParent():Purge(true, false, false, false, false)
			self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(), "modifier_recon_systems_bot_slow", {Duration = fSlowDuration})
			self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(), "modifier_recon_systems_null", {Duration = fNullDuration})
		end
	end
end
--------------------------------------------------------------------------------------------------------
-- 		Modifier: modifier_recon_systems_null
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_null == nil then modifier_recon_systems_null = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_null:IsHidden() return true end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_null:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_recon_systems_bot_shock")
	end
end
--------------------------------------------------------------------------------------------------------
-- 		Modifier: modifier_recon_systems_bot_slow
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_bot_slow == nil then modifier_recon_systems_bot_slow = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_slow:GetModifierMoveSpeedBonus_Percentage() return -(self:GetAbility():GetSpecialValueFor("movespeed_slow_percentage")) end
