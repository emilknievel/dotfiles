PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({
    -- switch to a new focused window in tiled grid
    focus_left  = {{"alt"}, "h"},
    focus_right = {{"alt"}, "l"},
    focus_up    = {{"alt"}, "k"},
    focus_down  = {{"alt"}, "j"},

    -- move windows around in tiled grid
    swap_left  = {{"alt", "shift"}, "h"},
    swap_right = {{"alt", "shift"}, "l"},
    swap_up    = {{"alt", "shift"}, "k"},
    swap_down  = {{"alt", "shift"}, "j"},

    -- position and resize focused window
    center_window        = {{"alt"}, "c"},
    full_width           = {{"alt"}, "f"},
    cycle_width          = {{"alt"}, "r"},
    -- reverse_cycle_width  = {{"ctrl", "alt", "cmd"}, "r"},
    cycle_height         = {{"alt", "shift"}, "r"},
    -- reverse_cycle_height = {{"ctrl", "alt", "cmd", "shift"}, "r"},

    -- increase/decrease width
    increase_width = {{"alt"}, "="},
    decrease_width = {{"alt"}, "-"},

    -- move focused window into / out of a column
    slurp_in = {{"alt"}, "i"},
    barf_out = {{"alt"}, "o"},

    -- move the focused window into / out of the tiling layer
    toggle_floating = {{"alt"}, "s"}, -- (scratch)

    -- focus the first / second / etc window in the current space
    focus_window_1 = {{"alt"}, "1"},
    focus_window_2 = {{"alt"}, "2"},
    focus_window_3 = {{"alt"}, "3"},
    focus_window_4 = {{"alt"}, "4"},
    focus_window_5 = {{"alt"}, "5"},
    focus_window_6 = {{"alt"}, "6"},
    focus_window_7 = {{"alt"}, "7"},
    focus_window_8 = {{"alt"}, "8"},
    focus_window_9 = {{"alt"}, "9"},

    -- switch to a new Mission Control space
    switch_space_l = {{"alt", "cmd"}, ","},
    switch_space_r = {{"alt", "cmd"}, "."},
    switch_space_1 = {{"alt", "cmd"}, "1"},
    switch_space_2 = {{"alt", "cmd"}, "2"},
    switch_space_3 = {{"alt", "cmd"}, "3"},
    switch_space_4 = {{"alt", "cmd"}, "4"},
    switch_space_5 = {{"alt", "cmd"}, "5"},
    switch_space_6 = {{"alt", "cmd"}, "6"},
    switch_space_7 = {{"alt", "cmd"}, "7"},
    switch_space_8 = {{"alt", "cmd"}, "8"},
    switch_space_9 = {{"alt", "cmd"}, "9"},

    -- move focused window to a new space and tile
    move_window_1 = {{"alt", "shift"}, "1"},
    move_window_2 = {{"alt", "shift"}, "2"},
    move_window_3 = {{"alt", "shift"}, "3"},
    move_window_4 = {{"alt", "shift"}, "4"},
    move_window_5 = {{"alt", "shift"}, "5"},
    move_window_6 = {{"alt", "shift"}, "6"},
    move_window_7 = {{"alt", "shift"}, "7"},
    move_window_8 = {{"alt", "shift"}, "8"},
    move_window_9 = {{"alt", "shift"}, "9"}
})

PaperWM.window_ratios = { 1/3, 1/2, 2/3 }

-- ignore a specific app
-- PaperWM.window_filter:rejectApp("iStat Menus Status")
-- ignore a specific window of an app
-- PaperWM.window_filter:setAppFilter("iTunes", { rejectTitles = "MiniPlayer" })
-- list of screens to tile (use % to escape string match characters, like -)
-- PaperWM.window_filter:setScreens({ "Built%-in Retina Display" })

-- number of fingers to detect a horizontal swipe, set to 0 to disable (the default)
PaperWM.swipe_fingers = 3

-- increase this number to make windows move farther when swiping
PaperWM.swipe_gain = 1.0

-- set to a table of modifier keys to enable window dragging, default is nil
PaperWM.drag_window = { "alt", "cmd" }

-- set to a table of modifier keys to enable window lifting, default is nil
PaperWM.lift_window = { "alt", "cmd", "shift" }

PaperWM:start()

WarpMouse = hs.loadSpoon("WarpMouse")
WarpMouse.margin = 8  -- optionally set how far past a screen edge the mouse
                      -- should warp, default is 2 pixels
WarpMouse:start()
