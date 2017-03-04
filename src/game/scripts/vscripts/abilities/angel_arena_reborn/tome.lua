local Constants = require('constants') -- XP TABLE
LinkLuaModifier( "modifier_medical_tractate",	'abilities/angel_arena_reborn/modifier_medical_tractate', 	LUA_MODIFIER_MOTION_NONE )
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

	if str then caster:ModifyStrength(str) end
	if agi then caster:ModifyAgility(agi) end
	if int then caster:ModifyIntellect(int) end
	
	if keys.ability:GetName() == "angel_arena_tome_agi" then
		if not caster.agiTomesUsed then
			caster.agiTomesUsed = 1 
		else
			caster.agiTomesUsed = caster.agiTomesUsed + 1
		end
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, caster.agiTomesUsed, nil)
	end

	if keys.ability:GetName() == "angel_arena_tome_str" then
		if not caster.strTomesUsed then
			caster.strTomesUsed = 1 
		else
			caster.strTomesUsed = caster.strTomesUsed + 1
		end
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, caster, caster.strTomesUsed, nil)
	end

	if keys.ability:GetName() == "angel_arena_tome_int" then
		if not caster.intTomesUsed then
			caster.intTomesUsed = 1 
		else
			caster.intTomesUsed = caster.intTomesUsed + 1
		end
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, caster.intTomesUsed, nil)
	end

	if keys.ability:GetName() == "angel_arena_tome_gods" then
		if not caster.intTomesUsed then
			caster.intTomesUsed = 1 
		else
			caster.intTomesUsed = caster.intTomesUsed + 1
		end
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