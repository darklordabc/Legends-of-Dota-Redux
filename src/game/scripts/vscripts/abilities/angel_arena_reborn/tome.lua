local Constants = require('constants') -- XP TABLE
LinkLuaModifier( "modifier_medical_tractate",	'abilities/angel_arena_reborn/modifier_medical_tractate', LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stats_tome",	'abilities/angel_arena_reborn/tome', LUA_MODIFIER_MOTION_NONE )

--each tome ability will apply their own instance of this modifier
modifier_stats_tome = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
	--AllowIllusionDuplicate = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,} end,
	GetModifierBonusStats_Strength = function(self) return self.str and self.str * self:GetStackCount() end,
	GetModifierBonusStats_Agility = function(self) return self.agi and self.agi * self:GetStackCount() end,
	GetModifierBonusStats_Intellect = function(self) return self.int and self.int * self:GetStackCount() end,

	OnStackCountChanged = function(self, count) self:OnCreated({stat = self.stat}) end,
	OnCreated = function(self, kv)
		if IsServer() then
			self.stat = self.stat or kv.stat
			self[self.stat] = self[self.stat] or self:GetAbility():GetSpecialValueFor(self.stat)
			self:GetParent():CalculateStatBonus()
		end
	end,
}

--these two listeners are just for volvos illusions. the tome modifiers are given to custom illusions in the util function that makes them
ListenToGameEvent("dota_illusions_created", function(keys)
	_G.lastIllusionCreator = keys.original_entindex
end, nil)

ListenToGameEvent("npc_spawned", function(keys)
	local illusion = EntIndexToHScript(keys.entindex)

	--not using timers here because it was giving me errors
	illusion:SetContextThink(DoUniqueString("statTomesForIllusions"), function()
		
		--make sure this is a valve illusion
		if not illusion or illusion:IsNull() or not illusion:IsIllusion() or illusion:HasModifier("modifier_stats_tome") then return end

		local original = _G.lastIllusionCreator and EntIndexToHScript(_G.lastIllusionCreator)
		if not original or original:IsNull() then return end

		--make sure this unit actually has stats
		if illusion.GetStrength then
			--copy over all the stat modifiers from the original hero
			for k,v in pairs(original:FindAllModifiersByName("modifier_stats_tome")) do
				local instance = illusion:AddNewModifier(illusion, v:GetAbility(), "modifier_stats_tome", {stat = v.stat})
				instance:SetStackCount(v:GetStackCount())
			end
		end
		return
	end, 0.1)
end, nil)

--creates and stores a new stats modifier to preserve the previous uses of the lower level tomes.
function LevelTome(keys)
	if keys.caster:IsIllusion() then return end
	local name = keys.ability:GetName():gsub("_op", "")
	name = name:sub(name:len() - 2)

	--wait a frame so that the ability is actually leveled up.
	Timers:CreateTimer(function()
		--'gods'
		if name == "ods" then
			for k,v in pairs({"agi", "str", "int"}) do
				keys.ability[v.."Mod"] = keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_stats_tome", {stat = v})
			end
			return
		end
		keys.ability[name.."Mod"] = keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_stats_tome", {stat = name})
	end)
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
		ability.agiTomesUsed = ability.agiTomesUsed and ability.agiTomesUsed + 1 or 1
		ability.agiMod:IncrementStackCount()

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, ability.agiTomesUsed, nil)
	end

	if ability:GetName() == "angel_arena_tome_str" or ability:GetName() == "angel_arena_tome_str_op" then
		ability.strTomesUsed = ability.strTomesUsed and ability.strTomesUsed + 1 or 1
		ability.strMod:IncrementStackCount()

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, caster, ability.strTomesUsed, nil)
	end

	if ability:GetName() == "angel_arena_tome_int" or ability:GetName() == "angel_arena_tome_int_op" then
		ability.intTomesUsed = ability.intTomesUsed and ability.intTomesUsed + 1 or 1
		ability.intMod:IncrementStackCount()

		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, ability.intTomesUsed, nil)
	end

	if ability:GetName() == "angel_arena_tome_gods" or ability:GetName() == "angel_arena_tome_gods_op" then
		ability.godTomesUsed = ability.godTomesUsed and ability.godTomesUsed + 1 or 1

		ability.agiMod:IncrementStackCount()
		ability.strMod:IncrementStackCount()
		ability.intMod:IncrementStackCount()

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
