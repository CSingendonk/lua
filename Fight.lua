-- Game entities
local player = {
    name = "Hero",
    hp = 100,
    max_hp = 100,
    max_magic = 100,
    attack = 10,
    magic = 20,
    xp = 0,
    level = 1,
    defending = false,
    inventory = {{name = "Mana Potion", type = "potion", magic = 20}, {name = "Health Potion",type = "potion", hp = 30} },
    equipped_weapon ={ name = "Sword", type = "weapon", attack = 15},
    equipped_armor = nil,
    equipped_accessory = nil
}
local enemies = {{
    name = "Goblin",
    hp = 50,
    max_hp = 50,
    attack = 8,
    xp_reward = 20,
    loot = {{    name = "Mana Potion",
    type = "potion",
    magic = 20}, {name = "Health Potion",type = "potion", hp = 30} }
}, {
    name = "Orc",
    hp = 80,
    max_hp = 80,
    attack = 12,
    xp_reward = 50,
    loot = {}
}, {
    name = "Troll",
    hp = 120,
    max_hp = 120,
    attack = 15,
    xp_reward = 100,
    loot = {}
}, {
    name = "Dragon",
    hp = 200,
    max_hp = 200,
    attack = 25,
    xp_reward = 200,
    loot = {}
}, {
    name = "Giant Spider",
    hp = 40,
    max_hp = 40,
    attack = 10,
    xp_reward = 15,
    loot = {}
}, {
    name = "Skeleton",
    hp = 30,
    max_hp = 30,
    attack = 5,
    xp_reward = 10,
    loot = {}
}, {
    name = "Zombie",
    hp = 25,
    max_hp = 25,
    attack = 7,
    xp_reward = 12,
    loot = {}
}, {
    name = "Witch",
    hp = 35,
    max_hp = 35,
    attack = 9,
    xp_reward = 18,
    loot = {}
}}

local weapons = {{
    name = "Sword",
    type = "weapon",
    attack = 15
}, {
    name = "Axe",
    type = "weapon",
    attack = 20
}, {
    name = "Dagger",
    type = "weapon",
    attack = 10
}, {
    name = "Mace",
    type = "weapon",
    attack = 18
}, {
    name = "Spear",
    type = "weapon",
    attack = 12
}}

local armors = {{
    name = "Leather Armor",
    type = "armor",
    defense = 5
}, {
    name = "Chainmail",
    type = "armor",
    defense = 10
}, {
    name = "Plate Armor",
    type = "armor",
    defense = 15
}, {
    name = "Shield",
    type = "armor",
    defense = 5
}, {
    name = "Helmet",
    type = "armor",
    defense = 3
}, {
    name = "Boots",
    type = "armor",
    defense = 2
}, {
    name = "Gloves",
    type = "armor",
    defense = 4
}, {
    name = "Cloak",
    type = "armor",
    defense = 8
}}

local accessories = {{
    name = "Amulet",
    type = "accessory",
    defense = 5,
    magic = 15
}, {
    name = "Ring",
    type = "accessory",
    defense = 3,
    magic = 10
}, {
    name = "Necklace",
    type = "accessory",
    defense = 4,
    magic = 12
}, {
    name = "Bracelet",
    type = "accessory",
    defense = 2,
    magic = 8
}, {
    name = "Pendant",
    type = "accessory",
    defense = 6,
    magic = 18
}, {
    name = "Crown",
    type = "accessory",
    defense = 10,
    magic = 20
}, {
    name = "Earrings",
    type = "accessory",
    defense = 2,
    magic = 6
}, {
    name = "Belt",
    type = "accessory",
    defense = 7,
    magic = 14
}}

local items = {{
    name = "Health Potion",
    type = "potion",
    hp = 30
}, {
    name = "Mana Potion",
    type = "potion",
    magic = 20
}, {
    name = "Elixir",
    type = "potion",
    hp = 50,
    magic = 30
}, {
    name = "Antidote",
    type = "potion",
    hp = -20,
    magic = -10
}, {
    name = "Poison",
    type = "potion",
    hp = -30,
    magic = -20
}, {
    name = "Cure",
    type = "potion",
    hp = 20,
    magic = 10
}, {
    name = "Smoke Bomb",
    type = "vail",
    hp = 0,
    magic = 0,
    defense = 100
}}

-- inventory management
local function lootNewWeapon(item)
    table.insert(player.inventory, item)
    message = "You picked up " .. item.name .. "!"
    if item.type == "weapon" then
        local _o = "Inventory!"
        local _i = "You have aquired a new weapon!\n" .. item.name .. "\nWhat will you do with it?"
        local _u = {
            "Wield the " .. item.name,
            "Store the " .. item.name .. " in my inventory",
            "Leave the " .. item.name .. " where I found it",
            escapebutton = 3,
            enterbutton = 2
        }

        local pressedbutton = love.window.showMessageBox(_o, _i, _u)
        if pressedbutton == 1 then
            player.inventory[#player.inventory + 1] = player.equipped_weapon
            player.equipped_weapon = nil
            player.equipped_weapon = item
            message = "You equipped the " .. item.name .. "!"

        elseif pressedbutton == 2 then
            player.inventory[#player.inventory + 1] = item
            message = "You stored the " .. item.name .. " in your inventory!"
        elseif pressedbutton == 3 then
            message = "You left the " .. item.name .. " where you found it."
        end
    end
end

local function lootNewArmor(item)
    table.insert(player.inventory, item)
    message = "You picked up " .. item.name .. "!"
    if item.type == "armor" then
    local _o = "Inventory!"
    local _i = "You have aquired a new armor!\n" .. item.name .. "\nWhat will you do with it?"
    local _u = {
        "Wear the " .. item.name,
        "Store the " .. item.name .. " in my inventory",
        "Leave the " .. item.name .. " where I found it",
        escapebutton = 3,
        enterbutton = 2
    }
    local pressedbutton = love.window.showMessageBox(_o, _i, _u)
    if pressedbutton == 1 then
    player.inventory[#player.inventory + 1] = player.equipped_armor
    player.equipped_armor = nil
    player.equipped_armor = item
    message = "You equipped the " .. item.name .. "!"
    elseif pressedbutton == 2 then
    player.inventory[#player.inventory + 1] = item
    message = "You stored the " .. item.name .. " in your inventory!"
    elseif pressedbutton == 3 then
    message = "You left the " .. item.name .. " where you found it."
    end
    end
end

local function lootNewAccessory(item)
    table.insert(player.inventory, item)
    message = "You picked up " .. item.name .. "!"
    if item.type == "accessory" then
    local _o = "Inventory!"
    local _i = "You have aquired a new accessory!\n" .. item.name .. "\nWhat will you do with it?"
    local _u = {
        "Wear the " .. item.name,
        "Store the " .. item.name .. " in my inventory",
        "Leave the " .. item.name .. " where I found it",
        escapebutton = 3,
        enterbutton = 2
    }
    local pressedbutton = love.window.showMessageBox(_o, _i, _u)
    if pressedbutton == 1 then
    player.inventory[#player.inventory + 1] = player.equipped_accessory
    player.equipped_accessory = nil
    player.equipped_accessory = item
    message = "You equipped the " .. item.name .. "!"
    elseif pressedbutton == 2 then
    player.inventory[#player.inventory + 1] = item
    message = "You stored the " .. item.name .. " in your inventory!"
    elseif pressedbutton == 3 then
    message = "You left the " .. item.name .. " where you found it."
    end
    end
end

local function lootNewItem(item)
    table.insert(player.inventory, item)
    message = "You picked up " .. item.name .. "!"
    if item.type == "potion" then
    local _o = "Inventory!"
    local _i = "You have aquired a new potion!\n" .. item.name .. "\nWhat will you do with it?"
    local _u = {
        "Drink the " .. item.name,
        "Store the " .. item.name .. " in my inventory",
        "Leave the " .. item.name .. " where I found it",
        escapebutton = 3,
        enterbutton = 2
    }
    local pressedbutton = love.window.showMessageBox(_o, _i, _u)
    if pressedbutton == 1 then
    player.hp = math.min(player.hp + item.hp, player.max_hp)
    player.magic = math.min(player.magic + item.magic, player.max_magic)
    message = "You drank the " .. item.name .. "!"
    elseif pressedbutton == 2 then
    player.inventory[#player.inventory + 1] = item
    message = "You stored the " .. item.name .. " in your inventory!"
    elseif pressedbutton == 3 then
    message = "You left the " .. item.name .. " where you found it."
    end
    end
    if item.type == "vail" then
    local _o = "Inventory!"
    local _i = "You have aquired a new item!\n" .. item.name .. "\nWhat will you do with it?"
    local _u = {
        "Use the " .. item.name,
        "Store the " .. item.name .. " in my inventory",
        "Leave the " .. item.name .. " where I found it",
        escapebutton = 3,
        enterbutton = 2
    }
    local pressedbutton = love.window.showMessageBox(_o, _i, _u)
    if pressedbutton == 1 then
    player.hp = math.min(player.hp + item.hp, player.max_hp)
    player.magic = math.min(player.magic + item.magic, player.max_magic)
    message = "You used the " .. item.name .. "!"
    elseif pressedbutton == 2 then
    player.inventory[#player.inventory + 1] = item
    message = "You stored the " .. item.name .. " in your inventory!"
    elseif pressedbutton == 3 then
    message = "You left the " .. item.name .. " where you found it."
    end
    end
    if item.type == "food" then
    local _o = "Inventory!"
    local _i = "You have aquired a new food!\n" .. item.name .. "\nWhat will you do with it?"
    local _u = {
        "Eat the " .. item.name,
        "Store the " .. item.name .. " in my inventory",
        "Leave the " .. item.name .. " where I found it",
        escapebutton = 3,
        enterbutton = 2
    }
    local pressedbutton = love.window.showMessageBox(_o, _i, _u)
    if pressedbutton == 1 then
    player.hp = math.min(player.hp + item.hp, player.max_hp)
    player.magic = math.min(player.magic + item.magic, player.max_magic)
    message = "You ate the " .. item.name .. " and restored " .. (item.hp and item.name) .. " HP and " .. item.magic .. " MP!"
    elseif pressedbutton == 2 then
        player.inventory[#player.inventory + 1] = item
         message = "You stored the " .. item.name .. " in your inventory!"
    elseif pressedbutton == 3 then
        message = "You left the " .. item.name .. " where you found it."
    end
    end
end

local function listItems()
    local _o = "Inventory"
    local _i = "Your inventory contains:\n\n"
    local _u = {}
    
    -- Create grid layout of inventory items
    for i, item in ipairs(player.inventory) do
        local itemInfo = item.name
        if item.type == "weapon" then
            itemInfo = itemInfo .. " (ATK +" .. item.attack .. ")"
        elseif item.type == "armor" then
            itemInfo = itemInfo .. " (DEF +" .. item.defense .. ")"
        elseif item.type == "food" or item.type == "vail" then
            itemInfo = itemInfo .. " (HP +" .. (item.hp or 0) .. ", MP +" .. (item.magic or 0) .. ")"
        end
        
        -- Add equip/unequip options for equipment
        if item.type == "weapon" or item.type == "armor" then
            if player.equipped and player.equipped[item.type] == item then
                table.insert(_u, "Unequip " .. itemInfo)
            else
                table.insert(_u, "Equip " .. itemInfo)
            end
        else
            table.insert(_u, "Use " .. itemInfo)
        end
    end
    
    -- Add cancel option
    table.insert(_u, "Close inventory")
    _u.escapebutton = #_u
    _u.enterbutton = 1
    
    -- Show inventory if not empty
    if #player.inventory > 0 then
        local pressedbutton = love.window.showMessageBox(_o, _i, _u)
        
        if pressedbutton ~= #_u then
            local selectedItem = player.inventory[pressedbutton]
            
            -- Handle equipment
            if selectedItem.type == "weapon" or selectedItem.type == "armor" then
                if player.equipped and player.equipped[selectedItem.type] == selectedItem then
                    -- Unequip
                    player.equipped[selectedItem.type] = nil
                    message = "Unequipped " .. selectedItem.name
                else
                    -- Equip
                    if not player.equipped then player.equipped = {} end
                    player.equipped[selectedItem.type] = selectedItem
                    message = "Equipped " .. selectedItem.name
                end
            -- Handle consumables
            elseif selectedItem.type == "potion" or selectedItem.type == "vail" then
                if selectedItem.hp then
                player.hp = math.min(player.hp + selectedItem.hp or 0, player.max_hp)
                elseif selectedItem.magic then
                player.magic = math.min(player.magic + selectedItem.magic or 0, player.max_magic)
                end
                table.remove(player.inventory, pressedbutton)
                message = "Used " .. selectedItem.name
            end
        end
    else
        love.window.showMessageBox("Inventory", "Your inventory is empty!", {"OK"})
    end
end

local function randomEnemyLoot()
    local enemy = enemies[currentEnemy]
    if enemy then
        enemy.loot = {}
        for i = 1, math.random(1, 3) do
            local item = loot[math.random(1, #loot)]
            enemy.loot[#enemy.loot + 1] = item
        end
    end
end

local function setEnemyLoot(loot)
    local enemy = enemies[currentEnemy]
    if enemy then
        if type(loot) == "table" then
            enemy.loot[#enemy.loot + 1] = loot            
    -- if loot argument is a table of items
        elseif table.unpack(loot) then
            for i in pairs(loot) do
    -- add each item to enemy loot table
                table.insert(enemy.loot, i)
            end
    -- if loot argument is a string then add the item with the name value of the string, or a random item if the string is "random" or ""
        elseif string.len(loot) then
            local item = loot
            if item == "random" or item == "" then
                randomEnemyLoot()
            elseif weapons[item] then
                enemy.loot[#enemy.loot + 1] = weapons[item]
            elseif armors[item] then
                enemy.loot[#enemy.loot + 1] = armors[item]
            elseif accessories[item] then
                enemy.loot[#enemy.loot + 1] = accessories[item]
            elseif items[item] then
                enemy.loot[#enemy.loot + 1] = items[item]
            end        
    end
    end
end




local currentEnemy = 1
local gameState = "player_turn"
local actionMenu = {"Attack", "Defend", "Magic", "Heal", "Items"}
local selectedAction = 1
local message = "Your turn! Choose an action."
local animations = {}

-- Utility functions
local function calculateDamage(attacker, defender)
    return math.max(attacker.attack - math.random(0, 3), 1)
end

local function drawHealthBar(x, y, width, height, current, max)
    local healthRatio = current / max
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0, 1, 0)
    if healthRatio < 1 then
        love.graphics.setColor(healthRatio, 1 * healthRatio, 0)
    end
    love.graphics.rectangle("fill", x, y, width * healthRatio, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
end

local function gainXP(amount)
    player.xp = player.xp + amount
    if player.xp >= player.level * 50 then
        player.xp = 0
        player.level = player.level + 1
        player.max_hp = player.max_hp + 20
        player.hp = player.max_hp
        message = "Level up! You reached level " .. player.level
    end
end

-- Animations
local function spawnAnimation(x, y, text, color)
    table.insert(animations, {
        x = x,
        y = y,
        text = text,
        color = color,
        time = 1
    })
end

local function updateAnimations(dt)
    for i = #animations, 1, -1 do
        local anim = animations[i]
        anim.time = anim.time - dt
        if anim.time <= 0 then
            table.remove(animations, i)
        end
    end
end

local function drawAnimations()
    for _, anim in ipairs(animations) do
        love.graphics.setColor(anim.color)
        love.graphics.printf(anim.text, anim.x, anim.y - (1 - anim.time) * 50, 200, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

-- Actions
local function playerAttack()
    local enemy = enemies[currentEnemy]
    local damage = calculateDamage(player, enemy)
    enemy.hp = math.max(enemy.hp - damage, 0)
    spawnAnimation(600, 200, "-" .. damage, {1, 0, 0})
    message = "You dealt " .. damage .. " damage!"
    player.defending = false
end

local function playerMagic()
    local enemy = enemies[currentEnemy]
    if player.magic >= 10 then
        player.magic = player.magic - 10
        local damage = 25
        enemy.hp = math.max(enemy.hp - damage, 0)
        spawnAnimation(600, 200, "-" .. damage .. " (Magic)", {0, 0, 1})
        message = "Magic attack dealt " .. damage .. " damage!"
    else
        message = "Not enough magic points!"
    end
end

local function playerHeal()
    if player.magic >= 15 then
        player.magic = player.magic - 15
        local heal = math.min(player.max_hp - player.hp, 30)
        player.hp = player.hp + heal
        spawnAnimation(200, 200, "+" .. heal, {0, 1, 0})
        message = "You healed " .. heal .. " HP!"
    else
        message = "Not enough magic points!"
    end
end

local function enemyAttack()
    local enemy = enemies[currentEnemy]
    local damage = calculateDamage(enemy, player)
    if player.defending then
        damage = math.floor(damage / 2)
    end
    player.hp = math.max(player.hp - damage, 0)
    spawnAnimation(200, 200, "-" .. damage, {1, 0, 0})
    message = enemy.name .. " dealt " .. damage .. " damage!"
end

local function lootNewItems()
    local enemy = enemies[currentEnemy]
    if enemy.loot and #enemy.loot > 0 then
        for _, item in ipairs(enemy.loot) do
            if  item.type == "weapon" then
                lootNewWeapon(item)
            elseif item.type == "armor" then
                lootNewArmor(item)
            elseif  item.type == "accessory" then
                lootNewAccessory(item)
            elseif  item.type == "potion" or item.type == "vail" then
                lootNewItem(item)
            end
        end
    end
    setEnemyLoot()
    message = "You found new items!"
end
            


-- Main Game Logic
local function checkBattleOutcome()
    if player.hp <= 0 then
        gameState = "end_game"
        message = "You were defeated. Game Over!"
    elseif enemies[currentEnemy].hp <= 0 then
        gainXP(enemies[currentEnemy].xp_reward)
        currentEnemy = currentEnemy + 1
        if currentEnemy > #enemies then
            gameState = "end_game"
            message = "You defeated all enemies! Victory!"
        else
            randomEnemyLoot()
            lootNewItems()
            player.inventory[#player.inventory + 1] = items[1]
            
            message = "A new enemy appears: " .. enemies[currentEnemy].name
        end
    end
end

function love.load()
    love.graphics.setFont(love.graphics.newFont(18))
end

function love.update(dt)
    updateAnimations(dt)
    if gameState == "enemy_turn" then
        love.timer.sleep(2)
        enemyAttack()
        gameState = "player_turn"
        checkBattleOutcome()
    end
end

function love.keypressed(key)
    if gameState == "player_turn" then
        if key == "up" then
            selectedAction = selectedAction == 1 and #actionMenu or selectedAction - 1
        elseif key == "down" then
            selectedAction = selectedAction == #actionMenu and 1 or selectedAction + 1
        elseif key == "return" or key == "space" then
            if actionMenu[selectedAction] == "Attack" then
                playerAttack()
                gameState = "enemy_turn"
            elseif actionMenu[selectedAction] == "Defend" then
                player.defending = true
                message = "You brace for the next attack!"
                gameState = "enemy_turn"
            elseif actionMenu[selectedAction] == "Magic" then
                playerMagic()
                gameState = "enemy_turn"
            elseif actionMenu[selectedAction] == "Heal" then
                playerHeal()
                gameState = "enemy_turn"
            elseif actionMenu[selectedAction] == "Items" then
                if #player.inventory > 0 then
                    listItems()
                    local item = player.inventory[1]
                    if item.type == "potion" then
                        if item.hp then
                        player.hp = math.min(player.hp + item.hp, player.max_hp)
                        message = "You used " .. item.name .. " and recovered " .. item.hp .. " HP!"
                        elseif item.magic then
                        player.magic = math.min(player.magic + item.magic, player.max_magic)
                        message = "You used " .. item.name .. " and recovered " .. item.magic .. " MP!"
                    end
                    elseif item.type == "damage" then
                        enemies[currentEnemy].hp = enemies[currentEnemy].hp - item.hp
                        message = "You used " .. item.name .. " and dealt " .. item.hp .. " damage!"
                    end
                    table.remove(player.inventory, 1)
                    gameState = "enemy_turn"
                else
                    message = "You have no items!"
                end
            elseif actionMenu[selectedAction] == "Run" then
                local escapeChance = math.random()
                if escapeChance > 0.5 then
                    gameState = "end_game"
                    message = "You successfully ran away!"
                else
                    message = "Couldn't escape!"
                    gameState = "enemy_turn"
                end
            end
            checkBattleOutcome()
        end
    elseif gameState == "end_game" and key == "return" then
        -- Restart the game
        player.hp = player.max_hp
        player.magic = 20
        player.xp = 0
        player.level = 1
        for _, enemy in ipairs(enemies) do
            enemy.hp = enemy.max_hp
        end
        currentEnemy = 1
        gameState = "player_turn"
        message = "Your turn! Choose an action."
    end
end

function love.draw()
    -- Player UI
    love.graphics.printf(player.name, 50, 50, 200, "center")
    drawHealthBar(50, 80, 200, 20, player.hp, player.max_hp)
    love.graphics.printf("HP: " .. player.hp .. "/" .. player.max_hp, 50, 110, 200, "center")
    love.graphics.printf("Magic: " .. player.magic, 50, 140, 200, "center")
    love.graphics.printf("XP: " .. player.xp, 50, 170, 200, "center")
    love.graphics.printf("Level: " .. player.level, 50, 200, 200, "center")
    -- Inventory
    love.graphics.printf("Inventory:", 50, 250, 200, "center")
    for i, item in ipairs(player.inventory) do
    love.graphics.printf(item.name, 50, 280 + (i - 1) * 30, 200, "center")
    end

    -- Enemy UI
    local enemy = enemies[currentEnemy]
    love.graphics.printf(enemy.name, 550, 50, 200, "center")
    drawHealthBar(550, 80, 200, 20, enemy.hp, enemy.max_hp)
    love.graphics.printf("HP: " .. enemy.hp .. "/" .. enemy.max_hp, 550, 110, 200, "center")
    -- loot
    randomEnemyLoot()
    setEnemyLoot(items[1])
    love.graphics.printf("Loot:", 550, 250, 200, "center")
    for i, item in ipairs(enemy.loot) do
    love.graphics.printf(item.name, 550, 280 + (i - 1) * 30, 200, "center")
    end

    -- Actions
    if gameState == "player_turn" then
        for i, action in ipairs(actionMenu) do
            if i == selectedAction then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(action, 0, 300 + (i - 1) * 30, 800, "center")
        end
    elseif gameState == "end_game" then
        love.graphics.printf("Press Enter to restart", 0, 400, 800, "center")
    end

    -- Message
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(message, 0, 250, 800, "center")

    -- Animations
    drawAnimations()
end
