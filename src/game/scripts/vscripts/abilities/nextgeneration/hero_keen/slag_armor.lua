function CheckOrb( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_slag_armor_orb", {Duration = 0.9})
	end
end

function StartCooldown(keys)
	local caster = keys.caster
	local ability = keys.ability

	local manacost = ability:GetManaCost(ability:GetLevel() -1)
	local cooldown = ability:GetLevelSpecialValueFor("cooldown",ability:GetLevel() -1)
	
	ability:StartCooldown(cooldown)
	caster:SpendMana(manacost, ability)
end

function AttackWasHit (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel() -1)
	local radius = ability:GetLevelSpecialValueFor("siege_radius",ability:GetLevel() -1)	
	local modifier = "modifier_slag_armor_debuff"

	if caster:HasModifier("modifier_siege_mode") then
		local units = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), caster, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, 0, 0, false )
		ability:ApplyDataDrivenModifier(caster,target,"modifier_slag_armor_damage_debuff",{duration = duration})
		for _,unit in pairs( units ) do
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_slag_armor_damage_debuff",{duration = duration})
			if unit:HasModifier(modifier) then
				unit:SetModifierStackCount(modifier,caster,unit:GetModifierStackCount(modifier,caster) +1)
				unit:FindModifierByName(modifier):SetDuration(duration,true)
			else
				ability:ApplyDataDrivenModifier(caster,unit,modifier,{duration = duration})
				unit:SetModifierStackCount(modifier,caster,1)
			end
			target:EmitSound("Hero_Batrider.StickyNapalm.Impact")
		end
	else
		if target:HasModifier(modifier) then
			target:SetModifierStackCount(modifier,caster,target:GetModifierStackCount(modifier,caster) +1)
			target:FindModifierByName(modifier):SetDuration(duration,true)
		else
			ability:ApplyDataDrivenModifier(caster,target,modifier,{duration = duration})
			target:SetModifierStackCount(modifier,caster,1)
		end
		ability:ApplyDataDrivenModifier(caster,target,"modifier_slag_armor_damage_debuff",{duration = duration})
		target:EmitSound("Hero_Batrider.StickyNapalm.Impact")
	end
	--ability:ToggleAbility()
end

function SlagArmorDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local firedamage = ability:GetLevelSpecialValueFor("damage_per_second",ability:GetLevel() -1)
	
	if caster:HasScepter() then
		local armor = target:GetPhysicalArmorValue() * 5
		if armor > 0 then
			firedamage = firedamage + armor
		end
	end
	local DamageTable = 
	{
		attacker = caster,
		damage_type = ability:GetAbilityDamageType(),
		damage = firedamage,
		victim = target
	}
	ApplyDamage(DamageTable)

--[[	amount = firedamage
    amount = amount - (amount * target:GetMagicalArmorValue())
    local lens_count = 0
    for i=0,5 do
        local item = caster:GetItemInSlot(i)
        if item ~= nil and item:GetName() == "item_aether_lens" then
            lens_count = lens_count + 1
        end
    end
    amount = amount * (1 + (.05 * lens_count) + ( .01 * caster:GetIntellect() / 16 ))
    amount = math.floor(amount)

    PopupNumbers(target, "damage", Vector(255, 133, 51), 2.0, amount, nil, POPUP_SYMBOL_POST_EYE)]]
end