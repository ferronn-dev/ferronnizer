local addonName, G = ...

local dialogName = string.upper(addonName)
StaticPopupDialogs[dialogName] = {
  text = 'UI must be reloaded.',
  button1 = 'OK',
  OnAccept = ReloadUI,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

local addonsToDisable = {
  'Blizzard_CompactRaidFrames',
  'Blizzard_CUFProfiles',
  'Blizzard_RaidUI',
}

G.Eventer({
  ADDON_LOADED = function()
    RaidFrame:UnregisterAllEvents()
  end,
  PLAYER_ENTERING_WORLD = function()
    local playerName = UnitName('player')
    local mustReload = false
    for _, addon in ipairs(addonsToDisable) do
      if GetAddOnEnableState(playerName, addon) == 2 then
        DisableAddOn(addon)
        mustReload = true
      end
    end
    if mustReload then
      StaticPopup_Show(dialogName)
    end
  end,
})
