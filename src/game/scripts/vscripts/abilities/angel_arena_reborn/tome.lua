local Constants = require('constants') -- XP TABLE
LinkLuaModifier( "modifier_medical_tractate",	'abilities/angel_arena_reborn/modifier_medical_tractate', LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stats_tome",	'abilities/angel_arena_reborn/tome', LUA_MODIFIER_MOTION_NONE )

modifier_stats_tome = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
	AllowIllusionDuplicate = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,} end,
	GetModifierBonusStats_Strength = function(self) return self.str and self.str * self:GetStackCount() end,
	GetModifierBonusStats_Agility = function(self) return self.agi and self.agi * self:GetStackCount() end,
	GetModifierBonusStats_Intellect = function(self) return self.int and self.int * self:GetStackCount() end,
	OnRefresh = function(self, kv) self:OnCreated(kv) end,
	OnCreated = function(self, kv) self[kv.stat] = self:GetAbility():GetSpecialValueFor(kv.stat) end,
	OnStackCountChanged = function(self, count) self:ForceRefresh() end,
}

function UpgradeStats(keys)
	local caster = keys.caster
	--local cost = keys.ability:GetCost() 
	local str = keys.ability:GetSpecialValueFor("str")
	local agi = keys.ability:GetSpecialValueFor("agi")
	local int = keys.ability:GetSpecialValueFor("int")

	if not caster or not caster:IsRealHero() then return end
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return end
	
	--_G.tPlayers[caster:GetPlayerOwnerID() ] = _G.tPlayers[caster:GetPlayerOwnerID() ] or {}
	--_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books or 0
	--_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books + cost

	--if str then caster:ModifyStrength(str) end
	--if agi then caster:ModifyAgility(agi) end
	--if int then caster:ModifyIntellect(int) end
	
	if keys.ability:GetName() == "angel_arena_tome_agi" or keys.ability:GetName() == "angel_arena_tome_agi_op" then
		caster.agiTomesUsed = caster.agiTomesUsed and caster.agiTomesUsed + 1 or 1

		caster.agiMod = caster.agiMod or caster:AddNewModifier(caster, keys.ability, "modifier_stats_tome", {stat = "agi"})
		caster.agiMod:SetStackCount(caster.agiTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, caster.agiTomesUsed, nil)
	end

	if keys.ability:GetName() == "angel_arena_tome_str" or keys.ability:GetName() == "angel_arena_tome_str_op" then
		caster.strTomesUsed = caster.strTomesUsed and caster.strTomesUsed + 1 or 1

		caster.strMod = caster.strMod or caster:AddNewModifier(caster, keys.ability, "modifier_stats_tome", {stat = "str"})
		caster.strMod:SetStackCount(caster.strTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, caster, caster.strTomesUsed, nil)
	end

	if keys.ability:GetName() == "angel_arena_tome_int" or keys.ability:GetName() == "angel_arena_tome_int_op" then
		caster.intTomesUsed = caster.intTomesUsed and caster.intTomesUsed + 1 or 1

		caster.intMod = caster.intMod or caster:AddNewModifier(caster, keys.ability, "modifier_stats_tome", {stat = "int"})
		caster.intMod:SetStackCount(caster.intTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, caster.intTomesUsed, nil)
	end

	if keys.ability:GetName() == "angel_arena_tome_gods" or keys.ability:GetName() == "angel_arena_tome_gods_op" then
		caster.agiTomesUsed = caster.agiTomesUsed and caster.agiTomesUsed + 1 or 1
		caster.strTomesUsed = caster.strTomesUsed and caster.strTomesUsed + 1 or 1
		caster.intTomesUsed = caster.intTomesUsed and caster.intTomesUsed + 1 or 1

		caster.agiMod = caster.agiMod or caster:AddNewModifier(caster, keys.ability, "modifier_stats_tome", {stat = "agi"})
		caster.agiMod:SetStackCount(caster.agiTomesUsed)

		caster.strMod = caster.strMod or caster:AddNewModifier(caster, keys.ability, "modifier_stats_tome", {stat = "str"})
		caster.strMod:SetStackCount(caster.strTomesUsed)

		caster.intMod = caster.intMod or caster:AddNewModifier(caster, keys.ability, "modifier_stats_tome", {stat = "int"})
		caster.intMod:SetStackCount(caster.intTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_XP, caster, caster.intTomesUsed, nil)
	end
end


function tome_levelup(keys)
	local caster = keys.caster
	--local ability = self
	if not caster or not caster:IsRealHero() then return end
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return end
	local level = caster:GetLevel()
	local need_exp = Constants.XP_PER_LEVEL_TABLE[level+1]
	local old_exp = Constants.XP_PER_LEVEL_TABLE[level]
	if not need_exp then need_exp = 0 end
	if not old_exp then old_exp = 0 end
	--local cost = keys.ability:GetCost() 
	--_G.tPlayers[caster:GetPlayerOwnerID() ] = _G.tPlayers[caster:GetPlayerOwnerID() ] or {}
	--_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books or 0
	--_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books + cost

	local expFactor = keys.ability:GetSpecialValueFor("exp") / 100

	print(need_exp - old_exp)
	local expNeededForNextLevel = need_exp - old_exp
	local giveExp = expNeededForNextLevel * expFactor
	--caster:HeroLevelUp(true)
	caster:AddExperience(giveExp, 0, true, true)

	if not caster.lvllTomesUsed then
		caster.lvllTomesUsed = 1 
	else
		caster.lvllTomesUsed = caster.lvllTomesUsed + 1
	end
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, caster, caster.lvllTomesUsed, nil)
end

function MedicalTractat(keys)
	local caster = keys.caster
	if not caster then return end
	
	if not(caster.medical_tractates) then
		caster.medical_tractates = 0
	end
	--local cost = keys.ability:GetCost() 
	--_G.tPlayers[caster:GetPlayerOwnerID() ] = _G.tPlayers[caster:GetPlayerOwnerID() ] or {}
	--_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books or 0
	--_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books + cost

	caster.medical_tractates = caster.medical_tractates + 1
	
	caster:RemoveModifierByName("modifier_medical_tractate") 
	while (caster:HasModifier("modifier_medical_tractate")) do
		caster:RemoveModifierByName("modifier_medical_tractate") 
	end
	caster:AddNewModifier(caster, nil, "modifier_medical_tractate", null)

end

function Eat_gem(keys)
	local caster = keys.caster
	if not caster then return end
	if not caster:IsRealHero() then return end

	caster.item_gem = CreateItem("item_gem", caster, caster) 
	caster:AddNewModifier(caster, caster.item_gem, "modifier_item_gem_of_true_sight", {})
end
