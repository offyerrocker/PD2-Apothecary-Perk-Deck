Hooks:PostHook(BlackMarketTweakData,"_init_projectiles","apothecary_blackmarkettweakdata_init_projectiles",function(self,_tweak_data)
	self.projectiles.apothecary_catalyzer = {
		name_id = "bm_grenade_apothecary_catalyzer",
		desc_id = "bm_grenade_apothecary_catalyzer_desc",
		icon = "apothecary_throwable",
		ability = "apothecary_catalyzer",
		custom = true,
		ignore_statistics = true,
		based_on = "copr_ability",
		texture_bundle_folder = "apothecary",
		max_amount = 1,
		base_cooldown = 90,
		sounds = {
			activate = "perkdeck_activate",
			cooldown = "perkdeck_cooldown_over"
		}
	}
	table.insert(self._projectiles_index,"apothecary_catalyzer")
end)