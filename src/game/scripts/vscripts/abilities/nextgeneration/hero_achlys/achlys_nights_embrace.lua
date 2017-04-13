LinkLuaModifier( "modifier_hidden_invis", "abilities/nextgeneration/hero_achlys/modifiers/modifier_hidden_invis.lua", LUA_MODIFIER_MOTION_NONE )

function AddInvis(keys)
	keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_hidden_invis", {duration = 15} )
end

function AddDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local heroes = HeroList:GetAllHeroes()
	local burn = ability:GetSpecialValueFor("mana_cost_pct") / 500

	local isHidden = true

	for k,v in pairs(heroes) do 
		if v:GetTeam() ~= caster:GetTeam() then
			if v:CanEntityBeSeenByMyTeam(caster) then
				isHidden = false
			end
		end
	end
	
	local cost = caster:GetMaxMana() * burn
	if caster:GetMana() > cost then
		if isHidden then
			if caster:HasModifier("modifier_achlys_nights_embrace_damage") then
				local stacks = caster:GetModifierStackCount("modifier_achlys_nights_embrace_damage", caster)
				ability.DamageStacks = stacks + 1
				caster:SetModifierStackCount("modifier_achlys_nights_embrace_damage", caster, ability.DamageStacks)
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_achlys_nights_embrace_damage", {})
				caster:SetModifierStackCount("modifier_achlys_nights_embrace_damage", caster, 1)
			end
		end
		caster:SpendMana(cost, ability)
	else
		caster:RemoveModifierByName("modifier_achlys_nights_embrace_damage")
	end
end

function ScepterCheck ( keys )
	local caster = keys.caster

	if not caster:HasScepter() then
		caster:RemoveModifierByName("modifier_achlys_nights_embrace")
		caster:RemoveModifierByName("modifier_achlys_nights_embrace_damage")
	end
end