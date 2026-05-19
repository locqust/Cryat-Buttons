-- ============================================================
-- Crayt Buttons v1.0
-- Lua widget for FrSky ETHOS 1.6.x
-- For use with the Krayt control system on ESP32
-- ============================================================

local VERSION     = "1.0"
local WIDGET_KEY  = "CraytB"
local WIDGET_NAME = "Crayt Buttons"
local IMG_PATH    = "/scripts/Crayt Buttons/Images/"
local CFG_PATH    = "/scripts/Crayt Buttons/config/"

local LAYOUT = {
  cols=5, rows=3, marginX=4, marginY=4,
  gapX=4, gapY=4, statusH=36, radius=8, icoW=32,
}

-- ============================================================
-- FILE I/O  (colours + text - too large for storage)
-- ============================================================
local function cfgFile()
  return CFG_PATH .. model.name() .. ".txt"
end

local function loadFile(w)
  local f = io.open(cfgFile(), "r")
  if not f then return end
  local pc = f:read("*l")
  if pc then w.pressColor = tonumber(pc) or lcd.RGB(248,252,248) end
  for i = 1, 45 do
    local c = f:read("*l")
    local t = f:read("*l")
    if c == nil then break end
    w.btnColor[i] = tonumber(c) or lcd.RGB(160,160,160)
    w.btnText[i]  = t or ""
  end
  f:close()
end

local function saveFile(w)
  local f = io.open(cfgFile(), "w")
  if not f then return end
  f:write(tostring(w.pressColor or lcd.RGB(248,252,248)) .. "\n")
  for i = 1, 45 do
    f:write(tostring(w.btnColor[i] or lcd.RGB(160,160,160)) .. "\n")
    f:write((w.btnText[i] or "") .. "\n")
  end
  f:close()
end

-- ============================================================
-- CREATE
-- ============================================================
local function create()
  local w = {
    activeBank = 1,
    pressedBtn = 0,
    loaded     = false,
    wifiOn     = false,
    randomOn   = false,
    imuOn      = false,
    bankSource   = nil,
    wifiSource   = nil,
    randomSource = nil,
    imuSource    = nil,
    buttonSource = nil,   -- handle to Crayt Buttons Source LUA source
    pressColor = lcd.RGB(248, 252, 248),
    btnColor   = {},
    btnText    = {},
    img        = {},
  }
  for i = 1, 45 do
    w.btnColor[i] = lcd.RGB(160, 160, 160)
    w.btnText[i]  = ""
  end
  return w
end

-- ============================================================
-- BITMAPS
-- ============================================================
local function loadBitmaps(w)
  local function bmp(n) return lcd.loadBitmap(IMG_PATH..n) end
  w.img.wifion  = bmp("greenwifi.png")
  w.img.wifioff = bmp("redwifi.png")
  w.img.shuffle = bmp("shuffle.png")
  w.img.arrowlr = bmp("arrowlr.png")
  w.img.one     = bmp("one.png")
  w.img.two     = bmp("two.png")
  w.img.three   = bmp("three.png")
  w.img.imuon   = bmp("imuon.png")
  w.img.imuoff  = bmp("imuoff.png")
end

-- ============================================================
-- PAINT
-- ============================================================
local function paint(w)
  if not w.loaded then
    loadBitmaps(w)
    loadFile(w)
    -- Resolve button source here since read() may not be called
    w.buttonSource = system.getSource({name = "Crayt Buttons Source"})
    w.loaded = true
  end

  local winW, winH = lcd.getWindowSize()
  local L    = LAYOUT
  local sw   = winW - 2*L.marginX
  local sh   = winH - 2*L.marginY - L.statusH
  local btnW = math.floor((sw - (L.cols-1)*L.gapX) / L.cols)
  local btnH = math.floor((sh - (L.rows-1)*L.gapY) / L.rows)
  local r    = L.radius
  local off  = (w.activeBank-1)*15
  local idx  = 1

  for row = 1, L.rows do
    for col = 1, L.cols do
      local gi  = off + idx
      local x   = L.marginX + (col-1)*(btnW+L.gapX)
      local y   = L.marginY + (row-1)*(btnH+L.gapY)
      local clr = (w.pressedBtn==idx) and w.pressColor or w.btnColor[gi]
      if not clr then clr = lcd.RGB(160,160,160) end

      -- Draw rounded rectangle using lcd.color() then draw
      lcd.color(clr)
      lcd.drawFilledRectangle(x+r,   y,     btnW-2*r, btnH)
      lcd.drawFilledRectangle(x,     y+r,   btnW,     btnH-2*r)
      lcd.drawFilledCircle(x+r,      y+r,      r)
      lcd.drawFilledCircle(x+btnW-r, y+r,      r)
      lcd.drawFilledCircle(x+r,      y+btnH-r, r)
      lcd.drawFilledCircle(x+btnW-r, y+btnH-r, r)

      -- Label text - vertically centred in button
      local lbl = w.btnText[gi] or ""
      if lbl ~= "" then
        lcd.font(FONT_BOLD)
        lcd.color(WHITE)
        local sp = lbl:find(" ")
        if sp then
          -- Two rows: centre the pair vertically
          lcd.drawText(x+btnW/2, y+btnH/2-14, lbl:sub(1,sp-1), CENTERED)
          lcd.drawText(x+btnW/2, y+btnH/2+2,  lbl:sub(sp+1),   CENTERED)
        else
          -- Single row: centre vertically
          lcd.drawText(x+btnW/2, y+btnH/2-8, lbl, CENTERED)
        end
      end
      idx = idx+1
    end
  end

  -- Status bar
  local sy = winH - L.statusH
  local iw = L.icoW

  local wi = w.wifiOn and w.img.wifion or w.img.wifioff
  if wi then lcd.drawBitmap(L.marginX, sy+2, wi) end

  local ri = w.randomOn and w.img.shuffle or w.img.arrowlr
  if ri then lcd.drawBitmap(L.marginX+iw+6, sy+2, ri) end

  local ii = w.imuOn and w.img.imuon or w.img.imuoff
  if ii then lcd.drawBitmap(L.marginX+iw*2+12, sy+2, ii) end

  local bi = ({w.img.one, w.img.two, w.img.three})[w.activeBank]
  if bi then lcd.drawBitmap(winW-iw-L.marginX, sy+2, bi) end

  lcd.font(FONT_S)
  lcd.color(lcd.RGB(160,160,160))
  lcd.drawText(winW-iw-60, sy+10, "Crayt Buttons V"..VERSION, RIGHT)


end

-- ============================================================
-- WAKEUP
-- ============================================================
local function wakeup(w)
  local changed = false

  -- 3-pos switch: low=-100, mid=0, high=+100
  local bs = w.bankSource
  if bs then
    local sv = bs:value()
    if sv then
      local nb
      if sv > 50 then nb = 3
      elseif sv < -50 then nb = 1
      else nb = 2 end
      if nb ~= w.activeBank then w.activeBank = nb; changed = true end
    end
  end

  -- 2-pos toggles: -100=off, +100=on
  local function tog(src)
    if not src then return false end
    local v = src:value()
    return v ~= nil and v > 50
  end

  local nw = tog(w.wifiSource)
  local nr = tog(w.randomSource)
  local ni = tog(w.imuSource)

  if nw ~= w.wifiOn   then w.wifiOn   = nw; changed = true end
  if nr ~= w.randomOn then w.randomOn = nr; changed = true end
  if ni ~= w.imuOn    then w.imuOn    = ni; changed = true end

  if changed then lcd.invalidate() end
end

-- ============================================================
-- EVENT
-- return true consumes touch, stops ETHOS intercepting it
-- ============================================================
local function event(w, category, value, x, y)
  if category ~= EVT_TOUCH then return false end

  -- Touch release: clear pressed state and send resting value
  if value == 16641 then
    w.pressedBtn = 0
    if w.buttonSource then
      w.buttonSource:value(0)  -- 0 = centre = released (992 sBus)
    end
    lcd.invalidate()
    return true
  end

  -- Only act on touch down
  if value ~= 16640 then return true end

  local winW, winH = lcd.getWindowSize()
  local L    = LAYOUT
  local sw   = winW - 2*L.marginX
  local sh   = winH - 2*L.marginY - L.statusH
  local btnW = math.floor((sw - (L.cols-1)*L.gapX) / L.cols)
  local btnH = math.floor((sh - (L.rows-1)*L.gapY) / L.rows)
  local idx  = 1

  for row = 1, L.rows do
    for col = 1, L.cols do
      local bx = L.marginX + (col-1)*(btnW+L.gapX)
      local by = L.marginY + (row-1)*(btnH+L.gapY)
      if x >= bx and x <= bx+btnW and y >= by and y <= by+btnH then
        w.pressedBtn = idx
        system.playHaptic(100)
        -- Source values calibrated to match Kyberpad sBus spread (172-1195)
        -- Internal ETHOS scale is -1024 to +1024 (not -100 to +100)
        -- Released = 0 = sBus 992 (channel centre)
        local btnValues = {-1020,-935,-851,-766,-680,-595,-510,-426,-340,-255,-170,-85,84,169,254}
        if w.buttonSource and btnValues[idx] then
          w.buttonSource:value(btnValues[idx])
        end
        lcd.invalidate()
        return true
      end
      idx = idx+1
    end
  end

  w.pressedBtn = 0
  lcd.invalidate()
  return true
end

-- ============================================================
-- CONFIGURE
-- ============================================================
local function configure(w)
  local line

  line = form.addLine("Bank Toggle (3-pos)")
  form.addSourceField(line, nil,
    function() return w.bankSource end,
    function(v) w.bankSource = v end)

  line = form.addLine("WiFi Toggle")
  form.addSourceField(line, nil,
    function() return w.wifiSource end,
    function(v) w.wifiSource = v end)

  line = form.addLine("Random Toggle")
  form.addSourceField(line, nil,
    function() return w.randomSource end,
    function(v) w.randomSource = v end)

  line = form.addLine("IMU Toggle")
  form.addSourceField(line, nil,
    function() return w.imuSource end,
    function(v) w.imuSource = v end)

  line = form.addLine("Pressed Colour")
  form.addColorField(line, nil,
    function() return w.pressColor end,
    function(v) w.pressColor = v; saveFile(w) end)

  local banks = {"B1","B2","B3"}
  for b = 1, 3 do
    for i = 1, 15 do
      local gi = (b-1)*15 + i
      line = form.addLine(banks[b].." Btn "..i.." Name")
      form.addTextField(line, nil,
        function() return w.btnText[gi] end,
        function(v) w.btnText[gi] = v; saveFile(w) end)
      line = form.addLine(banks[b].." Btn "..i.." Colour")
      form.addColorField(line, nil,
        function() return w.btnColor[gi] end,
        function(v) w.btnColor[gi] = v; saveFile(w) end)
    end
  end
end
local function read(w)
  w.bankSource   = storage.read("bankSource")
  w.wifiSource   = storage.read("wifiSource")
  w.randomSource = storage.read("randomSource")
  w.imuSource    = storage.read("imuSource")
  -- Resolve the Crayt Buttons Source LUA source (same method as Kyberpad)
  w.buttonSource = system.getSource({name = "Crayt Buttons Source"})
  print("buttonSource resolved: "..tostring(w.buttonSource))
  loadFile(w)
end

local function write(w)
  storage.write("bankSource",   w.bankSource)
  storage.write("wifiSource",   w.wifiSource)
  storage.write("randomSource", w.randomSource)
  storage.write("imuSource",    w.imuSource)
  saveFile(w)
end

-- ============================================================
-- INIT
-- ============================================================
local function init()
  system.registerWidget({
    key        = WIDGET_KEY,
    name       = WIDGET_NAME,
    create     = create,
    paint      = paint,
    wakeup     = wakeup,
    event      = event,
    configure  = configure,
    read       = read,
    write      = write,
    persistent = true,
  })
end

return { init = init }
