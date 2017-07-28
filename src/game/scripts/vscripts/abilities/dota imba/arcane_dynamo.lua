--[[ Author: Hewdraw, Noobsauce ]]

--CreateEmptyTalents("crystal_maiden")

---------------------------------
-- 		   Arcane Dynamo       --
---------------------------------

imba_crystal_maiden_arcane_dynamo = class({})
LinkLuaModifier("modifier_imba_arcane_dynamo", "abilities/dota imba/arcane_dynamo.lua", LUA_MODIFIER_MOTION_NONE)

function imba_crystal_maiden_arcane_dynamo:GetIntrinsicModifierName() return "modifier_imba_arcane_dynamo" end
function imba_crystal_maiden_arcane_dynamo:IsInnateAbility() return true end

function imba_crystal_maiden_arcane_dynamo:GetAbilityTextureName()
   return "custom/crystal_maiden_arcane_dynamo"
end

function imba_crystal_maiden_arcane_dynamo:OnUpgrade()
    if IsServer() then
        local caster = self:GetCaster()    
        caster:RemoveModifierByName("modifier_imba_arcane_dynamo")    
        caster:AddNewModifier(caster, self, "modifier_imba_arcane_dynamo", {})
    end
end

imba_crystal_maiden_arcane_dynamo_op = class({})

function imba_crystal_maiden_arcane_dynamo_op:GetIntrinsicModifierName() return "modifier_imba_arcane_dynamo" end
function imba_crystal_maiden_arcane_dynamo_op:IsInnateAbility() return true end

function imba_crystal_maiden_arcane_dynamo_op:GetAbilityTextureName()
   return "custom/crystal_maiden_arcane_dynamo_op"
end

function imba_crystal_maiden_arcane_dynamo_op:OnUpgrade()
    if IsServer() then
        local caster = self:GetCaster()    
        caster:RemoveModifierByName("modifier_imba_arcane_dynamo")    
        caster:AddNewModifier(caster, self, "modifier_imba_arcane_dynamo", {})
    end
end

---------------------------------
-- Arcane Dynamo Modifier      --
---------------------------------
modifier_imba_arcane_dynamo = class({})

function modifier_imba_arcane_dynamo:IsHidden() return false end
function modifier_imba_arcane_dynamo:IsDebuff() return false end
function modifier_imba_arcane_dynamo:IsPurgable() return false end

function modifier_imba_arcane_dynamo:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- Ability specials	
	--self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")

	-- Start thinking
	self:StartIntervalThink(0.2)
end

function modifier_imba_arcane_dynamo:OnIntervalThink()
	if IsServer() then
		-- If the caster is broken, reset the stacks
		if self.caster:PassivesDisabled() then
			self:SetStackCount(0)
			return nil
		end

		self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")

		local mana_percentage = self.caster:GetMana() / self.caster:GetMaxMana()
		local stacks = math.ceil(mana_percentage * self.max_stacks) 


		-- #4 Talent: Doubles Arcane Dynamo's effects
		--stacks = stacks * 1

		self:SetStackCount(stacks)
	end
end

function modifier_imba_arcane_dynamo:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					  MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
 	
 	return decFuncs
end

function modifier_imba_arcane_dynamo:GetModifierMoveSpeedBonus_Percentage()
   -- Does nothing if hero has break
	if self.caster:PassivesDisabled() then
		return nil
	end

	-- Does nothing if hero is illusion
	if self.caster:IsIllusion() then
		return nil
	end

	return self:GetStackCount()
end

function modifier_imba_arcane_dynamo:GetModifierSpellAmplify_Percentage()
	-- Does nothing if hero has break
	if self.caster:PassivesDisabled() then
		return nil
	end
	-- Does nothing if hero is illusion
	if self.caster:IsIllusion() then
		return nil
	end
	
	return self:GetStackCount()
end
