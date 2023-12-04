Hooks:PostHook(UpgradesTweakData,"_grenades_definitions","apothecary_init_grenades_definitions",function(self)
	self.definitions.apothecary_catalyzer = {
		category = "grenade"
	}
end)

-- 5% melee vuln increase

--Hooks:PostHook(UpgradesTweakData,"_init_values","apothecary_init_values",function(self) end)

Hooks:PostHook(UpgradesTweakData,"_player_definitions","apothecary_init_player_definitions",function(self)

	--self.values.grenade_launcher = self.values.grenade_launcher or {}
	
	self.definitions.player_apothecary_catalyzer_base = {
		name_id = "menu_deck_apothecary_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_catalyzer_base",
			category = "player"
		}
	}
	self.values.player.apothecary_catalyzer_base = {
		10 -- damage increase lasts 10 seconds
	}
	
	self.definitions.player_apothecary_catalyzer_cooldown_drain_1 = {
		name_id = "menu_deck_apothecary_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_catalyzer_cooldown_drain",
			category = "player"
		}
	}
	self.definitions.player_apothecary_catalyzer_cooldown_drain_2 = {
		name_id = "menu_deck_apothecary_1",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "apothecary_catalyzer_cooldown_drain",
			category = "player"
		}
	}
	self.values.player.apothecary_catalyzer_cooldown_drain = {
		2, -- 2s cooldown speed up on kill
		3
	}
	
	self.definitions.player_apothecary_activate_dot_rampup_1 = {
		name_id = "menu_deck_apothecary_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_activate_dot_rampup",
			category = "player"
		}
	}
	self.definitions.player_apothecary_activate_dot_rampup_2 = {
		name_id = "menu_deck_apothecary_3",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "apothecary_activate_dot_rampup",
			category = "player"
		}
	}
	self.definitions.player_apothecary_activate_dot_rampup_3 = {
		name_id = "menu_deck_apothecary_5",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "apothecary_activate_dot_rampup",
			category = "player"
		}
	}
	self.definitions.player_apothecary_activate_dot_rampup_4 = {
		name_id = "menu_deck_apothecary_7",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "apothecary_activate_dot_rampup",
			category = "player"
		}
	}
	self.values.player.apothecary_activate_dot_rampup = {
		0.1, -- +2 damage per second
		0.15, -- +3 damage per second
		0.2, -- +4 damage per second
		0.25 -- +5 damage per second
	}
	self.definitions.player_apothecary_gas_highlight = {
		name_id = "menu_deck_apothecary_3",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_highlight",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_highlight = { "apothecary_gas_enemy_mark" } -- "mark_enemy"
	self.values.player.apothecary_activate_nausea = { true }
	self.definitions.player_apothecary_activate_nausea = {
		name_id = "menu_deck_apothecary_3",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_activate_nausea",
			category = "player"
		}
	}
	
	self.definitions.player_apothecary_passive_health_increase_1 = {
		name_id = "menu_deck_apothecary_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_passive_health_increase",
			category = "player"
		}
	}
	self.definitions.player_apothecary_passive_health_increase_2 = {
		name_id = "menu_deck_apothecary_3",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "apothecary_passive_health_increase",
			category = "player"
		}
	}
	self.definitions.player_apothecary_passive_health_increase_3 = {
		name_id = "menu_deck_apothecary_5",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "apothecary_passive_health_increase",
			category = "player"
		}
	}
	self.values.player.apothecary_passive_health_increase = {
		2, -- 20
		4, -- 40
		7  -- 70
	}
	
	self.definitions.player_apothecary_gas_enemy_melee_catalyzer_extension = {
		name_id = "menu_deck_apothecary_3",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_enemy_melee_catalyzer_extension",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_enemy_melee_catalyzer_extension = {
		2
	}
	
	self.definitions.player_apothecary_activate_duration_increase = {
		name_id = "menu_deck_apothecary_3",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_activate_duration_increase",
			category = "player"
		}
	}
	self.values.player.apothecary_activate_duration_increase = {
		1 -- +1 second initial duration per enemy currently affected by poison gas damage
	}
	
	self.definitions.player_apothecary_gas_melee_temporary_damage_resistance_1 = {
		name_id = "menu_deck_apothecary_5",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_melee_temporary_damage_resistance",
			category = "player"
		}
	}
	self.definitions.player_apothecary_gas_melee_temporary_damage_resistance_2 = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "apothecary_gas_melee_temporary_damage_resistance",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_melee_temporary_damage_resistance = {
		0.02, -- +2% dmg res per stack
		0.04 -- +4% dmg res per stack
	}
	self.values.player.apothecary_gas_melee_temporary_damage_resistance_max = 50
	self.values.player.apothecary_gas_melee_temporary_damage_resistance_duration = 10
	
	self.definitions.player_apothecary_activate_ally_kill_restore_health = {
		name_id = "menu_deck_apothecary_7",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_activate_ally_kill_restore_health",
			category = "player"
		}
	}
	self.values.player.apothecary_activate_ally_kill_restore_health = {
		{
			kill_stacks = 1, -- stacks added per normal kill
			melee_stacks = 5, -- stacks added per allied melee kill (overrides normal kill_stacks)
			stacks_threshold = 5, -- stacks required/consumed to give healing burst
			heal_ally_tier = 1, -- heal amount for allies (5%)
			heal_self_amount = 0.05, -- heal self by 5%
			catalyst_double_stacks = 2
		}
	}
	
	self.definitions.player_apothecary_activate_speed_boost = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_activate_speed_boost",
			category = "player"
		}
	}
	self.values.player.apothecary_activate_speed_boost = {
		0.3 -- +30% movement speed bonus
	}
	-- uses inspire basic message for allied speed boost (also grants reload speed bonus)
	
	self.definitions.player_apothecary_gas_bonus_damage_resistance = {
		name_id = "menu_deck_apothecary_7",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_bonus_damage_resistance",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_bonus_damage_resistance = {
		0.25 -- flat bonus while in gas
	}
	self.values.player.apothecary_gas_bonus_linger_duration = 10 --applies to both speed and passive 25% damage resist
	
	
	self.definitions.player_apothecary_gas_enemy_melee_panic = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_enemy_melee_panic",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_enemy_melee_panic = {
		{
			700,
			0.75
		}
	}
	
	self.definitions.player_apothecary_gas_enemy_melee_vulnerability = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_enemy_melee_vulnerability",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_enemy_melee_vulnerability = {
		0.5
	}
	
	self.definitions.player_apothecary_gas_enemy_melee_catalyzer_vulnerability = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_gas_enemy_melee_catalyzer_vulnerability",
			category = "player"
		}
	}
	self.values.player.apothecary_gas_enemy_melee_catalyzer_vulnerability = {
		0.5
	}
	
	self.definitions.player_apothecary_activate_double_healing = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "apothecary_activate_double_healing",
			category = "player"
		}
	}
	self.values.player.apothecary_activate_double_healing = {
		2
	}
	
	
	self.values.grenade_launcher = self.values.grenade_launcher or {}
		
	-- 2x firerate for grenade launchers
	local gl_firerate_upgrade_tier = 1
	if self.values.grenade_launcher.fire_rate_multiplier then 
		-- for compatibility, in case other mods affect grenade launcher firerate
		gl_firerate_upgrade_tier = #self.values.grenade_launcher.fire_rate_multiplier + 1
		self.values.grenade_launcher.fire_rate_multiplier[gl_firerate_upgrade_tier] = 2
	else
		self.values.grenade_launcher.fire_rate_multiplier = {
			2
		}
	end
	self.definitions.player_apothecary_grenade_launcher_fire_rate_multiplier = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = gl_firerate_upgrade_tier,
			upgrade = "fire_rate_multiplier",
			category = "grenade_launcher"
		}
	}
	
	-- 2x reload speed for grenade launchers
	local gl_upgrade_tier = 1
	if self.values.grenade_launcher.reload_speed_multiplier then 
		-- for compatibility, in case other mods affect grenade launcher reload speed
		gl_upgrade_tier = #self.values.grenade_launcher.reload_speed_multiplier + 1
		self.values.grenade_launcher.reload_speed_multiplier[gl_upgrade_tier] = 2
	else
		self.values.grenade_launcher = self.values.grenade_launcher or {}
		self.values.grenade_launcher.reload_speed_multiplier = {
			2
		}
	end
	self.definitions.player_apothecary_grenade_launcher_reload_speed_multiplier = {
		name_id = "menu_deck_apothecary_9",
		category = "feature",
		upgrade = {
			value = gl_upgrade_tier,
			upgrade = "reload_speed_multiplier",
			category = "grenade_launcher"
		}
	}
	
end)