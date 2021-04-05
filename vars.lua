local _, G = ...

local cvars = {
  alwaysShowActionBars = 0,
  autoClearAFK = 1,
  autointeract = 0,
  autoLootDefault = 1,
  autoQuestWatch = 1,
  autoSelfCast = 1,
  blockChannelInvites = 0,
  blockTrades = 0,
  cameraDistanceMaxZoomFactor = 2.6,
  chatBubbles = 1,
  chatBubblesParty = 0,
  chatStyle = 'classic',
  countdownForCooldowns = 0,
  deselectOnClick = 0,
  doNotFlashLowHealthWarning = 0,
  enableFloatingCombatText = 1,
  ffxDeath = 0,
  floatingCombatTextAuraFade = 1,
  floatingCombatTextAuras = 1,
  floatingCombatTextCombatDamage = 1,
  floatingCombatTextCombatLogPeriodicSpells = 1,
  floatingCombatTextCombatState = 1,
  floatingCombatTextComboPoints = 1,
  floatingCombatTextDamageReduction = 1,
  floatingCombatTextDodgeParryMiss = 1,
  floatingCombatTextEnergyGains = 1,
  floatingCombatTextFloatMode = 1,
  floatingCombatTextFriendlyHealers = 0,
  floatingCombatTextHonorGains = 1,
  floatingCombatTextLowManaHealth = 1,
  floatingCombatTextPetMeleeDamage = 1,
  floatingCombatTextPetSpellDamage = 1,
  floatingCombatTextReactives = 1,
  floatingCombatTextRepChanges = 1,
  guildMemberNotify = 1,
  hideOutdoorWorldState = 0,
  instantQuestText = 1,
  interactOnLeftClick = 0,
  lockActionBars = 0,
  lootUnderMouse = 0,
  multiBarRightVerticalLayout = 0,
  nameplateMotion = 0,
  nameplateShowAll = 1,
  nameplateShowEnemies = 1,
  nameplateShowEnemyMinions = 1,
  nameplateShowEnemyMinus = 1,
  nameplateShowFriends = 0,
  nameplateShowFriendlyMinions = 1,
  profanityFilter = 0,
  raidOptionIsShown = 0,
  rotateMinimap = 0,
  scriptErrors = 1,
  showLoadingScreenTips = 1,
  showLootSpam = 1,
  showMinimapClock = 0,
  showNewbieTips = 0,
  showTargetOfTarget = 0,
  showTimestamps = 'none',
  showToastBroadcast = 0,
  showToastFriendRequest = 1,
  showToastOffline = 1,
  showToastOnline = 1,
  showToastWindow = 0,
  showTutorials = 0,
  Sound_AmbienceVolume = 0.9,
  Sound_DialogVolume = 0.9,
  Sound_EnableAllSound = 1,
  Sound_EnableAmbience = 1,
  Sound_EnableDialog = 1,
  Sound_EnableEmoteSounds = 1,
  Sound_EnableErrorSpeech = 0,
  Sound_EnableMusic = 1,
  Sound_EnablePetSounds = 1,
  Sound_EnableSFX = 1,
  Sound_EnableSoundWhenGameIsInBG = 0,
  Sound_MasterVolume = 0.2,
  Sound_MusicVolume = 0.6,
  Sound_SFXVolume = 0.9,
  Sound_ZoneMusicNoDelay = 1,
  spamFilter = 1,
  statusText = 1,
  statusTextDisplay = 'NUMERIC',
  taintlog = 1,
  UnitNameEnemyMinionName = 1,
  UnitNameEnemyPlayerName = 1,
  UnitNameFriendlyMinionName = 1,
  UnitNameFriendlyPlayerName = 1,
  UnitNameNonCombatCreatureName = 0,
  UnitNameNPC = 0,
  UnitNameOwn = 0,
  UnitNamePlayerGuild = 1,
  UnitNamePlayerPVPTitle = 1,
  whisperMode = 'inline',
}

G.Eventer({
  VARIABLES_LOADED = function()
    for k, v in pairs(cvars) do
      SetCVar(k, v)
    end
    SetConsoleKey('F12')
    C_Timer.After(15, function()
      hooksecurefunc('SetCVar', function(key, value)
        print('SetCVar('..key..','..value..')')
      end)
    end)
  end,
})
