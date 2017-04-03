function bleedDamage( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local hpToDamage = ability:GetLevelSpecialValueFor("bleed_damage", ability:GetLevel() - 1) / 100
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = math.ceil(target:GetHealth() * hpToDamage),
        damage_type = DAMAGE_TYPE_PURE,
        }
    ApplyDamage(damageTable)
end

function ApplyBleed( event )
    local caster = event.caster
    local attacker = event.attacker
    local target = event.unit
    local ability = event.ability

    if attacker:IsHero() then
        ability:ApplyDataDrivenModifier(caster,target,"modifier_hylonome_anemic_aura_thinker",{})
    end
end

function takeDamage( event )
    local target = event.unit
    target.preHeal = target:GetHealth()
end

function removeAnemic( event )
    event.target.anemicHealth = nil
    event.target.anemicHalf = nil
end

function anemicAura( event )
    local caster = event.caster
    local target = event.unit
    local ability = event.ability
    local auraLevel = ability:GetLevelSpecialValueFor("heal_reduction" , ability:GetLevel() - 1 ) --[[20 / 30 / 40 / 50]]

    if not target:IsAlive() then return end

    if target.anemicHealth == nil then target.anemicHealth = target:GetHealth() end
    if target.anemicHalf == nil then target.anemicHalf = 0 end

    local anemicAmount = (target.anemicHealth - target:GetHealth()) * (auraLevel / 100)
    
    if anemicAmount < 0 then
        target.anemicHalf = target.anemicHalf + (math.floor(anemicAmount) - anemicAmount)
        if target.anemicHalf > -1 then
            target:SetHealth(target:GetHealth() + anemicAmount)
        else 
             target:SetHealth(target:GetHealth() + anemicAmount + 1)
             target.anemicHalf = target.anemicHalf + 1
        end
    end

    target.anemicHealth = target:GetHealth()
end