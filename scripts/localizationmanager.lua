local mod_path = ModPath
Hooks:Add("LocalizationManagerPostInit", "apothecary_locmgr_add_localization", function(localizationmgr)
	if BeardLib then 
		--if beardlib is installed, then we don't need to load localization,
		--since beardlib's localization module can handle localization for you, so we do nothing here.
		
		--in this example, the mod is set up to handle it. take a look at the included main.xml
		return
	else
		local path = mod_path .. "localization/english.json"
		localizationmgr:load_localization_file( path )
	end
end)