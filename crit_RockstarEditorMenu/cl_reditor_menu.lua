local btns = {}
local areButtonsShown = false
local reopenMenu = false

local firstTooltips = true -- Change this to FALSE if you don't want the tutorial.
local firstTooltipsLabels = {"AM_H_EDIT_2", "AM_H_EDIT_3", "AM_H_EDIT_4"} -- INITIAL RECORDING TUTORIAL. WITHOUT THE FIRST MESSAGE BECAUSE IT'S USELESS.

local function CreateRecordingButtonLabel(input, label)
    local btn = 0
    BeginTextCommandThefeedPost(label)
    btn = EndTextCommandThefeedPostReplayInput(1, input, "")

    return btn
end

local function NotifyLabel(label, colID)
    if colID ~= nil then
        ThefeedSetNextPostBackgroundColor(colID)
    end
    BeginTextCommandThefeedPost(label)
    EndTextCommandThefeedPostTicker(true, false)
end

local function AlertLabel(label)
    SetTextComponentFormat(label)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

Citizen.CreateThread(function()
    while true do
        -- Make sure user is not busy in a pausemenu or NUI. Also make sure that they can see the buttons.
        if not IsPauseMenuActive() and not IsNuiFocused() and not ThefeedIsPaused() then
            -- LControl by default.
            if IsControlEnabled(0,19) and IsControlPressed(0,19) and not reopenMenu then
                if firstTooltips then -- Tutorial logic.
                    Citizen.CreateThread(function()
                        for i,k in pairs(firstTooltipsLabels) do
                            Wait(500)
                            while IsHudComponentActive(10) or IsHudComponentActive(11) or IsHudComponentActive(12) do -- I don't know which one is the correct one.
                                Citizen.Wait(0)
                            end
                            AlertLabel(k)
                        end
                    end)
                    firstTooltips = false
                end

                -- We disable the controls that we use, in case they are used by other resources as well.
                DisableControlAction(0,288, true)
                DisableControlAction(0,289, true)
                DisableControlAction(0,170, true)
                
                -- We set the button notifications.
                if not areButtonsShown then
                    if not IsRecording() then
                        local startRecBtn = CreateRecordingButtonLabel("~INPUT_REPLAY_START_STOP_RECORDING~", "REC_FEED_1") -- Start Recording
                        local startActionReplay = CreateRecordingButtonLabel("~INPUT_REPLAY_START_STOP_RECORDING_SECONDARY~", "REC_FEED_0") -- Turn On Action 
                        table.insert(btns, startRecBtn)
                        table.insert(btns, startActionReplay)
                    else
                        local stopRecBtn = CreateRecordingButtonLabel("~INPUT_REPLAY_START_STOP_RECORDING~", "REC_FEED_5") -- Save Recording
                        local saveActionReplay = CreateRecordingButtonLabel("~INPUT_REPLAY_START_STOP_RECORDING_SECONDARY~", "REC_FEED_3") -- Save Action Clip
                        local saveRecBtn = CreateRecordingButtonLabel("~INPUT_SAVE_REPLAY_CLIP~", "REC_FEED_4") -- Cancel Recording
                        table.insert(btns, stopRecBtn)
                        table.insert(btns, saveActionReplay)
                        table.insert(btns, saveRecBtn)
                    end
                    AnimpostfxPlay("SwitchHUDIn", 300, true) -- The blur effect.
                    areButtonsShown = true
                end

                -- We wait for input. (Remember, we disabled the controls).
                -- We use "Released" instead of "Pressed", so the player can rethink their action by releasing LControl.
                if IsDisabledControlJustReleased(0,288) then -- Start / Stop normal
                    reopenMenu = true
                    if not IsRecording() then
                        StartRecording(1)
                        if GetFollowVehicleCamViewMode() == 4 then
                            NotifyLabel("REC_FEED_WAR") -- Warning about first-person camera recordings.
                        end
                    else
                        StopRecordingAndSaveClip()
                    end
                end
                if IsDisabledControlJustReleased(0,289) then -- Start / Stop Action Replay.
                    reopenMenu = true
                    if not IsRecording() then
                        StartRecording(0)
                        if GetFollowVehicleCamViewMode() == 4 then
                            NotifyLabel("REC_FEED_WAR") -- Warning about first-person camera recordings.
                        end
                    else
                        local retval = SaveRecordingClip()
                        if retval then
                            NotifyLabel("REPLAY_SAVING", 18) -- Saving...
                        else
                            NotifyLabel("REPLAY_SAVE_CLIP_FAILED", 6) -- Saving clip failed.
                        end
                    end
                end
                if IsDisabledControlJustReleased(0,170) then -- Discard Rec ... But the control action says SAVE...
                    reopenMenu = true
                    if IsRecording() then
                        StopRecordingAndDiscardClip()
                    end
                end
            
            -- If we no longer hold LControl, remove the postfx, and clear the buttons.
            elseif areButtonsShown then
                AnimpostfxStop("SwitchHUDIn")
                AnimpostfxPlay("SwitchHUDOut", 300, false)
                for i,k in pairs(btns) do
                    ThefeedRemoveItem(k)
                end
                btns = {}
                areButtonsShown = false
                reopenMenu = false
            end
        else -- We are in a menu, wait a bit.
            if areButtonsShown then
                AnimpostfxStop("SwitchHUDIn")
                AnimpostfxPlay("SwitchHUDOut", 300, false)
                for i,k in pairs(btns) do
                    ThefeedRemoveItem(k)
                end
                btns = {}
                areButtonsShown = false
                reopenMenu = false
            end
            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)

--[[

    STRING BASED NOTIFICATIONS, BUT WE USE LABELS NOW, BECAUSE WE ARE COOL.

local function CreateRecordingButton(input, string)
    local btn = 0
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(string)
    btn = EndTextCommandThefeedPostReplayInput(1, input, "")

    return btn
end

local function Notify(string, colID)
    if colID ~= nil then
        ThefeedSetNextPostBackgroundColor(colID)
    end
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(string)
    EndTextCommandThefeedPostTicker(true, false)
end

local function Alert(string)
    SetTextComponentFormat("STRING")
    AddTextComponentSubstringPlayerName(string)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end
]]

