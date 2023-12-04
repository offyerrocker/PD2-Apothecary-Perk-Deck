
--networking fixes (to not crash other players)

local function get_as_digested(amount)
	local list = {}

	for i = 1, #amount do
		table.insert(list, Application:digest_value(amount[i], false))
	end

	return list
end

local function make_double_hud_string(a, b)
	return string.format("%01d|%01d", a, b)
end

local function add_hud_item(amount, icon)
	if #amount > 1 then
		managers.hud:add_item_from_string({
			amount_str = make_double_hud_string(amount[1], amount[2]),
			amount = amount,
			icon = icon
		})
	else
		managers.hud:add_item({
			amount = amount[1],
			icon = icon
		})
	end
end

local function set_hud_item_amount(index, amount)
	if #amount > 1 then
		managers.hud:set_item_amount_from_string(index, make_double_hud_string(amount[1], amount[2]), amount)
	else
		managers.hud:set_item_amount(index, amount[1])
	end
end

function PlayerManager:update_grenades_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_grenades[peer_id] then
		local grenade = self._global.synced_grenades[peer_id].grenade
		local tweak = tweak_data.blackmarket.projectiles[grenade]
		if tweak.based_on then 
			grenade = tweak.based_on
		end
		local amount = self._global.synced_grenades[peer_id].amount

		peer:send_queued_sync("sync_grenades", grenade, Application:digest_value(amount, false), 0)
	end
end

function PlayerManager:update_grenades_amount_to_peers(grenade, amount, register_peer_id)
	local peer_id = managers.network:session():local_peer():id()
	
		local tweak = tweak_data.blackmarket.projectiles[grenade]
		if tweak.based_on then 
			grenade = tweak.based_on
		end
		
	managers.network:session():send_to_peers_synched("sync_grenades", grenade, amount, register_peer_id or 0)
	self:set_synced_grenades(peer_id, grenade, amount, register_peer_id)
end

--fixes the synced (spoofed) grenade data being used for the actual data- specifically, cooldown
function PlayerManager:add_grenade_amount(amount, sync)
	local peer_id = managers.network:session():local_peer():id()
	local grenade = managers.blackmarket:equipped_grenade() --self._global.synced_grenades[peer_id].grenade
	local tweak = tweak_data.blackmarket.projectiles[grenade]
	local max_amount = self:get_max_grenades_by_peer_id(peer_id)
	local icon = tweak.icon
	local previous_amount = self._global.synced_grenades[peer_id].amount

	if amount > 0 and tweak.base_cooldown then
		managers.hud:animate_grenade_flash(HUDManager.PLAYER_PANEL)
	end

	amount = math.min(Application:digest_value(previous_amount, false) + amount, max_amount)

	if amount < max_amount and tweak.base_cooldown then
		self:replenish_grenades(tweak.base_cooldown)
	end

	managers.hud:set_teammate_grenades_amount(HUDManager.PLAYER_PANEL, {
		icon = icon,
		amount = amount
	})
	self:update_grenades_amount_to_peers(grenade, amount, sync and peer_id)
end
