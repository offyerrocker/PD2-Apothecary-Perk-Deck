
local paid = false
--if you want this perk deck to be instantly unlocked, change the above "true" to "false" (no quotation marks)

local costs = {
	[1] = 200,
	[2] = 300,
	[3] = 400,
	[4] = 600,
	[5] = 1000,
	[6] = 1600,
	[7] = 2400,
	[8] = 3200,
	[9] = 4000
}
--this is a simple function that looks up the cost for a given perk card tier given the above costs table
--however, if the paid var is false, then the cost is instead returned as 0 (unlocked instantly)
local function cost(n)
	return paid and costs[n] or 0
end

Hooks:PostHook(SkillTreeTweakData,"init","apothecary_initskilltree",function(self,data)
	
	--(re)define the "generic" cards that all perk decks share
	--due to how overkill has set up localization macros (selectively replacing certain substrings in a localization string),
	--we can't just copy the existing localization ids for the descriptions (the names are fine).
	--luckily, i have a fix for that at the bottom of the file

	local deck2 = {
		cost = cost(2),
		desc_id = "menu_deck_apothecary_2_desc",
		name_id = "menu_deckall_2",
		upgrades = {
			"weapon_passive_headshot_damage_multiplier"
		},
		icon_xy = {
			1,
			0
		}
	}
	local deck4 = {
		cost = cost(4),
		desc_id = "menu_deck_apothecary_4_desc",
		name_id = "menu_deckall_4",
		upgrades = {
			"passive_player_xp_multiplier",
			"player_passive_suspicion_bonus",
			"player_passive_armor_movement_penalty_multiplier"
		},
		icon_xy = {
			3,
			0
		}
	}
	local deck6 = {
		cost = cost(6),
		desc_id = "menu_deck_apothecary_6_desc",
		name_id = "menu_deckall_6",
		upgrades = {
			"armor_kit",
			"player_pick_up_ammo_multiplier"
		},
		icon_xy = {
			5,
			0
		}
	}
	local deck8 = {
		cost = cost(8),
		desc_id = "menu_deck_apothecary_8_desc",
		name_id = "menu_deckall_8",
		upgrades = {
			"weapon_passive_damage_multiplier",
			"passive_doctor_bag_interaction_speed_multiplier"
		},
		icon_xy = {
			7,
			0
		}
	}
	
	local perk_deck_data = {
		based_on = 22,
		name_id = "menu_deck_apothecary_title",
		desc_id = "menu_deck_apothecary_desc",
		{
			upgrades = {
				"apothecary_catalyzer",
				"player_apothecary_catalyzer_base",
				"player_apothecary_catalyzer_cooldown_drain_1",
				"player_apothecary_activate_dot_rampup_1",
				"player_apothecary_gas_enemy_melee_catalyzer_extension"
			},
			cost = cost(1),
			icon_xy = {0, 0},
			texture_bundle_folder = "apothecary",
			name_id = "menu_deck_apothecary_1",
			desc_id = "menu_deck_apothecary_1_desc"
		},
		deck2,
		{
			upgrades = {
				"player_apothecary_passive_health_increase_1",
				"player_apothecary_gas_highlight",
				"player_apothecary_activate_nausea",
				"player_apothecary_activate_dot_rampup_2",
				"player_apothecary_gas_enemy_melee_panic"
			},
			cost = cost(3),
			icon_xy = {1, 0},
			texture_bundle_folder = "apothecary",
			name_id = "menu_deck_apothecary_3",
			desc_id = "menu_deck_apothecary_3_desc"
		},
		deck4,
		{
			upgrades = {
				"player_apothecary_passive_health_increase_2",
				"player_apothecary_activate_duration_increase",
				"player_apothecary_gas_melee_temporary_damage_resistance_1",
				"player_apothecary_gas_bonus_damage_resistance",
				"player_apothecary_activate_dot_rampup_3"
				
			},
			cost = cost(5),
			icon_xy = {2, 0},
			texture_bundle_folder = "apothecary",
			name_id = "menu_deck_apothecary_5",
			desc_id = "menu_deck_apothecary_5_desc"
		},
		deck6,
		{
			upgrades = {
				"player_apothecary_activate_ally_kill_restore_health",
				"player_apothecary_activate_dot_rampup_4"
			},
			cost = cost(7),
			icon_xy = {3, 0},
			texture_bundle_folder = "apothecary",
			name_id = "menu_deck_apothecary_7",
			desc_id = "menu_deck_apothecary_7_desc"
		},
		deck8,
		{
			upgrades = {
				"player_apothecary_passive_health_increase_3",
				"player_apothecary_activate_speed_boost",
				"player_apothecary_gas_enemy_melee_vulnerability",
				"player_apothecary_gas_melee_temporary_damage_resistance_2",
				"player_apothecary_grenade_launcher_reload_speed_multiplier",
				"player_apothecary_grenade_launcher_fire_rate_multiplier",
				"player_apothecary_activate_double_healing",
				"player_passive_loot_drop_multiplier"
			},
			cost = cost(9),
			icon_xy = {0, 1},
			texture_bundle_folder = "apothecary",
			name_id = "menu_deck_apothecary_9",
			desc_id = "menu_deck_apothecary_9_desc"
		}
	}

	table.insert(self.specializations,perk_deck_data)
		
	local apothecary_decknumber = #self.specializations
	
	Hooks:Add("LocalizationManagerPostInit", "apothecary_addlocalization", function( loc )
		if apothecary_decknumber then 
			--used for the name of the perk deck as it appears on other players,
			--since the perk deck index is synced, and the index will vary with custom perk decks
			loc:add_localized_strings({
				["menu_st_spec_" .. tostring(apothecary_decknumber)] = loc:text(perk_deck_data.name_id)
			})
		end
		
--		the 'generic' perkdeck cards ("menu_deckall_2_desc" etc) have a macro localization issue when referenced directly
--		so we need to fix it for our deck here and substitute the macro keys with the proper values
--		if a mod has edited the values, that will be a problem, however

		local adjusted_description_2 = loc:text("menu_deckall_2_desc")
		adjusted_description_2 = string.gsub(adjusted_description_2,"$multiperk;","25%%")
		local adjusted_description_4 = loc:text("menu_deckall_4_desc")
		adjusted_description_4 = string.gsub(adjusted_description_4,"$multiperk;","+1")
		adjusted_description_4 = string.gsub(adjusted_description_4,"$multiperk2;","15%%")
		adjusted_description_4 = string.gsub(adjusted_description_4,"$multiperk3;","45%%")
		local adjusted_description_6 = loc:text("menu_deckall_6_desc")
		adjusted_description_6 = string.gsub(adjusted_description_6,"$multiperk;","135%%")
		local adjusted_description_8 = loc:text("menu_deckall_8_desc")
		adjusted_description_8 = string.gsub(adjusted_description_8,"$multiperk;","5%%")
		adjusted_description_8 = string.gsub(adjusted_description_8,"$multiperk2;","20%%")
		
		loc:add_localized_strings({
			menu_deck_apothecary_2_desc = adjusted_description_2,
			menu_deck_apothecary_4_desc = adjusted_description_4,
			menu_deck_apothecary_6_desc = adjusted_description_6,
			menu_deck_apothecary_8_desc = adjusted_description_8 
		})
	end)

	
end)