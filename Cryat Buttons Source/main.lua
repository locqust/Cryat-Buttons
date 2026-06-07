-- ============================================================
-- Cryat Buttons Source v1.0
-- Install to: /scripts/Cryat Buttons Source/main.lua
--
-- Matches Kyberpad Source structure exactly.
-- NO value function registered - ETHOS manages value internally.
-- Widget sets value via src:value(x), mixer reads it natively.
-- ============================================================

local function init()
  local locale = system.getLocale()
end

system.registerSource({
  key  = "CryatBS",
  name = "Cryat Buttons Source",
  init = init,
})
