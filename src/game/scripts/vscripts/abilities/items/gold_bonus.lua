gold_bonus = {}
if IsServer() then
  function gold_bonus:OnSpellStart()
    local caster = self:GetCaster()
    local gold = math.floor(self:GetGold())
    
    -- SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, nil)
    if caster:HasModifier("gold_bonus_modifier") then
      local d = caster:FindModifierByName("gold_bonus_modifier"):GetRemainingTime()
      caster:FindModifierByName("gold_bonus_modifier"):SetDuration(d + gold, true)
    else
      caster:AddNewModifier(caster, self, "gold_bonus_modifier", { duration = gold })
    end
    caster:EmitSound("DOTA_Item.Hand_Of_Midas")
    caster:HeroLevelUp(true)
    self:SpendCharge()
  end
end

item_new_ability_bonus = class(gold_bonus)
function item_new_ability_bonus:GetGold()
	return GameRules.pregame.optionStore["lodOptionNewAbilitiesBonusGold"] / 16.6666667
end

item_new_global_ability_bonus = class(gold_bonus)
function item_new_global_ability_bonus:GetGold()
  return GameRules.pregame.optionStore["lodOptionGlobalNewAbilitiesBonusGold"] / 16.6666667
end

item_balanced_build_bonus = class(gold_bonus)
function item_balanced_build_bonus:GetGold()
  return GameRules.pregame.optionStore["lodOptionBalancedBuildBonusGold"] / 16.6666667
end

gold_bonus_modifier = {}

if IsServer() then
  function gold_bonus_modifier:OnCreated( args )
    self:StartIntervalThink(1.0)
  end

  function gold_bonus_modifier:OnIntervalThink()
    self:GetParent():ModifyGold(self:GetGold(), true, DOTA_ModifyGold_Unspecified)  
    
    self:SetStackCount(tonumber(string.sub(tostring(math.ceil(self:GetGold() * self:GetRemainingTime())), 0, 2)))
  end

  function gold_bonus_modifier:IsPurgable()
    return false
  end

  function gold_bonus_modifier:GetAttributes()
    local attrs = {
      MODIFIER_ATTRIBUTE_PERMANENT,
    }

    return attrs
  end
end

function gold_bonus_modifier:GetGold()
  return 16.6666667
end

function gold_bonus_modifier:GetTexture()
  return "alchemist_goblins_greed"
end
LinkLuaModifier("gold_bonus_modifier", "abilities/items/gold_bonus", LUA_MODIFIER_MOTION_NONE)

-- modifier_new_global_ability_bonus = class(gold_bonus_modifier)
-- function modifier_new_global_ability_bonus:GetGold()
--   return math.floor(GameRules.pregame.optionStore["lodOptionGlobalNewAbilitiesBonusGold"] / 60)
-- end
-- function modifier_new_global_ability_bonus:GetTexture()
--   return "alchemist_goblins_greed"
-- end
-- LinkLuaModifier("modifier_new_global_ability_bonus", "abilities/items/gold_bonus", LUA_MODIFIER_MOTION_NONE)

-- modifier_balanced_build_bonus = class(gold_bonus_modifier)
-- function modifier_balanced_build_bonus:GetGold()
--   return math.floor(GameRules.pregame.optionStore["lodOptionBalancedBuildBonusGold"] / 60)
-- end
-- function modifier_balanced_build_bonus:GetTexture()
--   return "alchemist_goblins_greed"
-- end
-- LinkLuaModifier("modifier_balanced_build_bonus", "abilities/items/gold_bonus", LUA_MODIFIER_MOTION_NONE)