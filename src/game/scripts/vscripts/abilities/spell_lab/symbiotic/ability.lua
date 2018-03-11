if spell_lab_symbiotic == nil then
	spell_lab_symbiotic = class({})
end

LinkLuaModifier("spell_lab_symbiotic_modifier", "abilities/spell_lab/symbiotic/modifier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spell_lab_symbiotic_target", "abilities/spell_lab/symbiotic/target.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spell_lab_symbiotic_bonus", "abilities/spell_lab/symbiotic/bonus.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_symbiotic:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	if self:GetCaster():HasModifier("spell_lab_symbiotic_modifier") then
		behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return behav
end

function spell_lab_symbiotic:OnSpellStart()
	if self:GetCaster():HasModifier("spell_lab_symbiotic_modifier") then
		self:EndSymbiosis()
	else
		self:StartSymbiosis(self:GetCursorTarget())
	end
end

function spell_lab_symbiotic:CastFilterResultTarget( hTarget )
	local nCasterID = self:GetCaster():GetPlayerOwnerID()
	local nTargetID = hTarget:GetPlayerOwnerID()
	if self:GetCaster() == hTarget then return UF_FAIL_CUSTOM end
		if self:GetCaster():HasModifier("spell_lab_symbiotic_target") then return UF_FAIL_CUSTOM end
		--if hTarget:IsCourier() then
		--	return UF_SUCCESS
		--end
		--	if hTarget:HasAbility("life_stealer_infest") then return UF_FAIL_CUSTOM end
	if IsServer() and not hTarget:IsOpposingTeam(self:GetCaster():GetTeamNumber()) and PlayerResource:IsDisableHelpSetForPlayerID(nTargetID,nCasterID) then
		return UF_FAIL_DISABLE_HELP
	end

	return UnitFilter(hTarget,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_CHECK_DISABLE_HELP,
		self:GetCaster():GetTeamNumber() )
end

function spell_lab_symbiotic:GetCustomCastErrorTarget(hTarget)
if self:GetCaster() == hTarget then return "#DOTA_Error_spell_lab_symbiotic_no_self_target" end
	--if hTarget:HasAbility("life_stealer_infest") then return "#DOTA_Error_spell_lab_symbiotic_no_infest_target" end
	if self:GetCaster():HasModifier("spell_lab_symbiotic_target") then return "#DOTA_Error_spell_lab_symbiotic_no_inception" end
end
function spell_lab_symbiotic:StartSymbiosis(hTarget)
	if self:GetCaster():HasModifier("spell_lab_symbiotic_target") then return end
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Bane.Nightmare", self:GetCaster() )
	local hModifier = hTarget:AddNewModifier( self:GetCaster(), self, "spell_lab_symbiotic_target", {} )
	local hSymbiot = self:GetCaster():AddNewModifier( self:GetCaster(), self, "spell_lab_symbiotic_modifier", {} )
	hSymbiot:SetHost(hTarget,hModifier)
	hModifier:InitSymbiot(hSymbiot)
end


function spell_lab_symbiotic:EndSymbiosis()
	local hSymbiot = self:GetCaster():FindModifierByName("spell_lab_symbiotic_modifier")
	hSymbiot:Terminate(nil)
	self:EndCooldown()
end
