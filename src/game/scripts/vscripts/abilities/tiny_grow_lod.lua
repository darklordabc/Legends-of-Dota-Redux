if tiny_grow_lod == nil then tiny_grow_lod = class({}) end 

LinkLuaModifier("modifier_tiny_grow_lod", "heroes/hero_tiny/tiny_grow_lod.lua", LUA_MODIFIER_MOTION_NONE) --- PATH WERY IMPORTANT
LinkLuaModifier("modifier_tiny_grow_lod_tree", "heroes/hero_tiny/tiny_grow_lod.lua", LUA_MODIFIER_MOTION_NONE) --- PATH WERY IMPORTANT

local banana 

function tiny_grow_lod:GetIntrinsicModifierName()
    return "modifier_tiny_grow_lod"
end

function tiny_grow_lod:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function tiny_grow_lod:OnUpgrade()
    if IsServer() then
		if self:GetCaster():GetUnitName() == "npc_dota_hero_tiny" then
			local level_1 = "models/heroes/tiny_02/tiny_02.vmdl"
			local level_2 = "models/heroes/tiny_03/tiny_03.vmdl"
			local level_3 = "models/heroes/tiny_04/tiny_04.vmdl"
            if self:GetCaster():HasScepter() then
                if banana then
                    UTIL_Remove(banana)
                    banana = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_01/tiny_01_tree.vmdl"})
				    banana:FollowEntity(self:GetCaster(), true)
                end 
            end
            local wearables = {} 
            local cur = self:GetCaster():FirstMoveChild() 
            while cur ~= nil do 
                cur = cur:NextMovePeer()
                if cur ~= nil and cur:GetClassname() ~= "" and cur:GetClassname() == "dota_item_wearable" then 
                    table.insert(wearables, cur) 
                end
            end
            for i = 1, #wearables do 
                UTIL_Remove(wearables[i])
            end

			if self:GetLevel() == 1 then
				self:GetCaster():SetOriginalModel(level_1)
				self.torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_body.vmdl"})
				self.torso:FollowEntity(self:GetCaster(), true)
				self.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_head.vmdl"})
				self.head:FollowEntity(self:GetCaster(), true)
				self.left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_left_arm.vmdl"})
				self.left_arm:FollowEntity(self:GetCaster(), true)
				self.rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_right_arm.vmdl"})
				self.rigt_arm:FollowEntity(self:GetCaster(), true)
            elseif self:GetLevel() == 2 then
				self:GetCaster():SetOriginalModel(level_2)
				UTIL_Remove(self.torso)
				UTIL_Remove(self.head)
				UTIL_Remove(self.left_arm)
				UTIL_Remove(self.rigt_arm)
				
				self.torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_body.vmdl"})
				self.torso:FollowEntity(self:GetCaster(), true)
				self.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_head.vmdl"})
				self.head:FollowEntity(self:GetCaster(), true)
				self.left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_left_arm.vmdl"})
				self.left_arm:FollowEntity(self:GetCaster(), true)
				self.rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_right_arm.vmdl"})
                self.rigt_arm:FollowEntity(self:GetCaster(), true)
			elseif self:GetLevel() == 3 then
			UTIL_Remove(self.torso)
				self:GetCaster():SetOriginalModel(level_3)
				UTIL_Remove(self.head)
				UTIL_Remove(self.left_arm)
				UTIL_Remove(self.rigt_arm)
				
				self.torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_body.vmdl"})
				self.torso:FollowEntity(self:GetCaster(), true)
				self.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_head.vmdl"})
				self.head:FollowEntity(self:GetCaster(), true)
				self.left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_left_arm.vmdl"})
				self.left_arm:FollowEntity(self:GetCaster(), true)
				self.rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_right_arm.vmdl"})
                self.rigt_arm:FollowEntity(self:GetCaster(), true)
			end
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
    if self:GetCaster():GetUnitName() == "npc_dota_hero_tiny" then
			self:StartIntervalThink(0.1)
    end
	end
end

function modifier_tiny_grow_lod:OnIntervalThink()
	if self:GetCaster():GetUnitName() == "npc_dota_hero_tiny" then
		if self:GetParent():HasScepter() then
			if banana == nil then
				banana = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_01/tiny_01_tree.vmdl"})
				banana:FollowEntity(self:GetParent(), true)
            end
		else
			if banana then
				UTIL_Remove(banana)
			end
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
        if self:GetParent():HasScepter() then
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
    end
    return 0
end
