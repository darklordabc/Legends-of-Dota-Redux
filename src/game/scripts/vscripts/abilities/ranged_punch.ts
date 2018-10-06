class ranged_punch extends CDOTA_Ability_Lua {
	end_position:Vec
	particle:ParticleID
	range:number
	projectile:ProjectileID
	projectile_speed:number
	returning:boolean
	direction:Vec
	targets:CDOTA_BaseNPC[]

	OnSpellStart() {
  		let caster = this.GetCaster();
  		let origin = caster.GetAbsOrigin();
  		let point = this.GetCursorPosition();
  		let direction = (point-origin).Normalized();
  		direction[3] = 0;
  		this.direction = direction;
  		this.targets = [];
  		this.range = 1000//this.GetCastRange(null,null);
  		this.returning = false;

  		let projectileTable:LinearProjectileTable = {
  			Ability:this,
  			EffectName: "",
  			vSpawnOrigin:origin,
  			fDistance: this.range,
  			fStartRadius:100,//this.GetSpecialValueFor("radius"),
  			fEndRadius:100,//this.GetSpecialValueFor("radius"),
  			Source:caster,
  			vVelocity:direction * this.GetSpecialValueFor("projectile_speed"),
  			iUnitTargetTeam:DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH,
  			iUnitTargetType:DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,
  		}
  		

  		this.projectile = ProjectileManager.CreateLinearProjectile(projectileTable);

  		this.end_position = caster.GetAbsOrigin() + direction * this.range
	    this.particle = ParticleManager.CreateParticle( "particles/abilities/punch/ranged_punch.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null)
	    ParticleManager.SetParticleAlwaysSimulate( this.particle)
	    ParticleManager.SetParticleControlEnt( this.particle, 0, caster, ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", origin, true )
	    ParticleManager.SetParticleControl( this.particle, 1, this.end_position  )
	    ParticleManager.SetParticleControl( this.particle, 2, Vector( this.GetSpecialValueFor("projectile_speed") , 0, 0 ) )
	    ParticleManager.SetParticleControl( this.particle, 3, Vector(5,0,0) ) // Time to kill this
	    ParticleManager.SetParticleControl( this.particle, 4, Vector( 1, 0, 0 ) )
	    ParticleManager.SetParticleControl( this.particle, 5, Vector( 0, 0, 0 ) )
	    ParticleManager.SetParticleControlEnt( this.particle, 7, caster, ParticleAttachment_t.PATTACH_CUSTOMORIGIN, null, origin, true )
	}

	

	OnProjectileHit(target,location) {
		let caster = this.GetCaster();
		if (!target && !this.returning) {
	  		let origin = caster.GetAbsOrigin();
	  		let point = this.GetCursorPosition();
	  		let direction = (origin-location).Normalized();
	  		direction[3] = 0;
	  		this.direction = direction;
			this.returning = true;

			let projectileTable:LinearProjectileTable = {
	  			Ability:this,
	  			EffectName: "",
	  			vSpawnOrigin:location,
	  			fDistance: (origin-location).Length2D(),
	  			fStartRadius:100,//this.GetSpecialValueFor("radius"),
	  			fEndRadius:100,//this.GetSpecialValueFor("radius"),
	  			Source:caster,
	  			vVelocity:direction * this.GetSpecialValueFor("projectile_speed"),
	  			iUnitTargetTeam:DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH,
  				iUnitTargetType:DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,
	  		}

  		this.projectile = ProjectileManager.CreateLinearProjectile(projectileTable);
  		ParticleManager.SetParticleControlEnt( this.particle, 1, this.GetCaster(), ParticleAttachment_t.PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", this.GetCaster().GetAbsOrigin(), true);
		} else if (!target) {
			ParticleManager.DestroyParticle(this.particle,true);
			ParticleManager.ReleaseParticleIndex(this.particle);
		} else {
			if (this.targets.indexOf(target) == -1) {
				let normal = (target.GetAbsOrigin()-location).Normalized();
				let dot = normal.Dot(this.direction);
				this.targets.push(target)
				if (dot > 0) {
					let knockbackDistance = this.GetSpecialValueFor("knockback_distance")

					if (target.GetTeamNumber() != caster.GetTeamNumber()) {
						let damageTable:DamageTable = {
							ability:this,
							victim:target,
							attacker:caster,
							damage:this.GetSpecialValueFor("punch_damage"),
							damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
						}
						ApplyDamage(damageTable);

						let talent = caster.FindAbilityByName("special_bonus_unique_ranged_punch_0")
						if (talent && talent.GetLevel() > 0) {
							knockbackDistance = knockbackDistance * talent.GetSpecialValueFor("value")
						} 

					}
					
					let knockbackTable = {
						should_stun:false,
				        knockback_duration : 0.5,
				        duration : 0.5,
				        knockback_distance : 400,
				        knockback_height : 0,
				        //@ts-ignore
				        center_x : location.x,
				        //@ts-ignore
				        center_y : location.y,
				        center_z : GetGroundHeight(location,null),
					}
					target.AddNewModifier(caster,this,"modifier_knockback",knockbackTable);
					

				}
			}
		}
		return false
	}
}