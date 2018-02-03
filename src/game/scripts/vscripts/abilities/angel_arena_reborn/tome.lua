local Constants = require('constants') -- XP TABLE
LinkLuaModifier( "modifier_medical_tractate",	'abilities/angel_arena_reborn/modifier_medical_tractate', LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stats_tome",	'abilities/angel_arena_reborn/tome', LUA_MODIFIER_MOTION_NONE )

--each tome ability will apply their own instance of this modifier
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

	OnStackCountChanged = function(self, count) self:OnCreated({stat = self.stat}) end,
	OnCreated = function(self, kv)
		if IsServer() then
			self.stat = self.stat or kv.stat
			self[self.stat] = self:GetAbility():GetSpecialValueFor(self.stat)
			print(self.stat, self[self.stat])
			self:GetParent():CalculateStatBonus()
		end
	end,
}

--creates and stores a new stats modifier to preserve the previous uses of the lower level tomes.
function LevelTome(keys)
	local name = string.sub(keys.ability:GetName(), name:len() - 3)
	--'gods'
	if name == "ods" then
		for k,v in pairs({"agi", "str", "int"})
			keys.ability[v.."Mod"] = keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_stats_tome", {stat = v})
		end
		return
	end
	keys.ability[name.."Mod"] = keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_stats_tome", {stat = name})
end

function UpgradeStats(keys)
	local caster = keys.caster
	local ability = keys.ability
	--local cost = ability:GetCost() 
	local str = ability:GetSpecialValueFor("str")
	local agi = ability:GetSpecialValueFor("agi")
	local int = ability:GetSpecialValueFor("int")

	if not caster or not caster:IsRealHero() then return end
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return end

	if ability:GetName() == "angel_arena_tome_agi" or ability:GetName() == "angel_arena_tome_agi_op" then
		ability.agiMod = (ability.agiMod and not ability.agiMod:IsNull()) and ability.agiMod or caster:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = "agi"})

		ability.agiTomesUsed = ability.agiTomesUsed and ability.agiTomesUsed + 1 or 1
		ability.agiMod:SetStackCount(ability.agiTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, ability.agiTomesUsed, nil)
	end

	if ability:GetName() == "angel_arena_tome_str" or ability:GetName() == "angel_arena_tome_str_op" then
		ability.strMod = (ability.strMod and not ability.strMod:IsNull()) and ability.strMod or caster:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = "str"})

		ability.strTomesUsed = ability.strTomesUsed and ability.strTomesUsed + 1 or 1
		ability.strMod:SetStackCount(ability.strTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, caster, ability.strTomesUsed, nil)
	end

	if ability:GetName() == "angel_arena_tome_int" or ability:GetName() == "angel_arena_tome_int_op" then
		ability.intMod = (ability.intMod and not ability.intMod:IsNull()) and ability.intMod or caster:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = "int"})

		ability.intTomesUsed = ability.intTomesUsed and ability.intTomesUsed + 1 or 1
		ability.intMod:SetStackCount(ability.intTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, ability.intTomesUsed, nil)
	end

	if ability:GetName() == "angel_arena_tome_gods" or ability:GetName() == "angel_arena_tome_gods_op" then
		ability.agiMod = (ability.agiMod and not ability.agiMod:IsNull()) and ability.agiMod or caster:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = "agi"})
		ability.strMod = (ability.strMod and not ability.strMod:IsNull()) and ability.strMod or caster:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = "str"})
		ability.intMod = (ability.intMod and not ability.intMod:IsNull()) and ability.intMod or caster:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = "int"})

		ability.godTomesUsed = ability.godTomesUsed and ability.godTomesUsed + 1 or 1

		ability.agiMod:SetStackCount(ability.godTomesUsed)
		ability.strMod:SetStackCount(ability.godTomesUsed)
		ability.intMod:SetStackCount(ability.godTomesUsed)

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_XP, caster, ability.godTomesUsed, nil)
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
