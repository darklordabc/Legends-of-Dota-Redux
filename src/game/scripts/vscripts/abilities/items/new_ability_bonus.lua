item_new_ability_bonus = class({})

if IsServer() then
  function item_new_ability_bonus:OnSpellStart()
    local caster = self:GetCaster()
    local gold = GameRules.pregame.optionStore["lodOptionNewAbilitiesBonusGold"]
    caster:ModifyGold(gold, true, DOTA_ModifyGold_Unspecified)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, nil)
    self:SpendCharge()
  end
end
