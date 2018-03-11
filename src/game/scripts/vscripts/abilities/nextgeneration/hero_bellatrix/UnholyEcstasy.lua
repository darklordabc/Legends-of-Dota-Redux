-- Rip and Tear functions are here because I need to pass the damage value over from Unholy Ecstasy.
function UnholyEcstasy (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	local damageTaken = keys.DamageTaken
	local damagereduction = (ability:GetLevelSpecialValueFor("damage_reduction", ability:GetLevel() - 1 ) / 100) * -1
	local bonusdamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )
	if target.DamageCollection == nil then
		target.DamageCollection = 0
		damagedone = 0
	end

	target.DamageCollection = target.DamageCollection + (damageTaken*damagereduction)

	local damagecap = ability:GetLevelSpecialValueFor("damage_cap", ability:GetLevel() - 1 )
	damagedone = target.DamageCollection * bonusdamage / 100
	if damagedone > damagecap then
		damagedone = damagecap
	end
end

function UnholyEcstasyDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local damage = ability:GetAbilityDamage()

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = damage
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL

	ApplyDamage(damage_table)
end

function BonusMana(keys)
	local target = keys.target
	target:GiveMana(damagedone)

	amount = math.floor(damagedone)

	target:PopupNumbers(target, "mana_add", Vector(0, 204, 255), 2.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

function BonusDamage(keys)
	local caster = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local bonusdamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )

	if not target:IsMagicImmune() then 
		local damage_table = {}
			damage_table.ability = ability
			damage_table.victim = target
			damage_table.attacker = caster
			damage_table.damage = damagedone
			damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		

			amount = damagedone
		    amount = amount - (amount * target:GetMagicalArmorValue())

		    local lens_count = 0
		    for i=0,5 do
		        local item = caster:GetItemInSlot(i)
		        if item ~= nil and item:GetName() == "item_aether_lens" then
		            lens_count = lens_count + 1
		        end
		    end
    		amount = amount * (1 + (.08 * lens_count))
  		    amount = math.floor(amount)

  		    target:PopupNumbers(target, "crit", Vector(153, 0, 0), 2.0, amount, nil, POPUP_SYMBOL_POST_DROP)

		ApplyDamage(damage_table)

		caster:RemoveModifierByName("Unholy_Ecstasy_Bonus_Damage")
	end
end

function ResetDamage(keys)
	keys.target.DamageCollection = 0
	damagedone = 0
end