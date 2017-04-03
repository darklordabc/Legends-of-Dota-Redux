--------------------------------------------------------------------------------------------------------
--		Ability: keen_commander_recon_systems																
--------------------------------------------------------------------------------------------------------
if keen_commander_recon_systems == nil then keen_commander_recon_systems = class({}) end
--------------------------------------------------------------------------------------------------------
function keen_commander_recon_systems:GetCastAnimation() return ACT_DOTA_CAST_ABILITY_1 end
--------------------------------------------------------------------------------------------------------
function keen_commander_recon_systems:OnSpellStart()
	--print("keen_commander_recon_systems:OnSpellStart()")
	local vCursorPos = self:GetCursorTarget():GetOrigin()
	local fBotDuration = 20 or self:GetSpecialValueFor("shock_bot_duration")
	local tTrees = GridNav:GetAllTreesAroundPoint(vCursorPos, 10, false)

	--print(#tTrees)
	-- tTrees[1]:AddNewModifier(self:GetCaster(), self, "modifier_recon_systems_bot_aura", { duration = fBotDuration })
	local reconunit = CreateUnitByName("npc_dota_unit_recon",vCursorPos,false,self:GetCaster(),nil,self:GetCaster():GetTeamNumber())
	--reconunit:AddNoDraw()
	reconunit:AddNewModifier(self:GetCaster(),self,"modifier_recon_systems_bot_aura",{duration = fBotDuration})
	--CreateModifierThinker(self:GetCaster(), self, "modifier_recon_systems_bot_aura", { duration = fBotDuration }, vCursorPos, self:GetCaster():GetTeamNumber(), false)
end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_recon_systems_bot_aura													
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_bot_aura == nil then modifier_recon_systems_bot_aura = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:RemoveOnDeath() return true end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetModifierAura()	return "modifier_recon_systems_bot_shock" end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("shock_range") end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:GetAuraEntityReject( hEntity )
	if IsServer() then	
		if hEntity:HasModifier("modifier_recon_systems_shock_nulled") then 
			return true 
		end
	end
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:OnCreated(kv)
	if IsServer() then
		print("modifier_recon_systems_bot_aura:OnCreated")	
		local fBotRadius = self:GetAbility():GetSpecialValueFor("shock_range")		
		DebugDrawCircle(self:GetParent():GetOrigin(), Vector(255,255,0), 1, fBotRadius, false, self:GetDuration())
		self:StartIntervalThink(1/30)
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_aura:OnIntervalThink()
	if IsServer() then
		local tTrees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetOrigin(), 10, false)
		if #tTrees < 1 then self:Destroy() end

		local fBotRadius = self:GetAbility():GetSpecialValueFor("shock_range")
		local tEnemyUnits = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), nil, fBotRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 2, false)
		DebugDrawCircle(self:GetParent():GetOrigin(), Vector(255,255,0), 1, fBotRadius, false, 1/30)

		if #tEnemyUnits > 0 then
			for i=1, #tEnemyUnits do
				DebugDrawSphere(tEnemyUnits[i]:GetOrigin(), Vector(255,255,255), 1, tEnemyUnits[i]:GetHullRadius(), false, 1/30)
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_recon_systems_shock_nulled													
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_shock_nulled == nil then modifier_recon_systems_shock_nulled = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_shock_nulled:OnCreated()
	if IsServer() then
		print("modifier_recon_systems_shock_nulled:OnCreated")
		local fNullDuration = self:GetAbility():GetSpecialValueFor("shock_null_duration")
		print(fNullDuration)
		self:SetDuration( fNullDuration, true )
	end
end
--------------------------------------------------------------------------------------------------------
--function modifier_recon_systems_shock_nulled:GetTexture() return "hero_keen_commander/keen_commander_recon_systems_null" end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_recon_systems_bot_shock													
--------------------------------------------------------------------------------------------------------
if modifier_recon_systems_bot_shock == nil then modifier_recon_systems_bot_shock = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_shock:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_shock:GetModifierMoveSpeedBonus_Percentage() return -(self:GetAbility():GetSpecialValueFor("movespeed_slow_percentage")) end
--------------------------------------------------------------------------------------------------------
function modifier_recon_systems_bot_shock:OnCreated()
	if IsServer() then
		print("modifier_recon_systems_bot_shock:OnCreated")
		local fShockDamage = self:GetAbility():GetLevelSpecialValueFor("shock_damage", self:GetAbility():GetLevel()-1)
		local fSlowDuration = self:GetAbility():GetLevelSpecialValueFor("slow_duration", self:GetAbility():GetLevel()-1)	
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_recon_systems_shock_nulled", {})
		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetLevelSpecialValueFor("shock_damage", self:GetAbility():GetLevel()-1),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
			})
		self:SetDuration(fSlowDuration, true)
	end
end