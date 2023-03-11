constants = require ("../constants")


-- Bar Object
Bar = {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  percent = 0,
}

function Bar:new(x, y, w, h, percent)
  local new = {}
  setmetatable(new, {__index = self})
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.percent = percent
  return new
end

function Bar:draw()
  local v = math.floor(self.percent/100 * self.w)
  for y=self.y, self.y+self.h-1 do
    term.setCursorPos(self.x, y)
    term.setBackgroundColor(colors.lightGray)
    term.write(string.rep(" ", v))
    term.setBackgroundColor(colors.white)
    term.write(string.rep(" ", self.w - v))
  end
  term.setBackgroundColor(constants.BG_COLOR)
end

function Bar:handleEvents(event, args)
end

-- Bar Object end


-- Text Object
local Text = {
  x = 0,
  y = 0,
  text = "",
}

function Text:new(x, y, text, bgColor, func, key)
  local new = {}
  setmetatable(new, {__index = self})
  self.x = x
  self.y = y
  self.text = text
  self.bgColor = bgColor or constants.BG_COLOR
  self.func = func
  self.key = key
  return new
end

function Text:draw()
  term.setBackgroundColor(self.bgColor)
  term.setCursorPos(self.x, self.y)
  term.write(self.text)
  term.setBackgroundColor(constants.BG_COLOR)
end

function Text:handleEvents(event, args) 
  if event[1] == "mouse_click" then
    local mx, my = event[3], event[4]
    if (mx >= self.x and mx < self.x + #self.text and my == self.y) then
      self:callBack(args)
    end
  elseif event[1] == "key" then
    local key = event[2]
    if key == self.key then
      run = false
      if self.func then
        self:callBack(args)
      end
    end
  end

end

function Text:callBack(args)
  if self.func ~= nil then
    self:func(unpack(args or {}))
  end
end

-- Text Object end

local module = {}
module.Text = Text
module.Bar = Bar

return module