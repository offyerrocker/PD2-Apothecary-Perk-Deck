PlayerAction.ApothecaryCatalyzer = {
	Priority = 1,
	Function = function()
		local pm = managers.player
		local timer = TimerManager:game() --or managers.game_play_central:get_heist_timer()
		local player = pm:local_player()
		if not alive(player) then 
			return
		end
		local dmg_ext = player:character_damage()
		local duration = pm:upgrade_value("player","apothecary_catalyzer_base",0)
		
		if pm:has_category_upgrade("player","apothecary_activate_nausea") then
			Hooks:Call("catalyzer_nausea")
		end
		local cooldown_drain = pm:upgrade_value("player","apothecary_catalyzer_cooldown_drain",0)
		
		-- extend duration for each enemy in a cloud at the time of activation
		if pm:has_category_upgrade("player","apothecary_activate_duration_increase") then
			local duration_bonus = pm:upgrade_value("player","apothecary_activate_duration_increase",1)
			for _,dot_info in pairs(managers.dot._doted_enemies) do 
				if dot_info.gascloud_id then -- is from poison gas
					duration = duration + duration_bonus
				end
			end
		end
		
		-- apply speed boost to allies
		-- note: speed boost to self timer is in playermanager, conditional only on catalyzer state
		if pm:has_category_upgrade("player","apothecary_activate_speed_boost") then 
			
			-- give allies speed boost
			for _,char_data in pairs(managers.criminals._characters) do
				if char_data.taken then
					if alive(char_data.unit) and char_data.unit ~= player then 
						char_data.unit:network():send_to_unit({
							"long_dis_interaction",
							char_data.unit,
							1,
							player,
							false
						})
					end
				end
			end
			
			--managers.player:activate_temporary_upgrade("temporary", "damage_speed_multiplier")
			--managers.player:send_activate_temporary_team_upgrade_to_peers("temporary", "team_damage_speed_multiplier_received")
		end
		
		
		if pm:has_category_upgrade("player","apothecary_catalyzer_cooldown_drain") then
			pm:register_message(Message.OnEnemyKilled, "on_apothecary_cooldown_drain",function(weapon_unit, variant)
				if alive(player) then
					managers.player:speed_up_grenade_cooldown(cooldown_drain)
				end
			end)
		end
		
		local start_t = timer:time()
		local end_time = start_t + duration
		
		Hooks:Add("apothecary_catalyzer_extend_timer","apothecary_on_extend_catalyzer",function(duration_bonus)
			if pm:get_property("apothecary_catalyzer_active") then
				end_time = end_time + duration_bonus
				start_t = start_t + duration_bonus
				--managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, end_time - start_t, duration)
			end
		end)
		
		managers.network:session():send_to_peers("sync_ability_hud", end_time, duration)
		
		pm:set_property("apothecary_catalyzer_active",true)
		
		repeat
			if dmg_ext:dead() then --or dmg_ext:is_downed() 
				break
			end
			
			managers.hud:set_teammate_ability_radial(HUDManager.PLAYER_PANEL, {current=(end_time - timer:time()),total=end_time - start_t})
			coroutine.yield()
		until not (alive(player) and timer:time() < end_time)
		
		Hooks:Remove("apothecary_catalyzer_extend_timer")
		pm:set_property("apothecary_catalyzer_active",false)
		
		-- temp 25% dmg resist
		pm._apothecary_bonus_linger_timer = tweak_data.upgrades.values.player.apothecary_gas_bonus_linger_duration
		
		managers.hud:set_teammate_ability_radial(HUDManager.PLAYER_PANEL, {current=0,total=1})
		
		while not pm:got_max_grenades() do 
			coroutine.yield()
		end
		
		pm:unregister_message(Message.OnEnemyKilled, "on_apothecary_cooldown_drain")
	end
}