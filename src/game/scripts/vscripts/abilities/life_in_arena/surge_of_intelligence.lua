function Damage( event )
	local caster = event.caster
	local targets = event.target_entities
	local ability = event.ability
	local koef_damage = ability:GetSpecialValueFor('koef_damage') 
	-- рассчитаем урон который необходимо нанести
	local intBase = caster:GetBaseIntellect()
	local intOther = caster:GetIntellect()-intBase
	local dmg = (intBase+intOther/2)*koef_damage
	local minimumCooldown = 8
	
	if caster:GetMana() <= dmg then dmg = caster:GetMana() end
	
	for _,v in pairs(targets) do
		ApplyDamage({ victim = v, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
		local particle = ParticleManager:CreateParticle("particles/leshrac_diabolic_edict_custom.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 1, v:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)
	end
	
	caster:ShowPopup( {
		PostSymbol = 4,
		Color = Vector( 125, 125, 255 ),
		Duration = 0.7,
		Number = dmg,
		pfx = "spell_custom"} )
							
	caster:SpendMana(dmg, ability)

	local particle1 = ParticleManager:CreateParticle("particles/lion_spell_voodoo.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle1, 1, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle1)
	
	if dmg/15 < minimumCooldown then
		ability:StartCooldown(minimumCooldown)
	else
		ability:StartCooldown(dmg/15)
	end
	
end

function CDOTA_BaseNPC:ShowPopup( data )
    if not data then return end

    local target = self
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or false
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player then
		local playerent = PlayerResource:GetPlayer( self:GetPlayerID() )
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, playerent)
    end
	
	if number then
		number = math.floor(number+0.5)
	end

    local digits = 0
    if number ~= nil then digits = string.len(number) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end
