local GAP_BETWEEN_WINDOWS = 20
-- local GAP_BETWEEN_WINDOWS = 0
local SKETCHYBAR_HEIGHT = 32
local TOP_GAP = 15
-- local TOP_GAP = 30

local FAST_STEPS = 8
local FAST_DELAY = 0.01
local screens = hs.screen.allScreens()
local screenCount = #screens

local function updatePowerState()
  local powerSource = hs.battery.powerSource()
  return powerSource == "AC Power"
end

local function getExternalScreen()
  for _, screen in ipairs(hs.screen.allScreens()) do
      if screen:name() ~= "Built-in Retina Display" then
          return screen
      end
  end
  return nil
end

local isPluggedIn = updatePowerState()

function moveWindow(win, targetFrame)
  if not win then return end
  win:setFrame(targetFrame)
end

function moveWindowToPosition(position)
  local win = hs.window.focusedWindow()
  if not win then return end

  local currentScreen = win:screen()
  local screenFrame = currentScreen:frame()

  if currentScreen:name() ~= "Built-in Retina Display" then
    screenFrame.y = screenFrame.y + SKETCHYBAR_HEIGHT + TOP_GAP
    screenFrame.h = screenFrame.h - SKETCHYBAR_HEIGHT - TOP_GAP
  else
    screenFrame.y = screenFrame.y + TOP_GAP
    screenFrame.h = screenFrame.h - TOP_GAP

  end

  local newFrame = position(screenFrame, TOP_GAP)
  moveWindow(win, newFrame)
end


function getHalfFrame(screen, side, gap)
  local f = screen:frame()
  local yOffset = f.y
  local height = f.h
  local width = (f.w / 2)

  if side == "left" then
    return hs.geometry.rect(f.x + gap, yOffset, width - gap, height)
  elseif side == "right" then
    return hs.geometry.rect(f.x + width + gap, yOffset, width - 2 * gap, height)
  end
end

local function isFrameInHalf(winFrame, screenFrame, side, tolerance)
  tolerance = tolerance or 10
  local halfWidth = screenFrame.w / 2
  local leftX = screenFrame.x
  local rightX = screenFrame.x + halfWidth

  if side == "left" then
    return math.abs(winFrame.x - leftX - TOP_GAP) < tolerance
  elseif side == "right" then
    return math.abs(winFrame.x - rightX - GAP_BETWEEN_WINDOWS) < tolerance
  end
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", function()
  moveWindowToPosition(function(screen, gap)
    local win = hs.window.focusedWindow()
    if not win then return end
  
    local oldScreen = win:screen()
    local newScreen = oldScreen:next()
    if not newScreen then return end
  
    local oldFrame = oldScreen:frame()
    local newFrame = newScreen:frame()
    local winFrame = win:frame()
  
    local side = winFrame.x < (oldFrame.x + oldFrame.w / 2) and "left" or "right"
  
    local targetFrame = (side == "left")
    and hs.geometry.rect(hs.geometry.rect(newFrame.x + TOP_GAP, newFrame.y + gap, (newFrame.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, newFrame.h - TOP_GAP))
    or  hs.geometry.rect(newFrame.x + newFrame.w / 2 + GAP_BETWEEN_WINDOWS, newFrame.y + gap, (newFrame.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, newFrame.h - TOP_GAP)
  
    return targetFrame
  end)
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left", function()
  local win = hs.window.focusedWindow()
  if not win then return end

  local oldScreen = win:screen()
  local newScreen = oldScreen:previous()
  if not newScreen then return end

  local oldFrame = oldScreen:frame()
  local newFrame = newScreen:frame()
  local winFrame = win:frame()

  local side = winFrame.x < (oldFrame.x + oldFrame.w / 2) and "left" or "right"

  local targetFrame = (side == "left")
  and hs.geometry.rect(hs.geometry.rect(newFrame.x + TOP_GAP, newFrame.y + TOP_GAP, (newFrame.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, newFrame.h - TOP_GAP - GAP_BETWEEN_WINDOWS))
  or  hs.geometry.rect(newFrame.x + newFrame.w / 2 + GAP_BETWEEN_WINDOWS, newFrame.y + TOP_GAP, (newFrame.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, newFrame.h - TOP_GAP - GAP_BETWEEN_WINDOWS)

  moveWindow(win, targetFrame)
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Return", function() 
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x, screen.y - TOP_GAP, screen.w, screen.h + TOP_GAP)
  end)
end)

-- ------------------------------------------------------------ARROWS------------------------------------------------------------

-- DONE
hs.hotkey.bind({"ctrl", "alt"}, "Left", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + TOP_GAP, screen.y,  screen.w / 2 - GAP_BETWEEN_WINDOWS / 2 - TOP_GAP, screen.h - gap)
  end)
end)

-- DONE
hs.hotkey.bind({"ctrl", "alt"}, "Right", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + screen.w / 2 + GAP_BETWEEN_WINDOWS / 2, screen.y,  screen.w / 2 - GAP_BETWEEN_WINDOWS / 2 - TOP_GAP, screen.h - gap)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Up", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w - 2 * TOP_GAP, (screen.h - TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Down", function()
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y + screen.h / 2, screen.w - 2 * TOP_GAP, (screen.h - TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2)
  end)
end)

hs.hotkey.bind({"ctrl", "alt"}, "Return", function() 
  moveWindowToPosition(function(screen, gap)
      return hs.geometry.rect(screen.x + gap, screen.y, screen.w - 2 * gap, screen.h - TOP_GAP)
  end)
end)

-- ------------------------------------------------------------THIRDS------------------------------------------------------------

hs.hotkey.bind({"ctrl", "alt"}, "D", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + TOP_GAP, screen.y, (screen.w  - TOP_GAP - 2 * GAP_BETWEEN_WINDOWS) / 3 - gap, screen.h - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "F", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + (screen.w  - TOP_GAP - 2 * GAP_BETWEEN_WINDOWS) / 3 + GAP_BETWEEN_WINDOWS, screen.y, (screen.w  - TOP_GAP - 2 * GAP_BETWEEN_WINDOWS) / 3, screen.h - gap) 
  end) 
end)

hs.hotkey.bind({"ctrl", "alt"}, "G", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + (2 * (screen.w  - TOP_GAP - 2 * GAP_BETWEEN_WINDOWS) / 3) + 2 * GAP_BETWEEN_WINDOWS, screen.y, (screen.w  - TOP_GAP - 2 * GAP_BETWEEN_WINDOWS) / 3, screen.h - gap) 
  end) 
end)

-- ------------------------------------------------------------TWO THIRDS------------------------------------------------------------

hs.hotkey.bind({"ctrl", "alt"}, "E", function()
  moveWindowToPosition(function(screenFrame, gap)
    local win = hs.window.focusedWindow()
    if not win then return end

    local winFrame = win:frame()

    if winFrame.x < screenFrame.x + screenFrame.w / 3 then
        return hs.geometry.rect(
            screenFrame.x + screenFrame.w / 3,
            screenFrame.y,
            (2 * screenFrame.w / 3) - TOP_GAP,
            screenFrame.h - TOP_GAP
        )
    else
        return hs.geometry.rect(
            screenFrame.x + TOP_GAP,
            screenFrame.y,
            (2 * screenFrame.w / 3) - 2 * TOP_GAP,
            screenFrame.h - TOP_GAP
        )
    end
  end)
end)


-- ------------------------------------------------------------FOURTH------------------------------------------------------------

-- DONE
hs.hotkey.bind({"ctrl", "alt"}, "U", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + gap, screen.y, (screen.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, screen.h / 2 - gap) 
  end) 
end)

-- DONE
hs.hotkey.bind({"ctrl", "alt"}, "I", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + screen.w / 2 + GAP_BETWEEN_WINDOWS / 2, screen.y, (screen.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, screen.h / 2 - gap) 
  end) 
end)

-- DONE
hs.hotkey.bind({"ctrl", "alt"}, "J", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + gap, screen.y + screen.h / 2 + gap - TOP_GAP, (screen.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, screen.h / 2 - gap) 
  end) 
end)

-- DONE
hs.hotkey.bind({"ctrl", "alt"}, "K", function() 
  moveWindowToPosition(function(screen, gap) 
      return hs.geometry.rect(screen.x + screen.w / 2 + GAP_BETWEEN_WINDOWS / 2, screen.y + screen.h / 2 + gap - TOP_GAP, (screen.w  - 2 * TOP_GAP - GAP_BETWEEN_WINDOWS)/ 2, screen.h / 2 - gap) 
  end) 
end)

-- ------------------------------------------------------------MOVE BETWEEN DISPLAYS------------------------------------------------------------

-- hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", function()
--   local win = hs.window.focusedWindow()
--   if win then win:moveToScreen(win:screen():next()) end
-- end)

-- hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left", function()
--   local win = hs.window.focusedWindow()
--   if win then win:moveToScreen(win:screen():previous()) end
-- end)

-- ------------------------------------------------------------MOUSE------------------------------------------------------------

-- Переместить курсор в центр активного (фокусного) окна
hs.hotkey.bind({"shift", "cmd"}, "X", function()
  local win = hs.window.focusedWindow()
  if not win then return end

  local frame = win:frame()
  local center = hs.geometry.point(
      frame.x + frame.w / 2,
      frame.y + frame.h / 2
  )

  hs.mouse.setAbsolutePosition(center)
end)


-- ---------------------------------------------------------------------------------------------------------------------------------------------

function powerStatusChanged()
  local newPowerState = updatePowerState()
  
  if newPowerState ~= isPluggedIn then
      isPluggedIn = newPowerState
  end
end

powerWatcher = hs.battery.watcher.new(powerStatusChanged)
powerWatcher:start()