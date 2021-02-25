local _, G = ...

G.Eventer({
  PLAYER_LOGIN = function()
    G.ReparentFrame(PlayerFrame)
    G.ReparentFrame(TargetFrame)
  end,
})
