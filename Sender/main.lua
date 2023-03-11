constants = require ("constants")
objects = require ("objects")

os.loadAPI("json")  -- pastebin get 4nRg9CHU json

-- functions
function getKeyByNum(num)
  local keyNames = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
  local keyName = keyNames[num]
  if keyName then
      return keys[keyName]
  else
      return nil
  end
end

function lineText(text)
  return string.rep("-", math.floor(constants.SIZE[1]/2 - #text/2))..text..string.rep("-", math.ceil(constants.SIZE[1]/2 - #text/2))
end

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function generateControls(controls)
  local COLS = 4
  local ROWS = math.ceil(#controls/COLS)
  local XSPACING = math.floor(constants.SIZE[1]/(COLS+1))
  local YSPACING = math.floor(constants.SIZE[2]/(ROWS+1))
  local i=0
  for i, v in ipairs(controls) do
    local x = (i-1) % COLS + 1
    local y = math.floor((i-1) / COLS + 1)

    -- texts
    local id = table.shallow_copy(objects.Text):new(
      x*XSPACING, y*YSPACING,
      tostring(v[1]), colors.red, v[3], getKeyByNum(v[1])
    )
    local title = table.shallow_copy(objects.Text):new(
      x*XSPACING-math.floor(#v[2]/2), y*YSPACING+1,
      v[2]
    )

    -- insert
    controls[i] = {id, title}
  end
  return controls
end

function isQuit(event, quitElem) 
  if event[1] == "mouse_click" then
    local mx, my = event[3], event[4]
    if (mx > quitElem.x and mx < quitElem.x + #quitElem.text and my == quitElem.y) then  
      return true
    end
  elseif event[1] == "key" then
    local key = event[2]
    if key == keys.q then
      return true
    end
  end
  return false
end

function handleControl(obj, receiverID)
  rednet.open("back")

  local msg = {
    request = "control",
    action = "toggle",
  }
  rednet.send(receiverID, json.encode(msg), constants.PROTOCOL)

  senderID, msg = rednet.receive(constants.PROTOCOL, 1)
  if senderID == receiverID then
    msg = json.decode(msg)

    if msg.state then
      obj.bgColor = colors.green
    else
      obj.bgColor = colors.red
    end
  end

  rednet.close("back")
end

-- functions end


-- main loop
function draw(elems)
  term.clear()

  for i,v in ipairs(elems) do
    v:draw()
  end
end

function passwordMenu()  -- main menu
  term.setBackgroundColor(constants.BG_COLOR)

  local quitElem = table.shallow_copy(objects.Text):new(
    1, constants.SIZE[2], lineText(" Quit (Q) ")
  )

  local elems = {
    table.shallow_copy(objects.Text):new(
      1, 1,
      lineText(" " .. constants.TITLE .. " ")
    ),

    quitElem,

    table.shallow_copy(objects.Text):new(
      math.floor(constants.SIZE[1]/2 - 9/2), math.floor(constants.SIZE[2]/2 - 1),
      "Password:", nil, autoMenu, keys.one
    ),
  }

  draw(elems)
  local run = true
  while (run) do
    local event = { os.pullEvent() }
    if isQuit(event, quitElem) then
      run = false
      break
    end
    for k, v in pairs(elems) do
      v:handleEvents(event)
    end
    
    term.setCursorPos(math.floor(constants.SIZE[1]/2 - 9/2), math.floor(constants.SIZE[2]/2))
    local input = read("*")
    if input == constants.PASSWORD then
      run = false
      break
    end

    draw(elems)
    os.sleep(0.1)
  end
end

function mainMenu()  -- main menu
  term.setBackgroundColor(constants.BG_COLOR)
  passwordMenu()

  local quitElem = table.shallow_copy(objects.Text):new(
    1, constants.SIZE[2], lineText(" Quit (Q) ")
  )

  local elems = {
    table.shallow_copy(objects.Text):new(
      1, 1,
      lineText(" " .. constants.TITLE .. " ")
    ),

    quitElem,

    table.shallow_copy(objects.Text):new(
      math.floor(constants.SIZE[1]/2 - 8/2), math.floor(constants.SIZE[2]/2 - 1),
      "Auto (1)", nil, autoMenu, keys.one
    ),

    table.shallow_copy(objects.Text):new(
      math.floor(constants.SIZE[1]/2 - 12/2), math.floor(constants.SIZE[2]/2 + 1),
      "Control (2)", nil, controlMenu, keys.two
    ),
  }

  draw(elems)
  local run = true
  while (run) do
    local event = { os.pullEvent() }
    if isQuit(event, quitElem) then
      run = false
      break
    end
    for k, v in pairs(elems) do
      v:handleEvents(event)
    end

    draw(elems)
    os.sleep(0.1)
  end
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
end

function autoMenu()  -- auto menu
  term.setBackgroundColor(colors.gray)

  local distanceBar = table.shallow_copy(objects.Bar):new(
    math.floor(constants.SIZE[1]/2 - math.floor(constants.SIZE[1]/2)/2), math.floor(constants.SIZE[2]/2),
    math.floor(constants.SIZE[1]/2), 2,
    0
  )

  local quitElem = table.shallow_copy(objects.Text):new(
    1, constants.SIZE[2], lineText(" Quit (Q) ")
  )

  local elems = {
    table.shallow_copy(objects.Text):new(
      1, 1,
      lineText(" " .. constants.TITLE .. " (Auto) ")
    ),

    quitElem,

    distanceBar,
  }

  local distance = 0  -- distance to nearest computer
  distanceBar.percent = distance

  rednet.open("back")
  draw(elems)
  local run = true
  while (run) do
    -- os.queueEvent("dummy")
    local event = { os.pullEvent() }
    if isQuit(event, quitElem) then
      run = false
      break
    end
    for k, v in pairs(elems) do
      v:handleEvents(event)
    end

    draw(elems)
    os.sleep(0.1)
  end
  rednet.close("back")
end

function controlMenu()  -- control menu
  term.setBackgroundColor(colors.gray)

  local controls = {
    {1, "title", function (self) handleControl(self, 15) end},
  }
  controls = generateControls(controls)

  controlElems = {}
  for k, v in pairs(controls) do
    table.insert(controlElems, v[1])
    table.insert(controlElems, v[2])
  end

  local quitElem = table.shallow_copy(objects.Text):new(
    1, constants.SIZE[2], lineText(" Quit (Q) ")
  )

  local elems = {
    table.shallow_copy(objects.Text):new(
      1, 1,
      lineText(" " .. constants.TITLE .. " (Control) ")
    ),

    quitElem,

    unpack(controlElems),
  }

  draw(elems)
  local run = true
  while (run) do
    local event = { os.pullEvent() }
    if isQuit(event, quitElem) then
      run = false
      break
    end
    for k, v in pairs(elems) do
      v:handleEvents(event)
    end
    
    draw(elems)
    os.sleep(0.1)
  end
end


-- main loop end

mainMenu()