LinkLuaModifier("modifier_crater_spell_manager","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_projectile","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_area_controller","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_area_control","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class crater extends CDOTA_Ability_Lua {
	dummy:CDOTA_BaseNPC
	mod:CDOTA_Buff
	projectile:ProjectileID
	partic:ParticleID
	projectileParticle:ParticleID
	time:number
	launchLocation:Vec
	launchDirection:Vec

	GetAbilityTexture() {
		let caster = this.GetCaster();
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return "invoker_sun_strike"
		} else {
			return "techies_focused_detonate"
		}
	}

	GetManaCost(i) {
		let caster = this.GetCaster();
		let cost = [70,80,90,100]
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return cost[i];
		} else {
			return 0;
		}
	}

	GetCooldown(i) {
		let caster = this.GetCaster();
		if (IsClient()) { return 30;}
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return 0.5;
		} else {
			return 30
		}
	}
	GetCastPoint() {
		let caster = this.GetCaster();
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return 0.3;
		} else {
			return 0;
		}
	}
	GetIntrinsicModifierName() {return "modifier_crater_spell_manager"}
	
	OnSpellStart() {
		let caster = this.GetCaster();
		let origin = caster.GetAbsOrigin();

		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			let direction = (caster.GetCursorPosition()-origin).Normalized();
			//@ts-ignore
			direction.z = 0
			let projectileTable:LinearProjectileTable = {
				Ability:this,
				EffectName:"",
				//EffectName:"particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
				vSpawnOrigin:origin,
				fDistance:10000,
				fStartRadius:this.GetSpecialValueFor("crater_radius"),
				fEndRadius:this.GetSpecialValueFor("crater_radius"),
				Source:caster,
				// Projectile moves faster than particle...
				vVelocity:direction * (this.GetSpecialValueFor("marker_speed")) ,
			}

			this.projectileParticle = ParticleManager.CreateParticleForTeam("particles/crater_marker.vpcf",ParticleAttachment_t.PATTACH_CUSTOMORIGIN,caster,caster.GetTeamNumber())
			ParticleManager.SetParticleControl(this.projectileParticle,0,caster.GetAbsOrigin()+direction)
			ParticleManager.SetParticleControl(this.projectileParticle,1,direction*this.GetSpecialValueFor("marker_speed"));

			//this.projectile = ProjectileManager.CreateLinearProjectile(projectileTable);

			caster.EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast")

			//this.dummy = CreateModifierThinker(caster,this,"modifier_crater_projectile",{},origin,caster.GetTeamNumber(),false);
			/*this.dummy = CreateUnitByName(caster.GetUnitName(),origin,true,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
			this.mod = this.dummy.AddNewModifier(this.dummy,this,"modifier_crater_projectile",{})
			//@ts-ignore
			this.mod.direction = direction
			*/
			caster.SetModifierStackCount(this.GetIntrinsicModifierName(),caster,1);
			this.time = GameRules.GetGameTime()
			this.launchDirection = direction
			this.launchLocation = origin
			this.EndCooldown();
			this.StartCooldown(0.25);
		} else {
			//let origin = ProjectileManager.GetLinearProjectileLocation(this.projectile);
			let time = GameRules.GetGameTime() - this.time
			let origin = this.launchLocation + (this.launchDirection * (this.GetSpecialValueFor("marker_speed") * time))
			this.dummy = CreateUnitByName("npc_dota_thinker",origin,true,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
			this.OnDestroyProjectile(origin,this.dummy);
			//ProjectileManager.DestroyLinearProjectile(this.projectile);
			caster.SetModifierStackCount(this.GetIntrinsicModifierName(),caster,0);
			//this.mod.Destroy()
			//@ts-ignore
			Timers.CreateTimer(.5,()=>{
				if (this.dummy && IsValidEntity(this.dummy)) {
					AddFOWViewer(caster.GetTeamNumber(),origin,this.GetSpecialValueFor("crater_radius"),.5,true)
					return .5;
				}
			})
		}
	}


	OnDestroyProjectile(origin:Vec,target:CBaseEntity) {
		let caster = this.GetCaster();
		this.CreateVisibilityNode(origin,this.GetSpecialValueFor("crater_radius"),this.GetSpecialValueFor("crater_duration"));
		
		let pTable:TrackingProjectileTable = {
			Target:this.dummy,
			Source:caster,
			Ability:this,
			EffectName:"particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf",
			iMoveSpeed:this.GetSpecialValueFor("projectile_speed"),
		}

		caster.EmitSound("Ability.Ghostship.bell");

		ParticleManager.DestroyParticle(this.projectileParticle,true);
		ParticleManager.ReleaseParticleIndex(this.projectileParticle);

		this.projectileParticle = ParticleManager.CreateParticleForTeam("particles/crater_marker.vpcf",ParticleAttachment_t.PATTACH_CUSTOMORIGIN,caster,caster.GetTeamNumber())
		ParticleManager.SetParticleControl(this.projectileParticle,0,origin)
		ParticleManager.SetParticleControl(this.projectileParticle,1,Vector(0,0,0));

		this.partic = ParticleManager.CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf",ParticleAttachment_t.PATTACH_CUSTOMORIGIN,caster);
		ParticleManager.SetParticleControl(this.partic,0,caster.GetAbsOrigin());
  		ParticleManager.SetParticleControlEnt(this.partic,1,this.dummy,ParticleAttachment_t.PATTACH_POINT_FOLLOW,"attach_hitloc",this.dummy.GetAbsOrigin(),true)
  		ParticleManager.SetParticleControl(this.partic,2,Vector(this.GetSpecialValueFor("projectile_speed"),0))

		ProjectileManager.CreateTrackingProjectile(pTable)

		return false;
	}

	OnProjectileHit(target,location) {
		if (!target) {
			let caster = this.GetCaster();
			caster.SetModifierStackCount(this.GetIntrinsicModifierName(),caster,1);
			return false;
		} else {
			this.CreateCrater(location)
			this.dummy.EmitSound("Hero_Invoker.SunStrike.Ignite")
			UTIL_Remove(this.dummy);
			this.dummy = null;
			ParticleManager.DestroyParticle(this.partic,true);
			ParticleManager.ReleaseParticleIndex(this.partic);

			ParticleManager.DestroyParticle(this.projectileParticle,true);
			ParticleManager.ReleaseParticleIndex(this.projectileParticle);


		}
	}

	CreateCrater(origin:Vec) {
		let caster = this.GetCaster();
		this.CreateVisibilityNode(origin,this.GetSpecialValueFor("crater_radius"),this.GetSpecialValueFor("crater_duration"));
		let dummy = CreateModifierThinker(this.GetCaster(),this,"modifier_crater_area_controller",{duration:this.GetSpecialValueFor("crater_duration")},origin+Vector(0,0,50),caster.GetTeamNumber(),false);
		

		GridNav.DestroyTreesAroundPoint(origin,this.GetSpecialValueFor("crater_radius"),false);
		let damageTable:DamageTable = {
			ability:this,
			victim:caster,
			attacker:caster,
			damage:this.GetSpecialValueFor("crater_damage"),
			damage_type:DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL,
		}

		let units = FindUnitsInRadius(caster.GetTeamNumber(),origin,null,this.GetSpecialValueFor("crater_radius"),DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
		units.forEach((unit)=> {
			damageTable.victim = unit;
			ApplyDamage(damageTable);

			unit.AddNewModifier(caster,this,"modifier_stun",{duration:FrameTime()})
		})

		let talent = caster.FindAbilityByName("special_bonus_unique_crater_0")
		if (talent && talent.GetLevel() == 1) {
			let units = FindUnitsInRadius(caster.GetTeamNumber(),origin,null,talent.GetSpecialValueFor("value"),DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
			units.forEach((unit)=> {
				let dist = (unit.GetAbsOrigin()-origin).Length2D()
				if (dist > this.GetSpecialValueFor("crater_radius") -50) {
					let knockbackTable = {
						should_stun:false,
				        knockback_duration : 0.33,
				        duration : 0.33,
				        knockback_distance : -dist,
				        knockback_height : 0,
				        //@ts-ignore
				        center_x : origin.x,
				        //@ts-ignore
				        center_y : origin.y,
				        center_z : GetGroundHeight(origin,null),
					}
					unit.AddNewModifier(caster,this,"modifier_knockback",knockbackTable)
				}
			})
		}
	}
}

class modifier_crater_projectile extends CDOTA_Modifier_Lua {
	direction:Vec
	speed:number
	radius:number
	particle:ParticleID

	OnCreated() {
		if (IsClient()) {return}
		let projectile = this.GetParent();
		let ability = this.GetAbility();
		//@ts-ignore
		//this.direction = projectile.direction;
		this.speed = ability.GetSpecialValueFor("projectile_speed") * FrameTime();
		this.radius = ability.GetSpecialValueFor("crater_radius");
		this.StartIntervalThink(FrameTime());

		this.particle = ParticleManager.CreateParticle("particles/crater_marker.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN,this.GetCaster());
		//ParticleManager.SetParticleControlEnt(this.particle,0,projectile,ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,)
		ParticleManager.SetParticleControl(this.particle,4,Vector(this.radius,0,0));
	}

	OnIntervalThink() {
		let projectile = this.GetParent();
		projectile.SetAbsOrigin(projectile.GetAbsOrigin() + (this.direction * this.speed));
	}

	OnDestroy() {
		if (IsClient()) {return}
		let projectile = this.GetParent();
		let ability = this.GetAbility();
		let origin = projectile.GetAbsOrigin();
		ability.CreateVisibilityNode(origin,this.radius,ability.GetSpecialValueFor("vision_duration"));
		let dummy = CreateModifierThinker(this.GetCaster(),ability,"modifier_crater_area_controller",{duration:ability.GetSpecialValueFor("crater_duration")},origin+Vector(0,0,50),this.GetCaster().GetTeamNumber(),false);
		this.GetParent().Destroy()
	}

	GetEffectName() {
		return "particles/crater_marker.vpcf";
	}

	GetEffectAttachType() {
		return ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW
	}
}

class modifier_crater_area_controller extends CDOTA_Modifier_Lua {
	particle:ParticleID
	particle2:ParticleID

	// IsAura() {return true}
	// GetAuraRadius() {return this.GetAbility().GetSpecialValueFor("crater_radius")}
	// GetAuraSearchTeam() {return DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY}
	// GetModifierAura() {return "modifier_crater_area_control"}
	// GetAuraDuration() {return 0.1}

	OnCreated() {
		if (IsServer()) {
			this.particle2 = ParticleManager.CreateParticle("particles/crater_strike.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, this.GetParent())

			this.particle = ParticleManager.CreateParticle("particles/crater_area.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN,this.GetCaster());
			ParticleManager.SetParticleControl(this.particle,0,this.GetParent().GetAbsOrigin());
			ParticleManager.SetParticleControl(this.particle,3,this.GetParent().GetAbsOrigin());

			this.StartIntervalThink(FrameTime());
		}
	}

	OnIntervalThink() {
		//
		//print("Think")
		let units = FindUnitsInRadius(this.GetCaster().GetTeamNumber(),this.GetParent().GetAbsOrigin(),null,this.GetAbility().GetSpecialValueFor("crater_radius"),DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
		units.forEach((unit)=> {
			//print(unit.GetUnitName())
			let origin = this.GetParent().GetAbsOrigin()
			//@ts-ignore
			unit.AddNewModifier(this.GetCaster(),this.GetAbility(),"modifier_crater_area_control",{duration:0.1,x:origin.x,y:origin.y,z:origin.z})
		});
	}

	OnDestroy() {
		if (IsServer()) {
			ParticleManager.DestroyParticle(this.particle,true);
			ParticleManager.ReleaseParticleIndex(this.particle);
			ParticleManager.DestroyParticle(this.particle2,true);
			ParticleManager.ReleaseParticleIndex(this.particle2);
		}
	}
}

class modifier_crater_area_control extends CDOTA_Modifier_Lua {
	position:Vec

	OnCreated(kv) {
		if (IsClient()) {return}
		this.position = Vector(kv.x,kv.y,kv.z);
		//this.GetCaster().GetAbsOrigin();
		this.StartIntervalThink(FrameTime());

	}

	OnIntervalThink() {
		let unit = this.GetParent();
		let break_range = this.GetAbility().GetSpecialValueFor("crater_radius") -150;
		if ((unit.GetAbsOrigin()-this.position).Length2D() > break_range) {
			let direction = unit.GetAbsOrigin() - this.position;
			direction = direction.Normalized();
			let dot = direction.Dot(unit.GetForwardVector());
			if (dot > 0) {
				this.SetStackCount(1);
				return;
			}
		}
		this.SetStackCount(0); 
		AddFOWViewer(unit.GetTeamNumber(),this.position,break_range,FrameTime()*2,false);
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
			modifierfunction.MODIFIER_PROPERTY_FIXED_DAY_VISION,
		]
	}

	GetFixedDayVision() {
		return 50;
	}
	GetFixedNightVision() {
		return 50;
	}
	GetModifierMoveSpeed_Limit() {
		if(this.GetStackCount() == 1) {
			return 0.01;
		}
	}

	GetModifierMoveSpeedBonus_Constant() {
		if (this.GetStackCount() == 1) {
			return -1000;
		}
	}

	GetModifierMoveSpeed_Absolute() {
		if (this.GetStackCount() == 1) {
			return 0
		}
	}
}

class modifier_crater_spell_manager extends CDOTA_Modifier_Lua {
	IsHidden() {return true;}

}