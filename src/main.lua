-- This script will run when the match starts.

-- Configuration
local imageName = "Muddy Rat's face" 

-- Listen for the MatchStart event
Events.MatchStart(function(event)
    -- Greet the user and provide instructions
    MessageService.broadcast("Welcome, we are about to build the image of " .. imageName .. " inside of Roblox Bedwars!")
    task.wait(1) -- Wait a second before the next message
    MessageService.broadcast("Prepare to shift into freecam by pressing shift + P!")
    task.wait(1) -- Wait a second before the next message
    MessageService.broadcast("Building will begin shortly...")
    task.wait(3) -- A few seconds for the player to get ready

    -- Announce that the build is starting
    MessageService.broadcast("Starting build for image: " .. imageName)

    -- Execute the build script
    require("build_image")
end)

print("main.lua loaded and waiting for match to start...")
