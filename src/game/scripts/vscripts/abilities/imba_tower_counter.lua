imba_tower_counter = class({})

function imba_tower_counter:GetIntrinsicModifierName()
  return "modifier_imba_tower_counter"
end

LinkLuaModifier( "modifier_imba_tower_counter", "abilities/imba_tower_counter.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_imba_tower_counter = class({})

function modifier_imba_tower_counter:IsPassive()
    return true
end

function modifier_imba_tower_counter:OnCreated(keys)
    if IsServer() then
        self:StartIntervalThink(1.0)
    end
end

function modifier_imba_tower_counter:GetTexture()
    return "custom/strongtower"
end

function modifier_imba_tower_counter:OnIntervalThink(keys)
    local caster = self:GetCaster()

    local towers = LoadKeyValues('scripts/kv/towers.kv')

    local power = 0

    for i=0,23 do
        local ab = caster:GetAbilityByIndex(i)

        if ab and towers[ab:GetName()] then
            power = power + towers[ab:GetName()]
        end
    end

    caster:FindModifierByName("modifier_imba_tower_counter"):SetStackCount(power)
end