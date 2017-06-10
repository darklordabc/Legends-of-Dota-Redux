--[[Author: TheGreatGimmick
    Date: April 7, 2017
    Modifier tracks ability usage, displays next adaptation, and returns the next adaptation when requested.]]

LinkLuaModifier("modifier_adaptation_next_display", "heroes/hero_genos/modifiers/modifier_adaptation_next_display.lua", LUA_MODIFIER_MOTION_NONE)

modifier_adaptation_counter = class({})

function modifier_adaptation_counter:DeclareFunctions()
    local funcs = {
    MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
    return funcs
end

function modifier_adaptation_counter:OnCreated()
    if IsServer() then
        print('')
        print('Counter modifier created.')
    	self.bioweapon_cast_counter = 0
    	self.flight_instinct_cast_counter = 0
    	self.aquired_immunity_cast_counter = 0
    	self.next_adaptation_counter = 0
    	self.next_adaptation = -1
        local caster = self:GetParent()
        local ability = caster:FindAbilityByName("genos_adaptation")
        caster:AddNewModifier(caster, ability, "modifier_adaptation_next_display", {})
    end
end

function modifier_adaptation_counter:IsHidden() 
	return true
end

function modifier_adaptation_counter:IsPermanent() 
	return true
end

function modifier_adaptation_counter:OnAbilityExecuted(kv)
    if IsServer() then
        local caster = self:GetParent()
        if kv.unit == caster then
            print('')
            print('Genos spell used, locating:')
            --variables 
            local a = kv.ability
            local q = caster:FindAbilityByName("genos_bioweapon")
            local w = caster:FindAbilityByName("genos_flight_instinct")
            local e = caster:FindAbilityByName("genos_aquired_immunity")

            if a == q then
                print('Bioweapon used')
            	self.bioweapon_cast_counter = self.bioweapon_cast_counter + 1

            	if self.bioweapon_cast_counter > self.next_adaptation_counter then
            		caster:RemoveModifierByName("modifier_adaptation_next_display")
            		caster:AddNewModifier(caster, a, "modifier_adaptation_next_display", {})
            		self.next_adaptation_counter = self.bioweapon_cast_counter
            		self.next_adaptation = a
            	else
                	if self.bioweapon_cast_counter == self.next_adaptation_counter then
                		caster:RemoveModifierByName("modifier_adaptation_next_display")
                		local ability = caster:FindAbilityByName("genos_adaptation")
        				caster:AddNewModifier(caster, ability, "modifier_adaptation_next_display", {})
        				self.next_adaptation = -1
        			end
                end
    		end

            if a == w then
                print('Flight Instinct used')
            	self.flight_instinct_cast_counter = self.flight_instinct_cast_counter + 1

            	if self.flight_instinct_cast_counter > self.next_adaptation_counter then
            		caster:RemoveModifierByName("modifier_adaptation_next_display")
            		caster:AddNewModifier(caster, a, "modifier_adaptation_next_display", {})
            		self.next_adaptation_counter = self.flight_instinct_cast_counter
            		self.next_adaptation = a
            	else
                	if self.flight_instinct_cast_counter == self.next_adaptation_counter then
                		caster:RemoveModifierByName("modifier_adaptation_next_display")
                		local ability = caster:FindAbilityByName("genos_adaptation")
        				caster:AddNewModifier(caster, ability, "modifier_adaptation_next_display", {})
        				self.next_adaptation = -1
        			end
                end
    		end

            if a == e then
                print('Aquired Immunity used')
            	self.aquired_immunity_cast_counter = self.aquired_immunity_cast_counter + 1

            	if self.aquired_immunity_cast_counter > self.next_adaptation_counter then
            		caster:RemoveModifierByName("modifier_adaptation_next_display")
            		caster:AddNewModifier(caster, a, "modifier_adaptation_next_display", {})
            		self.next_adaptation_counter = self.aquired_immunity_cast_counter
            		self.next_adaptation = a
            	else
                	if self.aquired_immunity_cast_counter == self.next_adaptation_counter then
                		caster:RemoveModifierByName("modifier_adaptation_next_display")
                		local ability = caster:FindAbilityByName("genos_adaptation")
        				caster:AddNewModifier(caster, ability, "modifier_adaptation_next_display", {})
        				self.next_adaptation = -1
        			end
                end
    		end

            print('Bioweapon: '..self.bioweapon_cast_counter)
            print('Flight Instinct: '..self.flight_instinct_cast_counter)
            print('Aquired Immunity: '..self.aquired_immunity_cast_counter)
            print('Current Max: '..self.next_adaptation_counter)
    	end
    end
end

function modifier_adaptation_counter:RequestAdaptation()
    if IsServer() then
    	return self.next_adaptation
    end
end
