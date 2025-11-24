-- CONFIGURATION
-- Add your specific block names here
local t = 0
local linesScanned = 0

local colorMap = {
    ["minecraft:white_wool"] = "0",
    ["minecraft:black_wool"] = "1",
    ["minecraft:red_wool"]   = "2",
    ["minecraft:blue_wool"]  = "3",
    ["minecraft:yellow_wool"] = "4",
}

-- ... (go() function remains the same) ...
local function go()
    local success, message = turtle.forward()
    if success then
        t = t + 1
    end
    return success, message
end

-- ... (back() function is the modified version above) ...
local function back()
    -- 1. Turn 180 degrees
    turtle.turnRight()
    turtle.turnRight()

    -- 2. Travel back along the scanned line (t steps)
    for i = 1, t do
        turtle.forward()
    end

    -- 3. Turn 90 degrees to face the next line
    turtle.turnLeft()

    -- NOTE: We return the current 't' count so the turtle can move sideways
    -- The actual sideways move will be handled in the main loop.
    local current_t = t
    t = 0 -- Reset 't' for the new line
    linesScanned = linesScanned + 1 -- Increment the line counter
    return current_t
end


print("Starting Scan...")

-- NEW: Variable to track if the whole program should stop
local should_stop_program = false

while true do
    -- Check if a stop signal was raised from the previous line scan
    if should_stop_program then
        break -- Exit the main loop if signaled
    end

    -- 1. Scan the block below (Start of new line)
    local success, data = turtle.inspectDown()

    -- 2. Initial Stop Check: Invalid block found at the start of a line
    if not success or not data or not colorMap[data.name] then
        print("Invalid block found below new starting position: stopping scan.")
        break -- Exit the main loop
    end

    -- Print the color for the starting block
    local number = colorMap[data.name]
    print(number)

    -- LINE SCAN LOOP: Scans along the current line
    while true do

        -- 3. Move forward to the next block
        local move_success = go()

        -- 4. Check for End-of-Line Conditions
        local line_break_reason = nil -- nil, "wall", or "invalid_block"

        if not move_success then
            -- A. Turtle hit a WALL
            print("Path blocked! Starting return sequence.")
            line_break_reason = "wall"
        else
            -- B. Inspect the new block
            local scan_success, scan_data = turtle.inspectDown()

            if not scan_success or not scan_data or not colorMap[scan_data.name] then
                -- C. Found an invalid block mid-line
                print("Invalid block found mid-line. Starting return sequence.")
                line_break_reason = "invalid_block"
            else
                -- D. Move was successful, and the next block is valid. Continue scan.
                print(colorMap[scan_data.name])
                -- Continue the inner loop
            end
        end

        -- Execute End-of-Line Logic if a break reason was set
        if line_break_reason then
            back() -- Prepare the turtle (move back to the start side)

            -- Perform sideways move
            local sidemove_success = turtle.forward()

            if not sidemove_success then
                print("Cannot move sideways (Wall detected at edge). Stopping program.")
                should_stop_program = true -- Signal the outer loop to stop
            end

            turtle.turnLeft()
            break -- Breaks the inner 'while true do' line scan loop
        end
    end
end

print("Finished scanning. Total lines scanned: " .. linesScanned)
