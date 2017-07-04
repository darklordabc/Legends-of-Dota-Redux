gold_bonus = {}

if IsServer() then
  function gold_bonus:OnSpellStart()
    local caster = self:GetCaster()
    local gold = self:GetGold()
    caster:ModifyGold(gold, true, DOTA_ModifyGold_Unspecified)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, nil)
    self:SpendCharge()
  end
end


item_new_ability_bonus = class(gold_bonus)
function item_new_ability_bonus:GetGold()
	--return GameRules.pregame.optionStore["lodOptionNewAbilitiesBonusGold"]
  return 250
end

item_new_global_ability_bonus = class(gold_bonus)
function item_new_global_ability_bonus:GetGold()
	return 250
end

item_balanced_build_bonus = class(gold_bonus)
function item_balanced_build_bonus:GetGold()
	return 1000
end
