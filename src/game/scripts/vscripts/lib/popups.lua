-- partially copied from Elements TD

local popup = {}
 
POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8


-- Cherub: Explosive Spore damage
function PopupSporeDamage(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local amount = keys.Damage
    local damageType = ability:GetAbilityDamageType()


    amount = CalculateDamage(caster, target, amount, damageType)
    if not target:IsMagicImmune() then
        PopupNumbers(target, "damage", Vector(255, 255, 153), 2.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
    end
end

function CalculateDamage( caster, target, amount, damageType )
    if damageType == DAMAGE_TYPE_MAGICAL then
        amount = amount - (amount * target:GetMagicalArmorValue())
    elseif damageType == DAMAGE_TYPE_PHYSICAL then
        local armor = target:GetPhysicalArmorValue()
        local damageReduction = ((0.02 * armor) / (1 + 0.02 * armor))
        amount = amount - (amount * damageReduction)
    end


    local lens_count = 0
    for i=0,5 do
        local item = caster:GetItemInSlot(i)
        if item ~= nil and item:GetName() == "item_aether_lens" then
            lens_count = lens_count + 1
        end
    end
    amount = amount * (1 + (.05 * lens_count) + ( .01 * caster:GetIntellect() / 16 ))

    return math.floor(amount)
end

-- Customizable version.
function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx
    if pfx == "gold" or pfx == "lumber" then
        pidx = ParticleManager:CreateParticleForTeam(pfxPath, PATTACH_CUSTOMORIGIN, target, target:GetTeamNumber())
    else
        pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_CUSTOMORIGIN, target)
    end

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function PopupMultiplier(target, number)
    local particleName = "particles/custom/alchemist_unstable_concoction_timer.vpcf"
    local preSymbol = 0 --none
    local postSymbol = 4 --crit
    local digits = string.len(number)+1
    local targetPos = target:GetAbsOrigin()

    local particle = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, target )
    ParticleManager:SetParticleControl(particle, 0, Vector(targetPos.x, targetPos.y, targetPos.z+322))
    ParticleManager:SetParticleControl( particle, 1, Vector( preSymbol, number, postSymbol) )
    ParticleManager:SetParticleControl( particle, 2, Vector( digits, 0, 0) )
end
