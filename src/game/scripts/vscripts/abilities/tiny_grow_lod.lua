if tiny_grow_lod == nil then tiny_grow_lod = class({}) end 

LinkLuaModifier("modifier_tiny_grow_lod", "abilities/tiny_grow_lod.lua", LUA_MODIFIER_MOTION_NONE) --- PATH WERY IMPORTANT

function tiny_grow_lod:GetIntrinsicModifierName()
    return "modifier_tiny_grow_lod"
end

function tiny_grow_lod:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function tiny_grow_lod:OnUpgrade()
    if IsServer() then
		local level_1 = "models/heroes/tiny_02/tiny_02_body.vmdl"
		local level_2 = "models/heroes/tiny_03/tiny_03_body.vmdl"
		local level_3 = "models/heroes/tiny_04/tiny_04_body.vmdl"
		if self:GetLevel() == 1 then
			self:GetCaster():SetOriginalModel(level_1)
		elseif self:GetLevel() == 2 then
			self:GetCaster():SetOriginalModel(level_2)
		elseif self:GetLevel() == 3 then
			self:GetCaster():SetOriginalModel(level_3)
		end
	end
end

if modifier_tiny_grow_lod == nil then modifier_tiny_grow_lod = class({}) end

function modifier_tiny_grow_lod:IsHidden()
	return true
end

function modifier_tiny_grow_lod:IsPurgable()
	return false
end

function modifier_tiny_grow_lod:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_tiny_grow_lod:OnIntervalThink()
	if self:GetParent():HasScepter() then
		if self.banana ~= nil then
			self.banana = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_01/tiny_01_tree.vmdl"})
			self.banana:FollowEntity(self:GetParent(), true)
		end
	else
		if self.banana then
			UTIL_Remove(self.banana)
		end
	end
end

function modifier_tiny_grow_lod:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end
function modifier_tiny_grow_lod:GetModifierMoveSpeedBonus_Constant (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_movement_speed")
end
function modifier_tiny_grow_lod:GetModifierPreAttack_BonusDamage (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage")
end
function modifier_tiny_grow_lod:GetModifierAttackSpeedBonus_Constant (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_attack_speed")
end

function modifier_tiny_grow_lod:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
            if self:GetParent():PassivesDisabled() then
                return 0
            end
            local target = params.target
            EmitSoundOn( "DOTA_Item.BattleFury", target )
            if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
                local cleaveDamage = ( self:GetAbility():GetSpecialValueFor( "bonus_cleave_damage_scepter" ) * params.damage ) / 100.0
                DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleaveDamage, self:GetAbility():GetSpecialValueFor( "bonus_cleave_radius_scepter" ), "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
            end
   
         end
    end
    return 0
end