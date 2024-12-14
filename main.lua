local Interface = require("Interface")
local textures = {
    tile = love.graphics.newImage("assets/tile.png"),
    background = love.graphics.newImage("assets/background.png"),
    glow = love.graphics.newImage("assets/glow.png")
}

local tileShader = love.graphics.newShader [[
    extern number time;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        float glow = abs(sin(time * 2.0)) * 0.3;
        return pixel * color * (1.0 + glow);
    }
]]



local menu = Interface.createMenu({
    {text = "Start Game", action = function() gameState = "play" end},
    {text = "Instructions", action = function() gameState = "instructions" end},
    {text = "Settings", action = function() gameState = "settings" end},
    {text = "Exit", action = function() love.event.quit() end}
})


local settingsMenu = Interface.createMenu({
    {text = "Music Volume", action = function() musicVolume = 0  end},
    {text = "Sound Volume", action = function() end},
    {text = "Color Theme", action = function() colorScheme = currentScheme  end},
    {text = "Exit", action = function() gameState = "menu" end}
})




local particles = love.graphics.newParticleSystem(love.graphics.newCanvas(4, 4), 1000)
local movingTile = {
    tile = nil,
    startX = 0,
    startY = 0,
    endX = 0,
    endY = 0,
    progress = 0
}
local transition = {
    active = false,
    alpha = 0,
    from = "",
    to = "",
    progress = 0
}

local sounds = {
    move = love.audio.newSource("sounds/move.mp3", "static"),
    win = love.audio.newSource("sounds/win.wav", "static"),
    bakground = love.audio.newSource("sounds/bakground.mp3", "stream"),
}



local menuTitle = Interface.new()
local menuOptions = {}
local selectedOption = 1 -- Tracks the currently highlighted menu option
local gameState = "menu" -- Can be "menu", "play", "pause", or "instructions"
local previousState = "menu"
    local tiles = {}

local pieces = {}
local mainTitle, movesDisplay, timeDisplay, winMessage
local grid, emptyTile, tileSize, moves, startTime, elapsedTime, gameWon
local tileColors = {} -- Store colors for each tile
local animationTimer = 0
local animationSpeed = 2 -- Animation speed multiplier
local highScores = {1, 10, 100, 1000}
local currentScore = 0
local scoreDisplay = Interface.new()
local highScoresDisplay = Interface.new()
local settingsDisplay = Interface.new()
local rulesetsDisplay = Interface.new()
local rulesetOptions = {}
local rulesetTitles = {}
local rulesetDescriptions = {}
local settingOptions = {}
local selectedSetting = 1
local musicVolume = 0
local settings = {
    musicVolume = 0,
    soundVolume = 0,
    sfxVolume = 0,
    animationSpeed = 1,
    rulesets = {"Classic", "TimeLimit", "NoRepeats", "NoRepeatsAndNoBackwards", "MoveLimit", "TimeAndMoveLimit"},
    currentRuleset = 1,
    showHighScores = true,
    colorSchemes = {
        classic = {
            bg = {r = 0.1, g = 0.1, b = 0.1, a = 1},
            piece = {r = 0.5, g = 0.5, b = 0.5, a = 0.75},
            words = {r = 1, g = 1, b = 1, a = 1},
            hilite = {r = 0, g = 0.9, b = 0.1, a = 1},
            name = "Classic"
        },
        ocean = {
            bg = {r = 0.1, g = 0.2, b = 0.3, a = 1},
            piece = {r = 0.4, g = 0.6, b = 0.8, a = 1},
            words = {r = 1, g = 1, b = 1, a = 1},
            hilite = {r = 0.9, g = 0.9, b = 0.2, a = 1},
            name = "Ocean"
        },
        forest = {
            bg = {r = 0.1, g = 0.2, b = 0.1, a = 1},
            piece = {r = 0.4, g = 0.6, b = 0.4, a = 1},
            words = {r = 1, g = 1, b = 1, a = 1},
            hilite = {r = 0.9, g = 0.9, b = 0.2, a = 1},
            name = "Forest"
        },
        sunset = {
            bg = {r = 0.2, g = 0.1, b = 0.2, a = 1},
            piece = {r = 0.8, g = 0.4, b = 0.6, a = 1},
            words = {r = 1, g = 1, b = 1, a = 1},
            hilite = {r = 0.9, g = 0.9, b = 0.2, a = 1},
            name = "Sunset"
        },
        neon = {
            bg = {r = 0, g = 1, b = 0.2, a = 1},
            piece = {r = 0.1, g = 0.1, b = 1, a = 1},
            words = {r = 1, g = 0, b = 0, a = 1},
            hilite = {r = 0.9, g = 0.9, b = 0.2, a = 0.4},
            name = "Neon"
        },
        mystery = {
            bg = {r = math.random(0.5, 1), g = math.random(0.5, 1), b = math.random(0.5, 1), a = 1},
            piece = {r = math.random(0.5, 1), g = math.random(0.5, 1), b = math.random(0.5, 1), a = 1},
            words = {r = math.random(0.5, 1), g = math.random(0.5, 1), b = math.random(0.5, 1), a = 1},
            hilite = {r = math.random(0.5, 1), g = math.random(0.5, 1), b = math.random(0.5, 1), a = 1},
            name = "Mystery"
        }
    },
    currentScheme = "mystery"
}

local schemes = {"classic", "ocean", "forest", "sunset", "neon", "mystery"}
local currentScheme = settings.colorSchemes[settings.currentScheme]
local backgroundColor = currentScheme.bg
local tileColor = currentScheme.piece
local textColor = currentScheme.words
local highlightColor = currentScheme.hilite
local image, quads, imageWidth, imageHeight


function updateColorScheme()    
    backgroundColor = currentScheme.bg
    tileColor = currentScheme.piece
    textColor = currentScheme.words
    highlightColor = currentScheme.hilite
    applyColors()
end

function applyColors()
    local bg = currentScheme.bg
    love.graphics.setBackgroundColor(bg.r, bg.g, bg.b, bg.a)
    tileColor = currentScheme.piece
    textColor = currentScheme.words
    highlightColor = currentScheme.hilite

    -- Update the colors of the menu options

end-- Add at the top with other variable declarations
local selectedSettingOption = 1

-- Add the updateVolumes function
function updateVolumes()
    -- Update both music and sound effect volumes
    setMusicVolume(settings.musicVolume)
    setSoundVolume(settings.soundVolume)

end

function setMusicVolume(volume)
    settings.musicVolume = math.max(0, math.min(1, volume))
    love.audio.setVolume(settings.musicVolume, "music")
    sounds.bakground:setVolume(settings.musicVolume)
end

function setSoundVolume(volume)
    settings.soundVolume = math.max(0, math.min(1, volume))
    sounds.move:setVolume(settings.soundVolume)
    sounds.win:setVolume(settings.soundVolume)
end
function setAnimationSpeed(speed)
    settings.animationSpeed = math.max(1, math.min(2, speed))
    animationSpeed = settings.animationSpeed
end

function setRuleset(rulesetIndex)
    settings.currentRuleset = math.max(1, math.min(#settings.rulesets, rulesetIndex))
end

function toggleHighScores()
    settings.showHighScores = not settings.showHighScores
end

function setColorScheme(schemeIndex)
    backgroundColor = schemeIndex.bg
    tileColor = schemeIndex.piece
    textColor = schemeIndex.words
    highlightColor = schemeIndex.hilite
    -- Update the tile colors in the tileColors table
    applyColors()

end

function getCurrentColorScheme()
    return settings.colorSchemes[settings.currentScheme]
end

function applySettings()
    setMusicVolume(settings.musicVolume)
    setSoundVolume(settings.soundVolume)
    setAnimationSpeed(settings.animationSpeed)
    setRuleset(settings.currentRuleset)
    updateColorScheme()
end -- Function to generate a random bright color
local function generateColor()
    local r = math.random(0.1, 1) -- Red component (0.5-1 for brighter colors)
    local g = math.random(0.1, 1) -- Green component
    local b = math.random(0.1, 1) -- Blue component
    local a = 1 -- Alpha (opacity)
    return {r, g, b, a}
end

-- Function to initialize the puzzle
local function initializePuzzle()

     image = love.graphics.newImage("image.png") -- Replace with your image path
    imageWidth, imageHeight = image:getDimensions()
    tileSize = imageWidth / 4
    -- Calculate window dimensions
    local gridWidth = 4 * tileSize
    local gridHeight = 4 * tileSize
    local uiWidth = 200 -- Approximate width for UI text and margins
    local uiHeight = 50 -- Approximate height for title and status display
    local margin = 10 -- Additional space around the grid and UI

    local windowWidth = gridWidth + uiWidth + (margin * 2)
    local windowHeight = gridHeight + (margin * 2) + uiHeight

    -- Get the screen dimensions
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    
    -- Cap the window size to fit the screen
    local scale = math.min(screenWidth / windowWidth, screenHeight / windowHeight)
    tileSize = tileSize * scale
    windowWidth = math.floor(windowWidth * scale)
    windowHeight = math.floor(windowHeight * scale)
    
    love.window.setMode(windowWidth, windowHeight, { resizable = true, centered = true })
    love.window.setTitle("Slider Puzzle Game")
    
    -- Recreate quads with the new tileSize if scaled
    quads = {}
    for i = 1, 15 do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        quads[i] = love.graphics.newQuad(
            col * tileSize,
            row * tileSize,
            tileSize,
            tileSize,
            imageWidth,
            imageHeight
        )
    end
    local tilesvis = function()
            -- Puzzle initialization logic
    grid = {}
    emptyTile = { row = 4, col = 4 }
    moves = 0
    gameWon = false
    startTime = love.timer.getTime()

    -- Create a grid with quads for the image
    for i = 1, 15 do table.insert(tiles, i) end

    local index = 1
    for row = 1, 4 do
        grid[row] = {}
        for col = 1, 4 do
            if not (row == 4 and col == 4) then
                grid[row][col] = tiles[index]
                index = index + 1
            else
                grid[row][col] = nil -- Empty tile
            end
        end
    end
    end
    
    tilesvis()
    -- Ensure puzzle is solvable by checking inversions
    local function isSolvable(tiles)
        local inversions = 0
        for i = 1, #tiles do
            for j = i + 1, #tiles do
                if tiles[i] > tiles[j] then
                    inversions = inversions + 1
                end
            end
        end
        return inversions % 2 == 0
    end

    -- Shuffle until we get a solvable configuration
    repeat
        shuffle(tiles)
    until isSolvable(tiles)

    local index = 1
    for row = 1, 4 do
        grid[row] = {}
        for col = 1, 4 do
            if not (row == 4 and col == 4) then
                grid[row][col] = tiles[index]
                index = index + 1
            else
                grid[row][col] = nil -- Empty tile
            end
        end
    end
end
-- Check if the puzzle is solved
function isPuzzleSolved()
    if (grid == nil) then
        return
    end
    local solvedGrid = {}
    local index = 1
    for row = 1, 4 do
        solvedGrid[row] = {}
        for col = 1, 4 do
            if row == 4 and col == 4 then
                solvedGrid[row][col] = nil -- Empty tile position
            else
                solvedGrid[row][col] = index
                index = index + 1
            end
        end
    end

    -- Compare the current grid with the solved grid
    for row = 1, 4 do
        for col = 1, 4 do
            if grid[row][col] ~= solvedGrid[row][col] then
                return false -- Puzzle is not solved
            end
        end
    end

    -- Create victory animation effect
    if gameWon then
        for i = 1, 15 do
            tileColors[i] = {1, 1, 0} -- Set all tiles to yellow for victory
        end
    end
    return true -- Puzzle is solved
end

-- Shuffle function to randomize the tile positions
function shuffle(t)
    if t == nil then
    return
    end
    local n = #t == nil or #t == 0
    if n then
    return
    end
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Update animation
function updateAnimation(dt)
    animationTimer = animationTimer + dt * animationSpeed
    -- Pulse effect for tiles
--[[     for i = 1, 15 do
        local pulse = math.abs(math.sin(animationTimer + i * 0.2))
        tileColors[i][1] = tileColors[i][1] * (0.8 + 0.2 * pulse)
        tileColors[i][2] = tileColors[i][2] * (0.8 + 0.2 * pulse)
        tileColors[i][3] = tileColors[i][3] * (0.8 + 0.2 * pulse)
    end ]]
            for row = 1, 4 do
            for col = 1, 4 do
                local x = (col - 1) * tileSize + 200
                local y = (row - 1) * tileSize + 50
                if grid[row][col] then
                    love.graphics.draw(image, quads[grid[row][col]], x, y)
                else
                    love.graphics.rectangle("line", x, y, tileSize, tileSize)
                end
            end
        end
end
-- Save game state to a file without using serpent
function saveGameState()
    local saveData = {
        grid = grid,
        emptyTile = emptyTile,
        moves = 0,
        startTime = startTime,
        gameWon = gameWon
    }


    -- Serialize the table into a string
    local serializedData = ""
    for key, value in pairs(saveData) do
        -- Convert table values to strings and concatenate them
        if type(value) == "table" then
            -- If the value is a table, serialize it manually
            serializedData = serializedData .. key .. "=" .. tableToString(value) .. "\n"
        else
            serializedData = serializedData .. key .. "=" .. tostring(value) .. "\n"
        end
    end

    -- Save the serialized string to a file
    -- love.filesystem.write("gameState.txt", serializedData)
end

-- Helper function to convert a table into a string
function tableToString(t)
    local result = "{"
    for k, v in pairs(t) do
        if type(v) == "table" then
            result = result .. k .. "=" .. tableToString(v) .. ","
        else
            result = result .. k .. "=" .. tostring(v) .. ","
        end
    end
    return result:sub(1, -2) .. "}" -- Remove trailing comma and add closing bracket
end

-- Load game state from a file
function loadGameState()
    local success, serializedData = true, nil -- pcall(, "gameState.txt")
    if not success then
        initializePuzzle()
        return
    end
    if 5 == 6 then
        local serializedData = "nil" -- love.filesystem.read("gameState.txt")

        -- Split the serialized string into lines
        local saveData = {}
        for line in serializedData:gmatch("[^\r\n]+") do
            local key, value = line:match("([^=]+)=([^=]+)")
            if key and value then
                -- If the value is a table, we'll need to parse it
                if value:sub(1, 1) == "{" then
                    saveData[key] = stringToTable(value)
                else
                    saveData[key] = tonumber(value) or value
                end
            end
        end

        -- Restore game state from loaded data
        grid = saveData.grid
        emptyTile = saveData.emptyTile
        moves = 0
        startTime = saveData.startTime
        gameWon = saveData.gameWon
    else
        initializePuzzle() -- Default to initializing a new puzzle if no save file exists
    end
end

-- Helper function to convert a string back into a table
function stringToTable(s)
    local tbl = {}
    local pattern = "(%w+)=(%d+)"
    for k, v in s:gmatch(pattern) do
        tbl[k] = tonumber(v)
    end
    return tbl
end

function saveSettings()
    -- Save all current settings to a file
    local data = ""
    data = data .. "musicVolume=" .. settings.musicVolume .. "\n"
    data = data .. "soundVolume=" .. settings.soundVolume .. "\n"
    data = data .. "animationSpeed=" .. settings.animationSpeed .. "\n"
    data = data .. "currentRuleset=" .. settings.currentRuleset .. "\n"
    data = data .. "currentScheme=" .. settings.currentScheme .. "\n"
    data = data .. "showHighScores=" .. tostring(settings.showHighScores) .. "\n"

   -- love.filesystem.write("settings.txt", data)
    applySettings()
end


local settingsOptions = { }
local colorOptions = {Interface.new(), Interface.new(), Interface.new(), Interface.new(), Interface.new(), Interface.new()}


-- Load the game
function love.load()
    local success, err = pcall(function()
        textures = {
            tile = love.graphics.newImage("assets/tile.png"),
            background = love.graphics.newImage("assets/background.png"),
            glow = love.graphics.newImage("assets/glow.png")
        }
    end)
    if not success then
        error("Failed to load textures: " .. tostring(err))
    end

    -- Load game state if it exists

    -- Main menu setup
    menuTitle = Interface.new()
    menuTitle:setPosition(100, 50)
    menuTitle:setText("15-Puzzle Game")
    menuTitle:setFontSize(24)

    menuOptions = {Interface.new(), Interface.new(), Interface.new(), Interface.new()}

    menuOptions[1]:setPosition(100, 100)
    menuOptions[1]:setText("Start Game")
    menuOptions[1]:setFontSize(18)

    menuOptions[2]:setPosition(100, 140)
    menuOptions[2]:setText("Instructions")
    menuOptions[2]:setFontSize(18)

    menuOptions[3]:setPosition(100, 180)
    menuOptions[3]:setText("Settings")
    menuOptions[3]:setFontSize(18)

    menuOptions[4]:setPosition(100, 220)
    menuOptions[4]:setText("Exit")
    menuOptions[4]:setFontSize(18)

    -- Settings menu setup
    settingsTitle = Interface.new()
    settingsTitle:setPosition(100, 50)
    settingsTitle:setText("Settings")
    settingsTitle:setFontSize(24)

    settingsOptions = {Interface.new(), Interface.new(), Interface.new(), Interface.new()}
    colorOptions = {Interface.new(), Interface.new(), Interface.new(), Interface.new(), Interface.new(), Interface.new()}
    local settingNames = { "musicVolume", "sfxVolume", "colorTheme", "Back"}

    
    for i, setting in pairs(settings) do
        if settingsOptions[i] == nil then
            settingsOptions[i] = Interface.new()
        end
    end
    for i = 1, #settingsOptions do
        settingsOptions[i]:setPosition(100, 100 + (i - 1) * 40)
        settingsOptions[i]:setText("Setting " .. settingNames[i])
        settingsOptions[i]:setFontSize(18)
        settingsOptions[i]:setDimensions(200, 30)
    end

    for i, color in ipairs(settings.colorSchemes) do
        colorOptions[i] = Interface.new()
    end

    for i = 1, #colorOptions do
        colorOptions[i]:setPosition(150, 100 + (i - 1) * 40)
        colorOptions[i]:setText(schemes[i])
        colorOptions[i]:setFontSize(18)

        if currentScheme.name == schemes[i] then
            local color = currentScheme
            colorOptions[i]:setBackgroundColor(color.bg.r, color.bg.g, color.bg.b, 0.5)
            colorOptions[i]:setBorderColor(color.hilite.r, color.hilite.g, color.hilite.b)
            colorOptions[i]:setColor(color.words.r, color.words.g, color.words.b)
            colorOptions[i]:render()
        end
    end


    -- Gameplay UI setup
    mainTitle = Interface.new()
    movesDisplay = Interface.new()
    timeDisplay = Interface.new()
    winMessage = Interface.new()

    mainTitle:setPosition(50, 20)
    mainTitle:setText("15-Puzzle Game")
    mainTitle:setFontSize(20)
    if not moves then
        moves = 0
    end
    movesDisplay:setPosition(50, 70)
    movesDisplay:setText("Moves: " .. moves .. "0")
    movesDisplay:setFontSize(16)

    timeDisplay:setPosition(50, 100)
    timeDisplay:setText("Time: 0.00s")
    timeDisplay:setFontSize(16)

    winMessage:setPosition(50, 150)
    winMessage:setText("")
    winMessage:setFontSize(16)

    particles:setParticleLifetime(0.5, 2)
    particles:setLinearAcceleration(-50, -50, 50, 50)
    particles:setColors(1, 1, 0, 1, 1, 0.5, 0, 0)
    particles:setSizes(2, 0.5)

    scoreDisplay:setPosition(200, 15)
    scoreDisplay:setFontSize(16)
    scoreDisplay:setColor(0,1,0,1)
    loadHighScores()
end
-- Initialize high scores table
highScores = {0, 0, 0, 0, 0}

function calculateScore()
    local maxScore = 10000

    -- Lower time and moves = higher score
    local timeBonus = math.max(0, maxScore - math.floor(elapsedTime * 10))
    local moveBonus = math.max(0, maxScore - moves * 10)
    return timeBonus + moveBonus
end

function saveHighScores()
    local data = ""
    for i, score in ipairs(highScores) do
        data = data .. tostring(score) .. "\n"
    end
   -- love.filesystem.write("highscores.txt", data)
end

function loadHighScores()
    if 5 == 6 then
        local data = nil -- love.filesystem.read("highscores.txt")
        for score in data:gmatch("[^\r\n]+") do
            table.insert(highScores, tonumber(score))
        end
        table.sort(highScores, function(a, b)
            return a > b
        end)
    end
end

function updateHighScores(newScore)
    table.insert(highScores, newScore)
    table.sort(highScores, function(a, b)
        return a > b
    end)
    if #highScores > 5 then
        table.remove(highScores, #highScores)
    end
    saveHighScores()
end

function love.draw()
    -- Draw background with parallax
    love.graphics.setColor(1, 1, 1, 1)
    local bgScale = love.graphics.getHeight() / textures.background:getHeight()
    local bgOffset = love.timer.getTime() * 20
    love.graphics.draw(textures.background, -bgOffset % (textures.background:getWidth() * bgScale), 0, 0, bgScale,
        bgScale)
    love.graphics.draw(textures.background, (-bgOffset % (textures.background:getWidth() * bgScale)) +
        textures.background:getWidth() * bgScale, 0, 0, bgScale, bgScale)
    local cS = currentScheme
    local bg = currentScheme.bg
    local tc = currentScheme.words
    local pc = currentScheme.piece
    local hc = currentScheme.hilite

    if gameState == "menu" then
        -- Add menu background
        love.graphics.setColor(bg.r, bg.g, bg.b, bg.a)
        love.graphics.rectangle("fill", 80, 30, 1024, 1024)

        menuTitle:render()
        for i, option in ipairs(menuOptions) do
            if i == selectedOption then
                local pulse = math.abs(math.sin(love.timer.getTime() * 3))
                option:setColor(0.3 + pulse * 0.7, 1, 0.3 + pulse * 0.7)
            else
                option:setColor(tc.r, tc.g, tc.b)
            end
            option:render()
        end
    elseif gameState == "settings" then
        -- Add settings background
        love.graphics.setColor(bg.r, bg.g, bg.b, bg.a)
        love.graphics.rectangle("fill", 80, 30, 1024, 1024)

        settingsTitle:render()
        for i, option in ipairs(settingsOptions) do
            if i == selectedSetting then
                local pulse = math.abs(math.sin(love.timer.getTime() * 3))
                option:setColor(0.3 + pulse * 0.7, 1, 0.3 + pulse * 0.7)
            else
                option:setColor(tc.r, tc.g, tc.b)
            end
            option:render()
        end    
    elseif gameState == "play" then
        -- Render gameplay UI
        mainTitle:render()
        movesDisplay:render()
        timeDisplay:render()
        winMessage:render()
        scoreDisplay:render()

        -- Draw particles
        love.graphics.draw(particles, 0, 0)

        -- Render the grid with enhanced tiles
        for row = 1, 4 do
            for col = 1, 4 do
                local x = (col - 1) * tileSize + 200
                local y = (row - 1) * tileSize + 50
                if grid[row][col] then
                    love.graphics.setShader(tileShader)
                    love.graphics.setColor(currentScheme.piece.r, currentScheme.piece.g, currentScheme.piece.b, 0.75)
                    love.graphics.draw(textures.tile, x, y, 0, tileSize / textures.tile:getWidth(),
                        tileSize / textures.tile:getHeight())

                    love.graphics.setColor(currentScheme.hilite.r, currentScheme.hilite.g, currentScheme.hilite.b, 0.25)
                    love.graphics.draw(textures.glow, x - 5, y - 5, 0, (tileSize + 10) / textures.glow:getWidth(),
                        (tileSize + 10) / textures.glow:getHeight())

                    love.graphics.setShader()
                    love.graphics.setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
                    love.graphics.printf(tostring(grid[row][col]), x, y + (tileSize / 2) - 10, tileSize, "center")
                end
            end
        end

        -- Draw moving tile
        if movingTile.tile then
            local x = ((1 - movingTile.progress) * movingTile.startX) + (movingTile.progress * movingTile.endX)
            local y = ((1 - movingTile.progress) * movingTile.startY) + (movingTile.progress * movingTile.endY)

            love.graphics.setShader(tileShader)
            tileShader:send('time', love.timer.getTime())

            love.graphics.draw(textures.tile, x, y, 0, tileSize / textures.tile:getWidth(),
                tileSize / textures.tile:getHeight())

            love.graphics.setColor(currentScheme.hilite.r, currentScheme.hilite.g, currentScheme.hilite.b, 0.1)
            love.graphics.draw(textures.glow, x - 5, y - 5, 0, (tileSize + 10) / textures.glow:getWidth(),
                (tileSize + 10) / textures.glow:getHeight())

            love.graphics.setShader()
            love.graphics.setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
            love.graphics.printf(tostring(movingTile.tile), x, y + (tileSize / 2) - 10, tileSize, "center")
            movingTile.progress = movingTile.progress + 0.02
            if movingTile.progress >= 1 then
            movingTile.tile = nil
            end
        end
    elseif gameState == "instructions" then
        love.graphics.setColor(currentScheme.bg.r, currentScheme.bg.g, currentScheme.bg.b)
        love.graphics.rectangle("fill", 80, 30, 500, 300)

        love.graphics.setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
        love.graphics.print("Instructions:", 100, 50)
        love.graphics.print("• Use arrow keys to move tiles", 100, 100)
        love.graphics.print("• Press 'R' to randomly shuffle the tiles", 100, 145)
        love.graphics.print("• Press 'S' to save the game", 100, 190)
        love.graphics.print("• Press 'ESC' to quit the game", 100, 235)
        love.graphics.print("Press ENTER to return to menu", 150, 280)
    end

    if transition.active then
        love.graphics.setColor(0, 0, 0, transition.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

end

function love.update(dt)
    if gameState == "pause" then
        return
    end
    if gameState == "play" then
        if grid then
            elapsedTime = love.timer.getTime() - startTime
            timeDisplay:setText(string.format("Time: %.2fs", elapsedTime))
            scoreDisplay:setText(string.format("Score: %d", calculateScore()))

            -- Update particle system
            particles:update(dt)

            -- Update tile movement animation

            if gameWon then
                    local _o = "Game Over!"
local _i = "You won! Play again?"
local _u = {"OK", "No!", "Help", escapebutton = 2}

local pressedbutton = love.window.showMessageBox(_o, _i, _u)
if pressedbutton == 1 then
    movingTile.tile = nil
    movingTile.startX = movingTile.endX
    movingTile.startY = movingTile.endY
    movingTile.progress = 0
    shuffle(grid);
elseif pressedbutton == 2 then
    love.event.quit()
elseif pressedbutton == 3 then
    startTransition("play", "instructions")
    end
    -- Update tile hover effects
            local mx, my = love.mouse.getPosition()
            for row = 1, 4 do
                for col = 1, 4 do
                    local x = (col - 1) * tileSize + 200
                    local y = (row - 1) * tileSize + 50
--[[                    if grid[row][col] and mx >= x and mx < x + tileSize and my >= y and my < y + tileSize then
                        tileColors[grid[row][col]]-- = {math.min(1, tileColors[grid[row][col]][1] * 1.2),
                                                      -- math.min(1, tileColors[grid[row][col]][2] * 1.2),
                                                     --  math.min(1, tileColors[grid[row][col]][3] * 1.2)}
                                                     --[[
                                                     ]]
                        
                        if love.mouse.isDown(1) and not movingTile.tile then
                            -- Find empty tile position
                            local emptyRow, emptyCol
                            for r = 1, 4 do
                                for c = 1, 4 do
                                    if not grid[r][c] then
                                        emptyRow, emptyCol = r, c
                                        break
                                    end
                                end
                                if emptyRow then break end
                            end
                            
                            -- Check if clicked tile is adjacent to empty tile
                            if (math.abs(row - emptyRow) == 1 and col == emptyCol) or
                               (math.abs(col - emptyCol) == 1 and row == emptyRow) then
                                -- Swap tiles
                                movingTile.tile = grid[row][col]
                                movingTile.startX = x
                                movingTile.startY = y
                                movingTile.endX = (emptyCol - 1) * tileSize + 200
                                movingTile.endY = (emptyRow - 1) * tileSize + 50
                                movingTile.progress = 0
                                grid[row][col], grid[emptyRow][emptyCol] = grid[emptyRow][emptyCol], grid[row][col]
                                sounds.move:play()
                            end
                        end
                    end
                end

            end
            -- Update tile colors animation
            for i = 1, 15 do
                if not gameWon then
                    local pulse = math.abs(math.sin(love.timer.getTime() + i * 0.3))
--[[                     tileColors[i] = {math.min(1, tileColors[i][1] * (0.9 + 0.1 * pulse)),
                                     math.min(1, tileColors[i][2] * (0.9 + 0.1 * pulse)),
                                     math.min(1, tileColors[i][3] * (0.9 + 0.1 * pulse))} ]]
                end
            end

            -- Check win condition
            if isPuzzleSolved() and not gameWon then
                gameWon = true
                particles:emit(500)
                sounds.win:play()
                local finalScore = calculateScore()
                updateHighScores(finalScore)
                winMessage:setText(string.format("Congratulations! Score: %d", finalScore))
            end
        end
    end

    if transition.active then
        transition.progress = transition.progress + dt * 2
        transition.alpha = math.sin(transition.progress * math.pi)

        if transition.progress >= 1 then
            gameState = transition.to
            transition.active = false
        end
    end
end
function startTransition(from, to)
    previousState = from
    transition.active = true
    transition.alpha = 0
    transition.from = from
    transition.to = to
    transition.progress = 0
end

function updateTileMovement(dt)
    if movingTile.tile then
        movingTile.progress = movingTile.progress + dt * 5
        if movingTile.progress >= 1 then
            movingTile.tile = nil
            movingTile.progress = 0
        end
        return true
    end
    return false
end

-- Handle key presses for menu and gameplay
local priorState = nil
local currentIndex = 1


function love.keypressed(key)

    if priorState == nil then
        priorState = gameState
        priorSelectedOption = selectedOption
    end
    if gameState == "menu" then
        if key == "escape" then
            love.event.quit();
        end
        if key == "up" then
            selectedOption = selectedOption > 1 and selectedOption - 1 or #menuOptions
        elseif key == "down" then
            selectedOption = selectedOption < #menuOptions and selectedOption + 1 or 1
        elseif key == "return" then
            if selectedOption == 1 then
                startTransition("menu", "play")
                initializePuzzle()
            elseif selectedOption == 2 then
                startTransition("menu", "instructions")
            elseif selectedOption == 3 then
                startTransition("menu", "settings")
            elseif selectedOption == 4 then
                love.event.quit()
            end
        end
    elseif gameState == "instructions" then
        if key == "return" then
            startTransition("instructions", "menu")
        elseif key == "escape" then
            startTransition("instructions", "menu")
        end
    elseif gameState == "settings" then
        if key == "up" then
            settingsOptions[selectedOption]:setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
            selectedOption = selectedOption > 1 and selectedOption - 1 or selectedOption
            settingsOptions[selectedOption]:setColor(currentScheme.hilite.r, currentScheme.hilite.g, currentScheme.hilite.b)

        elseif key == "down" then
            settingsOptions[selectedOption]:setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
            selectedOption = selectedOption < #settingsOptions and selectedOption + 1 or 1
            settingsOptions[selectedOption]:setColor(currentScheme.hilite.r, currentScheme.hilite.g, currentScheme.hilite.b)
        elseif key == "left" or key == "right" then
            if selectedOption == 1 then -- Music Volume
                settings.musicVolume = key == "left" and math.max(0, settings.musicVolume - 0.1) or
                                           math.min(1, settings.musicVolume + 0.1)
                settingsOptions[selectedOption]:setText(string.format("Music Volume: %.1f", settings.musicVolume))

            elseif selectedOption == 2 then -- SFX Volume
                settings.sfxVolume = key == "left" and math.max(0, settings.sfxVolume - 0.1) or
                                         math.min(1, settings.sfxVolume + 0.1)
                settingsOptions[selectedOption]:setText(string.format("SFX Volume: %.1f", settings.sfxVolume))
            elseif selectedOption == 3 then -- Color Scheme
                for i = 1, #schemes do
                    local scheme = settings.colorSchemes[schemes[i]]
                    if scheme == currentScheme.name then
                        currentIndex = i
                        break
                    end
                end
                if key == "left" then
                    currentIndex = currentIndex - 1
                    if currentIndex < 1 then
                        currentIndex = #schemes
                    end
                elseif key == "right" then
                    currentIndex = currentIndex + 1
                    if currentIndex > #schemes then
                        currentIndex = 1
                    end
                end
                currentScheme = settings.colorSchemes[schemes[currentIndex]]
                settingsOptions[selectedOption]:setText(string.format("Color = " .. currentScheme.name))
                settingsOptions[selectedOption]:setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
                setColorScheme(settings.colorSchemes[schemes[currentIndex]])
            end
        elseif key == "return" or key == "escape" then
                love.graphics.setBackgroundColor(currentScheme.bg.r, currentScheme.bg.g, currentScheme.bg.b)
                love.graphics.setColor(currentScheme.words.r, currentScheme.words.g, currentScheme.words.b)
                settings.currentScheme = currentScheme.name
                saveSettings()
                startTransition("settings", "menu")
        end
    elseif gameState == "play" then
        if key == "return" then
            startTransition("play", previousState)
        end
        if key == "escape" then
            startTransition("play", "menu")
        end
        if key == "up" or key == "down" or key == "left" or key == "right" then
            local newRow, newCol = emptyTile.row, emptyTile.col

            if key == "down" then
                newRow = newRow + 1
            end
            if key == "up" then
                newRow = newRow - 1
            end
            if key == "right" then
                newCol = newCol + 1
            end
            if key == "left" then
                newCol = newCol - 1
            end

            if newRow >= 1 and newRow <= 4 and newCol >= 1 and newCol <= 4 then
                movingTile = {
                    tile = grid[newRow][newCol],
                    startX = (newCol - 1) * tileSize + 200,
                    startY = (newRow - 1) * tileSize + 50,
                    endX = (emptyTile.col - 1) * tileSize + 200,
                    endY = (emptyTile.row - 1) * tileSize + 50,
                    progress = 0
                }

                grid[emptyTile.row][emptyTile.col], grid[newRow][newCol] = grid[newRow][newCol],
                    grid[emptyTile.row][emptyTile.col]
                emptyTile.row, emptyTile.col = newRow, newCol

                moves = moves + 1
                movesDisplay:setText("Moves: " .. moves)
                sounds.move:play()
            end
        end
        if key == "s" then
            saveGameState()
        end
        if key == "r" then
            initializePuzzle()
        end
    end
end

function love.quit()
    particles:release()
    for _, sound in pairs(sounds) do
        sound:release()
    end
    if tileShader then
        tileShader:release()
    end
end
 