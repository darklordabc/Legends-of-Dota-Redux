 -- Author: Shush
 -- Date: 08/03/2017

----------------------------
--		DEADEYE		      --
----------------------------

imba_drow_ranger_deadeye = class({})
LinkLuaModifier("modifier_imba_deadeye_aura", "abilities/dota imba/deadeye", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_deadeye_vision", "abilities/dota imba/deadeye", LUA_MODIFIER_MOTION_NONE)

function imba_drow_ranger_deadeye:GetAbilityTextureName()
   return "custom/drow_deadeye"
end

function imba_drow_ranger_deadeye:IsInnateAbility()
	return true
end

function imba_drow_ranger_deadeye:GetIntrinsicModifierName()
	return "modifier_imba_deadeye_aura"
end

function imba_drow_ranger_deadeye:OnUpgrade()
    if IsServer() then
        local caster = self:GetCaster()    
        caster:RemoveModifierByName("modifier_imba_deadeye_aura")    
        caster:AddNewModifier(caster, self, "modifier_imba_deadeye_aura", {})
    end
end

-- Aura modifier
modifier_imba_deadeye_aura = class({})

function modifier_imba_deadeye_aura:OnCreated()
	self.caster = self:GetCaster()
    self.modifier_active = "modifier_imba_trueshot_active"
end

function modifier_imba_deadeye_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_imba_deadeye_aura:GetAuraEntityReject(target)
    if IsServer() then
	   -- Never reject caster	
    	if target == self.caster then
    		return false
    	end    	

    	-- #7 Talent: Deadeye becomes an aura
        --if self.caster:HasTalent("special_bonus_imba_drow_ranger_7") then
        --    if target:IsHero() then
        --        return false
        --    end            
        --end        

        return true
    end	
end

function modifier_imba_deadeye_aura:GetAuraRadius()
	return 25000 --global
end

function modifier_imba_deadeye_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_imba_deadeye_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_imba_deadeye_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_imba_deadeye_aura:GetModifierAura()
	return "modifier_imba_deadeye_vision"
end

function modifier_imba_deadeye_aura:IsAura()
	-- Stops working when the caster is Broken
	if self.caster:PassivesDisabled() then
		return false
	end

	return true
end

function modifier_imba_deadeye_aura:IsDebuff()
	return false
end

function modifier_imba_deadeye_aura:IsHidden()
	return true
end

function modifier_imba_deadeye_aura:IsPurgable()
	return false
end

-- Vision modifier
modifier_imba_deadeye_vision = class({})

function modifier_imba_deadeye_vision:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	self.day_vision = self.ability:GetSpecialValueFor("day_vision")
	self.night_vision = self.ability:GetSpecialValueFor("night_vision")
end

function modifier_imba_deadeye_vision:DeclareFunctions()
	local decFunc = {MODIFIER_PROPERTY_BONUS_DAY_VISION,
					MODIFIER_PROPERTY_BONUS_NIGHT_VISION}

	return decFunc
end

function modifier_imba_deadeye_vision:GetBonusDayVision()
    --if IsServer() then
        -- #6 Talent: Deadeye vision bonuses        
    --    local vision_bonus = self.caster:FindTalentValue("special_bonus_imba_drow_ranger_6")
    --    CustomNetTables:SetTableValue("talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID()), {vision_bonus = vision_bonus})        
    --end

    local day_vision = self.day_vision

    --if CustomNetTables:GetTableValue( "talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID())) then          
    --    if CustomNetTables:GetTableValue( "talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID())).vision_bonus then
    --        day_vision = day_vision + CustomNetTables:GetTableValue( "talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID())).vision_bonus
    --    end        
    --end

	return day_vision
end

function modifier_imba_deadeye_vision:GetBonusNightVision()
     local night_vision = self.night_vision

    --if CustomNetTables:GetTableValue( "talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID())) then          
    --    if CustomNetTables:GetTableValue( "talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID())).vision_bonus then
    --        night_vision = night_vision + CustomNetTables:GetTableValue( "talents", "hero_drow_ranger_talents"..tostring(self.caster:GetPlayerOwnerID())).vision_bonus
    --    end        
    --end   

	return night_vision
end

function modifier_imba_deadeye_vision:IsHidden()
	return false
end

function modifier_imba_deadeye_vision:IsPurgable()
	return false
end

function modifier_imba_deadeye_vision:IsDebuff()
	return false
end