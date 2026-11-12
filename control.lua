
local legacy_import=require("legacy_import")
script.on_init(function() legacy_import.adopt("fixadamo-carbon") end)
script.on_configuration_changed(function() legacy_import.adopt("fixadamo-carbon") end)
