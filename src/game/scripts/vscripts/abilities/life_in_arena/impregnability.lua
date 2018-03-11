

function ApplyModifiers(keys)

	local caster = keys.caster
	local ability = keys.ability
	--
	--"modifier_impregnability1"
	--"modifier_impregnability2"
	--
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_impregnability1", nil)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_impregnability2", nil)
	
end

function DestroyModifiers(keys)
	local caster = keys.caster
	local ability = keys.ability
	--for k,unit in pairs(ability.tAlliesPal) do
	for i = 1, #ability.tAlliesPal do
		if not ability.tAlliesPal[i]:IsNull() then
			ability.tAlliesPal[i]:RemoveModifierByName("modifier_impregnability_aura_inv")
		end
		--table.remove(ability.tAlliesPal,i)
	end
	ability.tAlliesPal = {}
	
end

function ApplyModifiersV2(keys)

	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local damage = keys.damage
	local tbuf = {}
	--
	if not ability.tAlliesPal then
		ability.tAlliesPal = {}
	end
	--
	local table_target = FindUnitsInRadius(caster:GetTeam(),
                                 caster:GetAbsOrigin(),
                                 nil,
                                 radius,
                                 DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                 DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                                 FIND_ANY_ORDER,
                                 false)
	--
	local flag = false
	--
	--print("---------")
	--for i = 1, #table_target do
	--	print(table_target[i]:GetUnitName())
	--end
	--print("---------")
	--
	--print("----------Delete---------- ")
	--for k,unit in pairs(ability.tAlliesPal) do
	for i = 1, #ability.tAlliesPal do
		--print(unit:GetUnitName())
		--for _,unit2 in pairs(table_target) do
		for j = 1, #table_target do
			--print(table_target[j]:GetUnitName())
			if ability.tAlliesPal[i] == table_target[j] then
				flag = true
				break
			end
		end
		--
		--print(flag)
		if flag == false then
			--print(ability.tAlliesPal[i]:GetUnitName())
			--table.remove(ability.tAlliesPal,k)
			table.insert(tbuf,i)
			ability.tAlliesPal[i]:RemoveModifierByName("modifier_impregnability_aura_inv")
		else
			flag = false
		end
	end
	
	--
	--print("----------Delete ")
	for i = 1, #tbuf do
	--for i,index in pairs(tbuf) do
		table.remove(ability.tAlliesPal,tbuf[i])
	end
	--
	--
	--print("--------insert------------")
	--
	for i = 1, #table_target do
   		if table_target[i] ~= caster then
			if not table_target[i]:HasModifier("modifier_impregnability_aura_inv") then
				--print(table_target[i]:GetUnitName())
				table.insert(ability.tAlliesPal,table_target[i])
				ability:ApplyDataDrivenModifier(caster, table_target[i], "modifier_impregnability_aura_inv", nil)
			end                
   		end

	end
	--print("--------------------")
	--
	--
	local table_target_enemy = FindUnitsInRadius(caster:GetTeam(),
                                 caster:GetAbsOrigin(),
                                 nil,
                                 radius,
                                 DOTA_UNIT_TARGET_TEAM_ENEMY,
                                 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                 DOTA_UNIT_TARGET_FLAG_NONE,
                                 FIND_ANY_ORDER,
                                 false)
	
	
	--modifier_impregnability_aura_dmg
	--for _,unit in pairs(table_target_enemy) do
	local fxIndex
	local particleName = "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf"
	print("---------")
	for i = 1, #table_target_enemy do
		print(table_target_enemy[i]:GetUnitName())
		--ability:ApplyDataDrivenModifier(caster, table_target_enemy[i], "modifier_impregnability_aura_dmg", nil) --{duration = 0.03} 
		--
		local damageTable =
		{
			victim = table_target_enemy[i],
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability
		}
		ApplyDamage( damageTable )
		-- Fire effect
		fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, table_target_enemy[i])
		ParticleManager:SetParticleControl( fxIndex, 0, table_target_enemy[i]:GetAbsOrigin() )
	end
	print("---------")
	
	--ability:ApplyDataDrivenModifier(caster, caster, "modifier_impregnability1", nil)
	--ability:ApplyDataDrivenModifier(caster, caster, "modifier_impregnability2", nil)
	
end