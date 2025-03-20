local GAP_BETWEEN_WINDOWS = 16
local SKETCHYBAR_HEIGHT = 32
local TOP_GAP = 13 

local FAST_STEPS = 8
local FAST_DELAY = 0.01

local function updatePowerState()
  local powerSource = hs.battery.powerSource()
  return powerSource == "AC Power"
end

local isPluggedIn = updatePowerState()

function moveWindow(win, targetFrame)
  if not win then return end
  
  isPluggedIn = updatePowerState()
  
  if isPluggedIn then
      local frame = win:frame()
      local step = 0
      local timer = hs.timer.doEvery(FAST_DELAY, function()
          if step >= FAST_STEPS then
              timer:stop()
              return
          end
          local progress = (step + 1) / FAST_STEPS
          local newFrame = {
              x = frame.x + (targetFrame.x - frame.x) * progress,
              y = frame.y + (targetFrame.y - frame.y) * progress,
              w = frame.w + (targetFrame.w - frame.w) * progress,
              h = frame.h + (targetFrame.h - frame.h) * progress,
          }
          win:setFrame(newFrame)
          step = step + 1
      end)
  else
      win:setFrame(targetFrame)
  end
end

function moveWindowToPosition(position)
  local win = hs.window.focusedWindow()
  if not win then return end
  local screenFrame = win:screen():frame()

  if win:screen():name() == hs.screen.primaryScreen():name() then
      screenFrame.y = screenFrame.y + SKETCHYBAR_HEIGHT + TOP_GAP
      screenFrame.h = screenFrame.h - SKETCHYBAR_HEIGHT - TOP_GAP
  else
      screenFrame.y = screenFrame.y + TOP_GAP
      screenFrame.h = screenFrame.h - TOP_GAP
  end

  local newFrame = position(screenFrame, TOP_GAP)
  moveWindow(win, newFrame)
end

hs.hotkey.bind({"ctrl", "alt"}, "Left", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w / 2 - gap, screen.h - gap)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Right", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + screen.w / 2 + gap, screen.y, screen.w / 2 - gap * 2, screen.h - gap)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Up", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w - 2 * gap, screen.h / 2 - gap)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Down", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y + screen.h / 2 + gap, screen.w - 2 * gap, screen.h / 2 - gap)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Return", function() 
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w - 2 * gap, screen.h - gap)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "D", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w / 3 - gap, screen.h - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "F", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + screen.w / 3 + gap, screen.y, screen.w / 3 - 2 * gap, screen.h - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "G", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + (2 * screen.w / 3), screen.y, screen.w / 3 - gap, screen.h - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "E", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen()
  local screenFrame = screen:frame()
  local winFrame = win:frame()

  local isPrimaryScreen = (screen:name() == hs.screen.primaryScreen():name())
  local topOffset = isPrimaryScreen and (SKETCHYBAR_HEIGHT + TOP_GAP) or TOP_GAP
  local adjustedHeight = screenFrame.h - topOffset

  if winFrame.x < screenFrame.x + screenFrame.w / 3 then
      moveWindow(win, hs.geometry.rect(
          screenFrame.x + screenFrame.w / 3 + TOP_GAP,
          screenFrame.y + topOffset,
          (2 * screenFrame.w / 3) - 2 * TOP_GAP,
          adjustedHeight - TOP_GAP
      ))
  else
      moveWindow(win, hs.geometry.rect(
          screenFrame.x + TOP_GAP,
          screenFrame.y + topOffset,
          (2 * screenFrame.w / 3) - 2 * TOP_GAP,
          adjustedHeight - TOP_GAP
      ))
  end
end)

hs.hotkey.bind({"ctrl", "alt"}, "U", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w / 2 - gap, screen.h / 2 - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "I", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + screen.w / 2 + 2 * gap - TOP_GAP, screen.y, screen.w / 2 - gap - TOP_GAP, screen.h / 2 - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "J", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + gap, screen.y + screen.h / 2 + gap - TOP_GAP, screen.w / 2 - gap, screen.h / 2 - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "K", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + screen.w / 2 + 2 * gap - TOP_GAP, screen.y + screen.h / 2 + gap - TOP_GAP, screen.w / 2 - gap - TOP_GAP, screen.h / 2 - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", function()
  local win = hs.window.focusedWindow()
  if win then win:moveToScreen(win:screen():next()) end
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left", function()
  local win = hs.window.focusedWindow()
  if win then win:moveToScreen(win:screen():previous()) end
end)

function powerStatusChanged()
  local newPowerState = updatePowerState()
  
  if newPowerState ~= isPluggedIn then
      isPluggedIn = newPowerState
  end
end

powerWatcher = hs.battery.watcher.new(powerStatusChanged)
powerWatcher:start()