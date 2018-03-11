if blink_support == nil then
	blink_support = class({})
end

LinkLuaModifier( "blink_support_effect_modifier", "abilities/overflow/blink_support/effect_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function blink_support:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	return behav
end

function blink_support:GetManaCost()
	return self.BaseClass.GetManaCost( self, 1 )
end

function blink_support:GetCooldown( nLevel )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "cooldown_scepter" )
	else
		return self.BaseClass.GetCooldown( self, nLevel )
	end
end


function blink_support:OnSpellStart()
	local hCaster = self:GetCaster() --We will always have Caster.
	local hTarget = false --We might not have target so we make fail-safe so we do not get an error when calling - self:GetCursorTarget()
	if not self:GetCursorTargetingNothing() then
		hTarget = self:GetCursorTarget()
	end
	local vPoint = self:GetCursorPosition() --We will always have Vector for the point.
	local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
	local nMaxBlink = self:GetSpecialValueFor( "max_blink" ) --How far can we actually blink?
	local nClamp = self:GetSpecialValueFor( "blink_clamp" ) --If we try to over reach we use this value instead. (this is mechanic from blink dagger.)
	if hTarget and hCaster:GetTeamNumber() == hTarget:GetTeamNumber() and not hTarget:IsBuilding() then
		if hCaster == hTarget then
			if not self.hFountain and not self.bNoFountain then --We check if we have ever tried finding the fountain before.
			local hFountain = Entities:FindByClassname(nil, "ent_dota_fountain") --Find first fountain
			local bFound = false --Make the boolean for while statement.
				while not bFound do
					if hFountain then --Is there a fountain entity?
						if hFountain:GetTeamNumber() == hCaster:GetTeamNumber() then -- Is it the right team?
							self.hFountain = hFountain --Store it so we don't have to trouble finding the foundtain again.
							bFound = true --Make sure while statement ends
						else
							hFountain = Entities:FindByClassname(hFountain, "ent_dota_fountain") --Find the next fountain if we didn't find the right team.
						end
					else
						self.bNoFountain = true --We have concluded that there is no fountain entity for this team. Lets not do that again!
						bFound = true --We could alternatively use 'Break' but I find this more funny.
					end
				end
			end
			if self.hFountain then --Do we have fountain?
				vPoint = self.hFountain:GetAbsOrigin() --Lets change our target location there then.
				self:Blink(hCaster, vPoint, nMaxBlink, nClamp) --BLINK!
			else
				self:EndCooldown() --Cooldown refund if we could not find fountain on self cast
				self:RefundManaCost() --Manacost refund if we could not find fountain on self cast
			end
		else
		
			local hModifier = hCaster:FindModifierByNameAndCaster("blink_support_effect_modifier", hCaster) --Check if we have someone selected
			if hModifier then
				hOld = EntIndexToHScript(hModifier:GetStackCount()) --Find the target with the ent index
				if hOld:FindModifierByNameAndCaster("blink_support_effect_modifier", hCaster) then --Check if the target is not purged.
					hCaster:RemoveModifierByNameAndCaster("blink_support_effect_modifier", hCaster)
					hOld:RemoveModifierByNameAndCaster("blink_support_effect_modifier", hCaster)
				end
			end
			hTarget:AddNewModifier( hCaster, self, "blink_support_effect_modifier", { duration = self:GetSpecialValueFor( "help_duration" ) } ) --lets add modifier to target
			hCaster:AddNewModifier( hCaster, self, "blink_support_effect_modifier", { duration = self:GetSpecialValueFor( "help_duration" ) } ) --lets add modifier to caster
			local hModifier = hCaster:FindModifierByNameAndCaster("blink_support_effect_modifier", hCaster) --find that modifier (they really should fix this by returning handle when adding new modifier.
			local nTargetIndex = hTarget:GetEntityIndex() --lets find the targets entity index
			hModifier:SetStackCount(nTargetIndex) --add that index to the modifier as it's stack count
			self:EndCooldown() --Cooldown refund so can cast again
			self:RefundManaCost() --Manacost refund
		end
	else
	
		local hModifier = hCaster:FindModifierByNameAndCaster("blink_support_effect_modifier", hCaster) --Check if we have someone selected
		if hModifier then
			hTarget = EntIndexToHScript(hModifier:GetStackCount()) --Find the target with the ent index
			if hTarget:FindModifierByNameAndCaster("blink_support_effect_modifier", hCaster) then --Check if the target is not purged.
				self:Blink(hTarget, vPoint, nMaxBlink, nClamp) --BLINK!
				if self:GetLevel() < self:GetSpecialValueFor( "max_level" ) and GameRules:IsDaytime() then --We can't define max level for item like we can with abilities. Best to create special value for it.
					self:UpgradeAbility(true)
				end
			else --Someone purged our target
			self:Blink(hCaster, vPoint, nMaxBlink, nClamp) --BLINK!
			end
		else
			self:Blink(hCaster, vPoint, nMaxBlink, nClamp) --BLINK!
		end
	end
end


function blink_support:Blink(hTarget, vPoint, nMaxBlink, nClamp)
	local vOrigin = hTarget:GetAbsOrigin() --Our units's location
	ProjectileManager:ProjectileDodge(hTarget)  --We disjoint disjointable incoming projectiles.
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, hTarget) --Create particle effect at our caster.
	hTarget:EmitSound("DOTA_Item.BlinkDagger.Activate") --Emit sound for the blink
	local vDiff = vPoint - vOrigin --Difference between the points
	if vDiff:Length2D() > nMaxBlink then  --Check caster is over reaching.
		vPoint = vOrigin + (vPoint - vOrigin):Normalized() * nClamp -- Recalculation of the target point.
	end
	hTarget:SetAbsOrigin(vPoint) --We move the caster instantly to the location
	FindClearSpaceForUnit(hTarget, vPoint, false) --This makes sure our caster does not get stuck
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, hTarget) --Create particle effect at our caster.
end

function blink_support:CastFilterResultTarget( hTarget ) -- hTarget is the targeted NPC.
	return self:CCastFilter( hTarget, false )
end

function blink_support:GetCustomCastErrorTarget( hTarget) -- hTarget is the targeted NPC. 
	return self:CCastFilter( hTarget, true )
end

function blink_support:CCastFilter( hTarget, bError )
	if IsServer() then --this should be only run on server.
		local hCaster = self:GetCaster() --We will always have Caster.
		local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
		local vPoint = hTarget:GetAbsOrigin() --Our target's location
		local nRangeBonus = hCaster:GetMaxMana() --Get our caster's mana pool
		local nMaxRange = self:GetSpecialValueFor( "help_range" ) + nRangeBonus--How far can we actually target?
		local vDiff = vPoint - vOrigin --Difference between the points
		local nTargetID = hTarget:GetPlayerOwnerID() --getting targets owner id
		local nCasterID = hCaster:GetPlayerOwnerID() --getting casters owner id
		--if hCaster:GetTeamNumber() ~= hTarget:GetTeamNumber() then
		--	if bError then
		--		return "#dota_hud_error_cant_cast_on_enemy"
		--	else
		--		return UF_FAIL_CUSTOM
		--	end
		--end
		if nTargetID and nCasterID then --making sure they both exist
			if PlayerResource:IsDisableHelpSetForPlayerID(nTargetID, nCasterID) then --target hates having caster help him out.
				if bError then
					return "#dota_hud_error_target_has_disable_help"
				else
					return UF_FAIL_CUSTOM
				end
			end
		end
		if vDiff:Length2D() > nMaxRange then  --Check caster is over reaching.
			if bError then
				return "#dota_hud_error_target_out_of_range" --returning error from localization
			else
				return UF_FAIL_CUSTOM
			end
		end
		if not bError then
			return UF_SUCCESS
		end
	end
end


function blink_support:OnUpgrade()
	self.IsProcBanned = true
end