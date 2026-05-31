-- Load the output data from the Python conversion
local imageData = require("output")

-- Configuration
local BUILD_MODE = "centered"  -- Options: "horizontal", "vertical", "centered", or "cube"
local BLOCK_SPACING = 3

-- Block ID to ItemType mapping
-- Note: Some blocks may not exist in ItemType - adjust as needed
local BLOCK_TYPES = {
    [1] = ItemType.STONE_BRICK,
    [2] = ItemType.OBSIDIAN,
    [3] = ItemType.WOOL_WHITE,
    [4] = ItemType.ANDESITE,
    [5] = ItemType.CLAY_RED,
    [6] = ItemType.FISHERMAN_CORAL, -- CORAL_BLOCK IN ORIGINAL CODE
    [7] = ItemType.WOOD_PLANK_OAK,
    [8] = ItemType.WOOD_PLANK_BIRCH,
    [9] = ItemType.WOOD_PLANK_SPRUCE,
    [10] = ItemType.DIAMOND_BLOCK,
    [11] = ItemType.SAND,
    [12] = ItemType.PURPLE_LUCKY_BLOCK, 
    [13] = ItemType.WOOL_RED,
    [14] = ItemType.WOOL_GREEN,
    [15] = ItemType.WOOL_YELLOW,
    [16] = ItemType.WOOL_BLUE,
    [17] = ItemType.WOOL_CYAN,
    [18] = ItemType.WOOL_PINK,
    [19] = ItemType.WOOL_ORANGE,
    [20] = ItemType.WOOL_PURPLE,
    [21] = ItemType.BLASTPROOF_CERAMIC, 
    [22] = ItemType.CLAY_BLACK,
    [23] = ItemType.CLAY_LIGHT_GREEN,
    [24] = ItemType.CLAY_TAN,
    [25] = ItemType.CLAY_WHITE,
    [26] = ItemType.LUCKY_BLOCK,
    [27] = ItemType.DIORITE,
    [28] = ItemType.CLAY_DARK_BROWN,
    [29] = ItemType.CLAY_BLUE,
    [30] = ItemType.ICE,
    [31] = ItemType.CLAY_DARK_GREEN,
    [32] = ItemType.CONCRETE_GREEN,
    [33] = ItemType.CLAY_PURPLE,
    [34] = ItemType.MARBLE_PILLAR,
    [35] = ItemType.CLAY,
    [36] = ItemType.MARBLE,
    [37] = ItemType.IRON_BLOCK,
    [38] = ItemType.SANDSTONE_SMOOTH,
    [39] = ItemType.RED_SAND
}

-- Debugging: Check for missing ItemType mappings
for blockId, blockType in pairs(BLOCK_TYPES) do
    if not blockType then
        print("Debug: Missing ItemType for block ID:", blockId)
    end
end

-- Build horizontally (along X and Z axis)
local function buildHorizontal(imageData, startPosition, blocksPlaced, blocksFailed)
    local height = #imageData
    local width = #imageData[1]
    
    print("Building horizontally: " .. width .. "x" .. height .. " pixel art...")
    
    -- Loop through each pixel in the image
    for z = 1, height do
        for x = 1, width do
            -- Get the block ID for this pixel
            local blockId = imageData[z][x]
            local blockType = BLOCK_TYPES[blockId]

            if blockType then
                -- Calculate position: start from player position, offset by X and Z
                local blockPosition = Vector3.new(
                    startPosition.X + (x - 1) * BLOCK_SPACING,
                    startPosition.Y,  -- Same Y level (no verticality)
                    startPosition.Z + (z - 1) * BLOCK_SPACING
                )

                -- Place the block
                local success = BlockService.placeBlock(blockType, blockPosition)
                if success then
                    blocksPlaced = blocksPlaced + 1
                else
                    blocksFailed = blocksFailed + 1
                end
            else
                print("Warning: Unknown block ID:", blockId)
                blocksFailed = blocksFailed + 1
            end
        end

        -- Progress update every 50 rows
        if z % 50 == 0 then
            MessageService.broadcast("Progress: " .. z .. "/" .. height .. " rows completed")
        end

        -- Delay after each row
        task.wait(0.1)
    end
    
    return blocksPlaced, blocksFailed
end

-- Build vertically (along X and Y axis)
local function buildVertical(imageData, startPosition, blocksPlaced, blocksFailed)
    local height = #imageData
    local width = #imageData[1]
    
    print("Building vertically: " .. width .. "x" .. height .. " pixel art...")
    
    -- Loop through each pixel in the image (start from bottom of array)
    for y = 1, height do
        for x = 1, width do
            -- Get the block ID for this pixel (read from bottom of array to fix upside-down issue)
            local arrayRow = height - y + 1  -- Flip the array reading order
            local blockId = imageData[arrayRow][x]
            local blockType = BLOCK_TYPES[blockId]

            if blockType then
                -- Calculate position: start from player position, offset by X and Y
                local blockPosition = Vector3.new(
                    startPosition.X + (x - 1) * BLOCK_SPACING,
                    startPosition.Y + (y - 1) * BLOCK_SPACING,  -- Y increases upward
                    startPosition.Z
                )

                -- Place the block
                local success = BlockService.placeBlock(blockType, blockPosition)
                if success then
                    blocksPlaced = blocksPlaced + 1
                else
                    blocksFailed = blocksFailed + 1
                end
            else
                print("Warning: Unknown block ID:", blockId)
                blocksFailed = blocksFailed + 1
            end
        end

        -- Progress update every 50 rows
        if y % 50 == 0 then
            MessageService.broadcast("Progress: " .. y .. "/" .. height .. " rows completed")
        end

        -- Delay after each row
        task.wait(0.1)
    end
    
    return blocksPlaced, blocksFailed
end

-- Build centered (horizontal with player at center)
local function buildCentered(imageData, startPosition, blocksPlaced, blocksFailed)
    local height = #imageData
    local width = #imageData[1]
    
    print("Building centered: " .. width .. "x" .. height .. " pixel art...")
    
    -- Calculate center offsets (player position becomes center of image)
    local centerX = math.floor(width / 2)
    local centerZ = math.floor(height / 2)
    
    -- Loop through each pixel in the image
    for z = 1, height do
        for x = 1, width do
            -- Get the block ID for this pixel
            local blockId = imageData[z][x]
            local blockType = BLOCK_TYPES[blockId]

            if blockType then
                -- Calculate position: center the image around player position
                local blockPosition = Vector3.new(
                    startPosition.X + (x - 1 - centerX) * BLOCK_SPACING,
                    startPosition.Y,  -- Same Y level (no verticality)
                    startPosition.Z + (z - 1 - centerZ) * BLOCK_SPACING
                )

                -- Place the block
                local success = BlockService.placeBlock(blockType, blockPosition)
                if success then
                    blocksPlaced = blocksPlaced + 1
                else
                    blocksFailed = blocksFailed + 1
                end
            else
                print("Warning: Unknown block ID:", blockId)
                blocksFailed = blocksFailed + 1
            end
        end

        -- Progress update every 50 rows
        if z % 50 == 0 then
            MessageService.broadcast("Progress: " .. z .. "/" .. height .. " rows completed")
        end

        -- Delay after each row
        task.wait(0.1)
    end
    
    return blocksPlaced, blocksFailed
end

-- Build cube (hollow cube with image on all 6 faces) - parallel construction
local function buildCube(imageData, startPosition, blocksPlaced, blocksFailed)
    local height = #imageData
    local width = #imageData[1]
    
    print("Building cube: " .. width .. "x" .. height .. " pixel art on each face (parallel)...")
    
    -- Calculate center offsets (player position becomes center of cube)
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)
    local centerZ = math.floor(height / 2)
    
    -- Shared counters (need to be careful with concurrent access)
    local totalPlaced = 0
    local totalFailed = 0
    local facesCompleted = 0
    
    -- Function to build bottom face
    local function buildBottomFace()
        local placed, failed = 0, 0
        for z = 1, height do
            for x = 1, width do
                local blockId = imageData[z][x]
                local blockType = BLOCK_TYPES[blockId]
                if blockType then
                    local blockPosition = Vector3.new(
                        startPosition.X + (x - 1 - centerX) * BLOCK_SPACING,
                        startPosition.Y,
                        startPosition.Z + (z - 1 - centerZ) * BLOCK_SPACING
                    )
                    local success = BlockService.placeBlock(blockType, blockPosition)
                    if success then placed = placed + 1 else failed = failed + 1 end
                end
            end
            if z % 100 == 0 then
                MessageService.broadcast("Bottom face: " .. z .. "/" .. height)
            end
            task.wait(0.1)
        end
        totalPlaced = totalPlaced + placed
        totalFailed = totalFailed + failed
        facesCompleted = facesCompleted + 1
        print("Bottom face complete!")
    end
    
    -- Function to build top face
    local function buildTopFace()
        local placed, failed = 0, 0
        for z = 1, height do
            for x = 1, width do
                local arrayRow = height - z + 1
                local blockId = imageData[arrayRow][x]
                local blockType = BLOCK_TYPES[blockId]
                if blockType then
                    local blockPosition = Vector3.new(
                        startPosition.X + (x - 1 - centerX) * BLOCK_SPACING,
                        startPosition.Y + (height - 1) * BLOCK_SPACING,
                        startPosition.Z + (z - 1 - centerZ) * BLOCK_SPACING
                    )
                    local success = BlockService.placeBlock(blockType, blockPosition)
                    if success then placed = placed + 1 else failed = failed + 1 end
                end
            end
            if z % 100 == 0 then
                MessageService.broadcast("Top face: " .. z .. "/" .. height)
            end
            task.wait(0.1)
        end
        totalPlaced = totalPlaced + placed
        totalFailed = totalFailed + failed
        facesCompleted = facesCompleted + 1
        print("Top face complete!")
    end
    
    -- Function to build front face
    local function buildFrontFace()
        local placed, failed = 0, 0
        for y = 1, height do
            for x = 1, width do
                local arrayRow = height - y + 1
                local blockId = imageData[arrayRow][x]
                local blockType = BLOCK_TYPES[blockId]
                if blockType then
                    local blockPosition = Vector3.new(
                        startPosition.X + (x - 1 - centerX) * BLOCK_SPACING,
                        startPosition.Y + (y - 1) * BLOCK_SPACING,
                        startPosition.Z - centerZ * BLOCK_SPACING
                    )
                    local success = BlockService.placeBlock(blockType, blockPosition)
                    if success then placed = placed + 1 else failed = failed + 1 end
                end
            end
            if y % 100 == 0 then
                MessageService.broadcast("Front face: " .. y .. "/" .. height)
            end
            task.wait(0.1)
        end
        totalPlaced = totalPlaced + placed
        totalFailed = totalFailed + failed
        facesCompleted = facesCompleted + 1
        print("Front face complete!")
    end
    
    -- Function to build back face
    local function buildBackFace()
        local placed, failed = 0, 0
        for y = 1, height do
            for x = 1, width do
                local arrayRow = height - y + 1
                local arrayCol = width - x + 1
                local blockId = imageData[arrayRow][arrayCol]
                local blockType = BLOCK_TYPES[blockId]
                if blockType then
                    local blockPosition = Vector3.new(
                        startPosition.X + (x - 1 - centerX) * BLOCK_SPACING,
                        startPosition.Y + (y - 1) * BLOCK_SPACING,
                        startPosition.Z + (height - 1 - centerZ) * BLOCK_SPACING
                    )
                    local success = BlockService.placeBlock(blockType, blockPosition)
                    if success then placed = placed + 1 else failed = failed + 1 end
                end
            end
            if y % 100 == 0 then
                MessageService.broadcast("Back face: " .. y .. "/" .. height)
            end
            task.wait(0.1)
        end
        totalPlaced = totalPlaced + placed
        totalFailed = totalFailed + failed
        facesCompleted = facesCompleted + 1
        print("Back face complete!")
    end
    
    -- Function to build left face
    local function buildLeftFace()
        local placed, failed = 0, 0
        for y = 1, height do
            for z = 1, height do
                local arrayRow = height - y + 1
                local blockId = imageData[arrayRow][z]
                local blockType = BLOCK_TYPES[blockId]
                if blockType then
                    local blockPosition = Vector3.new(
                        startPosition.X - centerX * BLOCK_SPACING,
                        startPosition.Y + (y - 1) * BLOCK_SPACING,
                        startPosition.Z + (z - 1 - centerZ) * BLOCK_SPACING
                    )
                    local success = BlockService.placeBlock(blockType, blockPosition)
                    if success then placed = placed + 1 else failed = failed + 1 end
                end
            end
            if y % 100 == 0 then
                MessageService.broadcast("Left face: " .. y .. "/" .. height)
            end
            task.wait(0.1)
        end
        totalPlaced = totalPlaced + placed
        totalFailed = totalFailed + failed
        facesCompleted = facesCompleted + 1
        print("Left face complete!")
    end
    
    -- Function to build right face
    local function buildRightFace()
        local placed, failed = 0, 0
        for y = 1, height do
            for z = 1, height do
                local arrayRow = height - y + 1
                local arrayCol = height - z + 1
                local blockId = imageData[arrayRow][arrayCol]
                local blockType = BLOCK_TYPES[blockId]
                if blockType then
                    local blockPosition = Vector3.new(
                        startPosition.X + (width - 1 - centerX) * BLOCK_SPACING,
                        startPosition.Y + (y - 1) * BLOCK_SPACING,
                        startPosition.Z + (z - 1 - centerZ) * BLOCK_SPACING
                    )
                    local success = BlockService.placeBlock(blockType, blockPosition)
                    if success then placed = placed + 1 else failed = failed + 1 end
                end
            end
            if y % 100 == 0 then
                MessageService.broadcast("Right face: " .. y .. "/" .. height)
            end
            task.wait(0.1)
        end
        totalPlaced = totalPlaced + placed
        totalFailed = totalFailed + failed
        facesCompleted = facesCompleted + 1
        print("Right face complete!")
    end
    
    -- Launch all 6 faces in parallel
    task.spawn(buildBottomFace)
    task.spawn(buildTopFace)
    task.spawn(buildFrontFace)
    task.spawn(buildBackFace)
    task.spawn(buildLeftFace)
    task.spawn(buildRightFace)
    
    -- Wait for all faces to complete
    while facesCompleted < 6 do
        task.wait(1)
        MessageService.broadcast("Cube progress: " .. facesCompleted .. "/6 faces completed")
    end
    
    return totalPlaced, totalFailed
end

-- Get all players
local players = PlayerService.getPlayers()
if #players == 0 then
    print("No players found!")
    return
end

MessageService.broadcast("Starting pixel art construction...")
task.wait(2)  -- Wait a few moments to ensure player entities are loaded

-- Get the first player's entity
local player = players[1]
local entity = player:getEntity()
if not entity then
    print("Player has no entity!")
    return
end

-- Get the player's position as the top-left corner
local startPosition = entity:getPosition()
print("Starting position:", startPosition)

-- Destroy the block under the player
local blockUnder = startPosition - Vector3.new(0, 5, 0)
BlockService.destroyBlock(blockUnder)
MessageService.broadcast("Destroyed block under player")

-- Build the pixel art
-- Each block is spaced by BLOCK_SPACING units
-- Horizontal mode: X direction = width (horizontal), Z direction = height (depth) - player at top-left
-- Vertical mode: X direction = width (horizontal), Y direction = height (vertical) - player at bottom-left
-- Centered mode: X direction = width (horizontal), Z direction = height (depth) - player at center
-- Cube mode: Hollow cube with image on all 6 faces - player at center

local height = #imageData  -- Number of rows
local width = #imageData[1]  -- Number of columns

print("Building " .. width .. "x" .. height .. " pixel art...")

local blocksPlaced = 0
local blocksFailed = 0

-- Choose build mode
if BUILD_MODE == "horizontal" then
    blocksPlaced, blocksFailed = buildHorizontal(imageData, startPosition, blocksPlaced, blocksFailed)
elseif BUILD_MODE == "vertical" then
    blocksPlaced, blocksFailed = buildVertical(imageData, startPosition, blocksPlaced, blocksFailed)
elseif BUILD_MODE == "centered" then
    blocksPlaced, blocksFailed = buildCentered(imageData, startPosition, blocksPlaced, blocksFailed)
elseif BUILD_MODE == "cube" then
    blocksPlaced, blocksFailed = buildCube(imageData, startPosition, blocksPlaced, blocksFailed)
else
    print("Error: Unknown build mode. Use 'horizontal', 'vertical', 'centered', or 'cube'")
    return
end

MessageService.broadcast("Pixel art construction complete!")
MessageService.broadcast("Blocks placed: " .. blocksPlaced)
MessageService.broadcast("Blocks failed: " .. blocksFailed)
MessageService.broadcast("Total dimensions: " .. width .. " blocks wide x " .. height .. " blocks deep")
MessageService.broadcast("Physical size: " .. (width * BLOCK_SPACING) .. " units x " .. (height * BLOCK_SPACING) .. " units")
