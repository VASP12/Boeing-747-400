-- Boeing 747-400 Systems --
-- Version: 1.0.0

-- XLUA GLOBALS --

-- CONSTANTS --

-- GLOBAL VARIABLES --

-- LOCAL VARIABLES --

-- FIND X-PLANE DATAREFS --

--[[General X-Plane Datarefs]]--
simDR_startup_running                   = find_dataref("sim/operation/prefs/startup_running")
simDR_engine_running                    = find_dataref("sim/flightmodel/engine/ENGN_running")
simDR_aircraft_on_ground                = find_dataref("sim/flightmodel/failures/onground_all")
simDR_aircraft_groundspeed              = find_dataref("sim/flightmodel/position/groundspeed")

--[[ Electrical System --]]
simDR_battery_on                        = find_dataref("sim/cockpit2/electrical/battery_on")
simDR_gpu_on                            = find_dataref("sim/cockpit/electrical/gpu_on")
simDR_cross_tie                         = find_dataref("sim/cockpit2/electrical/cross_tie")
simDR_apu_gen_on                        = find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_apu_gen_amps                      = find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_apu_start_switch_mode             = find_dataref("sim/cockpit2/electrical/APU_starter_switch")
simDR_apu_N1_pct                        = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_apu_running                       = find_dataref("sim/cockpit2/electrical/APU_running")
simDR_generator_on                      = find_dataref("sim/cockpit2/electrical/generator_on")

-- FIND CUSTOM DATAREFS --

--[[Electrical System --]]
B747DR_button_switch_position           = find_dataref("laminar/B747/button_switch/position")
B747DR_elec_ext_pwr_1_switch_mode       = find_dataref("laminar/B747/elec_ext_pwr_1/switch_mode")
B747DR_elec_apu_pwr_1_switch_mode       = find_dataref("laminar/B747/apu_pwr_1/switch_mode")
B747DR_gen_drive_disc_status            = find_dataref("laminar/B747/electrical/generator/drive_disc_status")
B747DR_CAS_advisory_status              = find_dataref("laminar/B747/CAS/advisory_status")
B747DR_CAS_memo_status                  = find_dataref("laminar/B747/CAS/memo_status")

-- FIND X-PLANE COMMANDS --

-- FIND CUSTOM COMMANDS --

--[[ Electrical System--]]
simCMD_apu_gen_on                       = find_command("sim/electrical/APU_generator_on")
simCMD_apu_gen_off                      = find_command("sim/electrical/APU_generator_off")

-- CREATE READ-ONLY CUSTOM DATAREFS --

--[[ Electrical System --]]
B747DR_elec_standby_power_sel_pos       = create_dataref("laminar/B747/electrical/standby_power/sel_dial_pos", "number")
B747DR_elec_apu_sel_pos                 = create_dataref("laminar/B747/electrical/apu/sel_dial_pos", "number")
B747DR_elec_stby_ignit_sel_pos          = create_dataref("laminar/B747/electrical/stby_ignit/sel_dial_pos", "number")
B747DR_elec_auto_ignit_sel_pos          = create_dataref("laminar/B747/electrical/auto_ignit/sel_dial_pos", "number")
B747DR_elec_apu_inlet_door_pos          = create_dataref("laminar/B747/electrical/apu_inlet_door", "number")
B747DR_elec_ext_pwr1_available          = create_dataref("laminar/B747/electrical/ext_pwr1_avail", "number")
B747DR_init_elec_CD                     = create_dataref("laminar/B747/elec/init_CD", "number")


-- READ-WRITE CUSTOM DATAREF HANDLERS --

-- CREATE READ-WRITE CUSTOM DATAREFS --

-- CUSTOM COMMAND HANDLERS --

-- CREATE CUSTOM COMMANDS --

--[[ Electrical System --]]
B747CMD_elec_standby_power_sel_up       = create_command("laminar/B747/electrical/standby_power/sel_dial_up", "Electrical Standby Power Selector Up", B747_elec_standby_power_sel_up_CMDhandler)
B747CMD_elec_standby_power_sel_dn       = create_command("laminar/B747/electrical/standby_power/sel_dial_dn", "Electrical Standby Power Selector Down", B747_elec_standby_power_sel_dn_CMDhandler)
B747CMD_elec_apu_sel_up                 = create_command("laminar/B747/electrical/apu/sel_dial_up", "Electrical APU Selector Dial Up", B747_elec_apu_sel_up_CMDhandler)
B747CMD_elec_apu_sel_dn                 = create_command("laminar/B747/electrical/apu/sel_dial_dn", "Electrical APU Selector Dial Down", B747_elec_apu_sel_dn_CMDhandler)
B747CMD_stby_ign_sel_up                 = create_command("laminar/B747/electrical/stby_ignit/sel_dial_up", "Electrical Standby Ignition Selector Dial Up", B747_stby_ign_sel_up_CMDhandler)
B747CMD_stby_ign_sel_dn                 = create_command("laminar/B747/electrical/stby_ignit/sel_dial_dn", "Electrical Standby Ignition Selector Dial Down", B747_stby_ign_sel_dn_CMDhandler)
B747CMD_auto_ign_sel_up                 = create_command("laminar/B747/electrical/auto_ignit/sel_dial_up", "Electrical Auto Ignition Selector Dial Up", B747_auto_ign_sel_up_CMDhandler)
B747CMD_auto_ign_sel_dn                 = create_command("laminar/B747/electrical/auto_ignit/sel_dial_dn", "Electrical Auto Ignition Selector Dial Down", B747_auto_ign_sel_dn_CMDhandler)
B747CMD_ai_elec_quick_start			        = create_command("laminar/B747/ai/elec_quick_start", "number", B747_ai_elec_quick_start_CMDhandler)


-- REPLACE X-PLANE COMMAND HANDLERS --

-- REPLACE X-PLANE COMMANDS --

--[[ Electrical System]]
simCMD_apu_start                        = replace_command("sim/electrical/APU_start", sim_apu_start_CMDhandler)
simCMD_apu_on                           = replace_command("sim/electrical/APU_on", sim_apu_on_CMDhandler)
simCMD_apu_off                          = replace_command("sim/electrical/APU_off", sim_apu_off_CMDhandler)

-- X-PLANE WRAP COMMAND HANDLERS --

-- WRAP X-PLANE COMMANDS --

-- OBJECT CONSTRUCTORS --

-- CREATE OBJECTS --

-- SYSTEM FUNCTIONS --


-- ANIMATION UTILITY --
function B747_set_animation_position(current_value, target, min, max, speed)
    local fps_factor = math.min(1.0, speed * SIM_PERIOD)
    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end
end

-- EVENT CALLBACKS --
function aircraft_load() end

function aircraft_unload() end

function flight_start() end

function flight_crash() end

function before_physics() end

function after_physics() end

function after_replay() end

-- SUB-MODULE PROCESSING --

--dofile("")
--dofile("")
--dofile("")
--dofile("")
--dofile("")
--dofile("")
--dofile("")
--dofile("")
--dofile("")
--dofile("")
