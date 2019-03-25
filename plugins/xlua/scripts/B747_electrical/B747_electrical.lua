--[[
*****************************************************************************************
* Program Script Name	:	B747.03.electrical
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2016-05-03	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT � 2016 JIM GREGORY / LAMINAR RESEARCH - ALL RIGHTS RESERVED	    *
*****************************************************************************************
--]]

--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

local NUM_ALERT_MESSAGES = 109

--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local B747_apu_start = 0
local B747_apu_inlet_door_target_pos = 0

local B747_CASwarning   = {}
local B747_CAScaution   = {}
local B747_CASadvisory  = {}
local B747_CASmemo      = {}

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running           	= find_dataref("sim/operation/prefs/startup_running")
simDR_engine_running            	= find_dataref("sim/flightmodel/engine/ENGN_running")
simDR_aircraft_on_ground        	= find_dataref("sim/flightmodel/failures/onground_all")
simDR_aircraft_groundspeed      	= find_dataref("sim/flightmodel/position/groundspeed")
simDR_battery_on                	= find_dataref("sim/cockpit2/electrical/battery_on")
simDR_gpu_on                    	= find_dataref("sim/cockpit/electrical/gpu_on")
simDR_cross_tie                 	= find_dataref("sim/cockpit2/electrical/cross_tie")
simDR_apu_gen_on                	= find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_apu_gen_amps              	= find_dataref("sim/cockpit2/electrical/APU_generator_amps") -- why was this commented out?
simDR_apu_start_switch_mode     	= find_dataref("sim/cockpit2/electrical/APU_starter_switch")
simDR_apu_N1_pct                	= find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_apu_running               	= find_dataref("sim/cockpit2/electrical/APU_running")
simDR_generator_on              	= find_dataref("sim/cockpit2/electrical/generator_on")
simDR_ind_airspeed_kts_pilot        = find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B747DR_button_switch_position       = find_dataref("laminar/B747/button_switch/position")
B747DR_elec_ext_pwr_1_switch_mode   = find_dataref("laminar/B747/elec_ext_pwr_1/switch_mode")
B747DR_elec_ext_pwr_2_switch_mode   = find_dataref("laminar/B747/elec_ext_pwr_2/switch_mode")
B747DR_elec_apu_pwr_1_switch_mode   = find_dataref("laminar/B747/apu_pwr_1/switch_mode")
B747DR_gen_drive_disc_status        = find_dataref("laminar/B747/electrical/generator/drive_disc_status")
B747DR_CAS_advisory_status          = find_dataref("laminar/B747/CAS/advisory_status")
B747DR_CAS_memo_status              = find_dataref("laminar/B747/CAS/memo_status")
B747DR_airspeed_Vmc                 = find_dataref("laminar/B747/airspeed/Vmc")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B747DR_elec_standby_power_sel_pos   = create_dataref("laminar/B747/electrical/standby_power/sel_dial_pos", "number")
B747DR_elec_apu_sel_pos             = create_dataref("laminar/B747/electrical/apu/sel_dial_pos", "number")
B747DR_elec_stby_ignit_sel_pos      = create_dataref("laminar/B747/electrical/stby_ignit/sel_dial_pos", "number")
B747DR_elec_auto_ignit_sel_pos      = create_dataref("laminar/B747/electrical/auto_ignit/sel_dial_pos", "number")
B747DR_elec_apu_inlet_door_pos      = create_dataref("laminar/B747/electrical/apu_inlet_door", "number")
B747DR_elec_ext_pwr1_available      = create_dataref("laminar/B747/electrical/ext_pwr1_avail", "number")
B747DR_elec_ext_pwr2_available      = create_dataref("laminar/B747/electrical/ext_pwr2_avail", "number")
B747DR_elec_ext_pwr1_on				= create_dataref("laminar/B747/electrical/ext_pwr1_on", "number")
B747DR_elec_ext_pwr2_on				= create_dataref("laminar/B747/electrical/ext_pwr2_on", "number")
B747DR_init_elec_CD                 = create_dataref("laminar/B747/elec/init_CD", "number")

B747DR_CAS_warning_status       	= create_dataref("laminar/B747/CAS/warning_status", string.format("array[%s]", #B747_CASwarningMsg))
B747DR_CAS_caution_status       	= create_dataref("laminar/B747/CAS/caution_status", string.format("array[%s]", #B747_CAScautionMsg))
B747DR_CAS_advisory_status      	= create_dataref("laminar/B747/CAS/advisory_status", string.format("array[%s]", #B747_CASadvisoryMsg))
B747DR_CAS_memo_status          	= create_dataref("laminar/B747/CAS/memo_status", string.format("array[%s]", #B747_CASmemoMsg))

B747DR_CAS_gen_warning_msg = {}
for i = 0, NUM_ALERT_MESSAGES do
    B747DR_CAS_gen_warning_msg[i] 	= create_dataref(string.format("laminar/B747/CAS/gen_warning_msg_%03d", i), "string")
end

B747DR_CAS_gen_caution_msg = {}
for i = 0, NUM_ALERT_MESSAGES do
    B747DR_CAS_gen_caution_msg[i]   = create_dataref(string.format("laminar/B747/CAS/gen_caution_msg_%03d", i), "string")
end

B747DR_CAS_gen_advisory_msg = {}
for i = 0, NUM_ALERT_MESSAGES do
    B747DR_CAS_gen_advisory_msg[i] = create_dataref(string.format("laminar/B747/CAS/gen_advisory_msg_%03d", i), "string")
end

B747DR_CAS_gen_memo_msg = {}
for i = 0, NUM_ALERT_MESSAGES do
    B747DR_CAS_gen_memo_msg[i] 	   = create_dataref(string.format("laminar/B747/CAS/gen_memo_msg_%03d", i), "string")
end

B747DR_CAS_recall_ind           = create_dataref("laminar/B747/CAS/recall_ind", "number")
B747DR_CAS_sec_eng_exceed_cue   = create_dataref("laminar/B747/CAS/sec_eng_exceed_cue", "number")
B747DR_CAS_status_cue           = create_dataref("laminar/B747/CAS/status_cue", "number")
B747DR_CAS_msg_page             = create_dataref("laminar/B747/CAS/msg_page", "number")
B747DR_CAS_num_msg_pages        = create_dataref("laminar/B747/CAS/num_msg_pages", "number")
B747DR_CAS_caut_adv_display     = create_dataref("laminar/B747/CAS/caut_adv_display", "number")
B747DR_master_warning           = create_dataref("laminar/B747/warning/master_warning", "number")
B747DR_master_caution           = create_dataref("laminar/B747/warning/master_caution", "number")
B747DR_init_warning_CD          = create_dataref("laminar/B747/warning/init_CD", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	         	     **--
--*************************************************************************************--

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--

function sim_apu_start_CMDhandler(phase, duration)
    if phase == 0 then

        if simDR_apu_running == 0 then
            if B747DR_elec_apu_sel_pos == 0 then
                B747CMD_elec_apu_sel_up:once()
                B747CMD_elec_apu_sel_up:once()
            elseif B747DR_elec_apu_sel_pos == 1 then
                B747CMD_elec_apu_sel_up:once()
            end
        end
    end
end

function sim_apu_on_CMDhandler(phase, duration)
    if phase == 0 then
        if B747DR_elec_apu_sel_pos == 0 then
            B747CMD_elec_apu_sel_up:once()
        end
    end
end

function sim_apu_off_CMDhandler(phase, duration)
    if phase == 0 then
        if B747DR_elec_apu_sel_pos == 1 then
            B747CMD_elec_apu_sel_dn:once()
        end
    end
end

--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_apu_start                = replace_command("sim/electrical/APU_start", sim_apu_start_CMDhandler)
simCMD_apu_on                   = replace_command("sim/electrical/APU_on", sim_apu_on_CMDhandler)
simCMD_apu_off                  = replace_command("sim/electrical/APU_off", sim_apu_off_CMDhandler)
--simCMD_apu_gen_on               = find_command("sim/electrical/APU_generator_on")
--simCMD_apu_gen_off              = find_command("sim/electrical/APU_generator_off")

--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

function B747_elec_standby_power_sel_up_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_standby_power_sel_pos = math.min(B747DR_elec_standby_power_sel_pos+1, 2)
    end
end

function B747_elec_standby_power_sel_dn_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_standby_power_sel_pos = math.max(B747DR_elec_standby_power_sel_pos-1, 0)
    end
end

function B747_elec_apu_sel_up_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_apu_sel_pos = math.min(B747DR_elec_apu_sel_pos+1, 2)
        if B747DR_elec_apu_sel_pos == 2 then B747_apu_start = 1 end
    end

    if phase == 2 then
        if B747DR_elec_apu_sel_pos == 2 then
            B747DR_elec_apu_sel_pos = 1
        end
    end
end

function B747_elec_apu_sel_dn_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_apu_sel_pos = math.max(B747DR_elec_apu_sel_pos-1, 0)
    end
end

function B747_stby_ign_sel_up_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_stby_ignit_sel_pos = math.min(B747DR_elec_stby_ignit_sel_pos+1, 2)
    end
end

function B747_stby_ign_sel_dn_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_stby_ignit_sel_pos = math.max(B747DR_elec_stby_ignit_sel_pos-1, 0)
    end
end

function B747_auto_ign_sel_up_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_auto_ignit_sel_pos = math.min(B747DR_elec_auto_ignit_sel_pos+1, 2)
    end
end

function B747_auto_ign_sel_dn_CMDhandler(phase, duration)
    if phase == 0 then
        B747DR_elec_auto_ignit_sel_pos = math.max(B747DR_elec_auto_ignit_sel_pos-1, 0)
    end
end

function B747_ai_elec_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B747_set_elec_all_modes()
	  	B747_set_elec_CD() 
	  	B747_set_elec_ER()
	end 	
end	

function B747_ai_warning_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
		B747_set_warning_all_modes()
		B747_set_warning_CD()
		B747_set_warning_ER()	
	end 	
end	

--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--

B747CMD_elec_standby_power_sel_up 		= create_command("laminar/B747/electrical/standby_power/sel_dial_up", "Electrical Standby Power Selector Up", B747_elec_standby_power_sel_up_CMDhandler)
B747CMD_elec_standby_power_sel_dn 		= create_command("laminar/B747/electrical/standby_power/sel_dial_dn", "Electrical Standby Power Selector Down", B747_elec_standby_power_sel_dn_CMDhandler)
B747CMD_elec_apu_sel_up 				= create_command("laminar/B747/electrical/apu/sel_dial_up", "Electrical APU Selector Dial Up", B747_elec_apu_sel_up_CMDhandler)
B747CMD_elec_apu_sel_dn 				= create_command("laminar/B747/electrical/apu/sel_dial_dn", "Electrical APU Selector Dial Down", B747_elec_apu_sel_dn_CMDhandler)
B747CMD_stby_ign_sel_up 				= create_command("laminar/B747/electrical/stby_ignit/sel_dial_up", "Electrical Standby Ignition Selector Dial Up", B747_stby_ign_sel_up_CMDhandler)
B747CMD_stby_ign_sel_dn 				= create_command("laminar/B747/electrical/stby_ignit/sel_dial_dn", "Electrical Standby Ignition Selector Dial Down", B747_stby_ign_sel_dn_CMDhandler)
B747CMD_auto_ign_sel_up 				= create_command("laminar/B747/electrical/auto_ignit/sel_dial_up", "Electrical Auto Ignition Selector Dial Up", B747_auto_ign_sel_up_CMDhandler)
B747CMD_auto_ign_sel_dn 				= create_command("laminar/B747/electrical/auto_ignit/sel_dial_dn", "Electrical Auto Ignition Selector Dial Down", B747_auto_ign_sel_dn_CMDhandler)
B747CMD_ai_elec_quick_start				= create_command("laminar/B747/ai/elec_quick_start", "number", B747_ai_elec_quick_start_CMDhandler)
B747CMD_ai_warning_quick_start			= create_command("laminar/B747/ai/warning_quick_start", "number", B747_ai_warning_quick_start_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--




--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--




--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
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

function B747_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function B747_ternary(condition, ifTrue, ifFalse)
    if condition then return ifTrue else return ifFalse end
end

function B747_battery()
	if B747DR_button_switch_position[13] < 0.05 then
		simDR_battery_on[0] = 0
	end
	
	if B747DR_button_switch_position[13] > 0.95 then
		simDR_battery_on[0] = 1
	end
end

function B747_external_power()

    -- EXT POWER 1,2 AVAILABLE
    if simDR_aircraft_on_ground == 1
        and simDR_aircraft_groundspeed < 0.05
        and simDR_engine_running[0] == 0
        and simDR_engine_running[1] == 0
        and simDR_engine_running[2] == 0
        and simDR_engine_running[3] == 0
    then
        B747DR_elec_ext_pwr1_available = 1
		B747DR_elec_ext_pwr2_available = 1
		
    else
        B747DR_elec_ext_pwr1_available = 0
		B747DR_elec_ext_pwr2_available = 0
    end

    -- EXTERNAL POWER ON/OFF
    if B747DR_elec_ext_pwr1_available == 1
        and B747DR_elec_ext_pwr_1_switch_mode == 1
    then
		B747DR_elec_ext_pwr1_on = 1
    else
        B747DR_elec_ext_pwr1_on = 0
    end
	
	if B747DR_elec_ext_pwr2_available == 1
        and B747DR_elec_ext_pwr_2_switch_mode == 1
    then
		B747DR_elec_ext_pwr2_on = 1
    else
        B747DR_elec_ext_pwr2_on = 0
    end
	
	if B747DR_elec_ext_pwr1_on == 1 and B747DR_elec_ext_pwr2_on == 1
	then
		simDR_gpu_on = 1
	else
		simDR_gpu_on = 0
	end

end

function B747_bus_tie()

    if B747DR_button_switch_position[18] > 0.95
        and B747DR_button_switch_position[19] > 0.95
        and B747DR_button_switch_position[20] > 0.95
        and B747DR_button_switch_position[21] > 0.95
        and simDR_cross_tie == 0
    then
        simDR_cross_tie = 1
    elseif (B747DR_button_switch_position[18] < 0.05
        or B747DR_button_switch_position[19] < 0.05
        or B747DR_button_switch_position[20] < 0.05
        or B747DR_button_switch_position[21] < 0.05)
        and simDR_cross_tie == 1
    then
        simDR_cross_tie = 0
    end

end

function B747_apu_shutdown()

    simDR_apu_start_switch_mode = 0
    B747DR_elec_apu_pwr_1_switch_mode = 0
    B747_apu_inlet_door_target_pos = 0.0

end

function B747_apu()

    -- STARTER
    if B747DR_elec_apu_sel_pos == 0 then
        if simDR_apu_running == 1 then
            if simDR_battery_on[0] == 0 then                    -- APU SHUTDOWN IMMEDIATELY IF BATTERY OFF
            B747_apu_shutdown()
            else                                                -- APU COOL DOWN BEFORE SHUT DOWN
                if is_timer_scheduled(B747_apu_shutdown) == false then
                    run_after_time(B747_apu_shutdown, 60.0)
                end
            end
        end


    elseif B747_apu_start == 1 then                   -- TODO:  NEED BATTERY SWITCH ON OR HARDWIRED ?
        if simDR_apu_running == 0 then
            B747_apu_inlet_door_target_pos = 1.0
            if B747DR_elec_apu_inlet_door_pos > 0.95 then
                simDR_apu_start_switch_mode = 2                 -- START
            end

        elseif simDR_apu_running == 1 then
            B747_apu_start = 0
            simDR_apu_start_switch_mode = 1                     -- RUNNING
        end

    end


    -- INLET DOOR
    B747DR_elec_apu_inlet_door_pos = B747_set_animation_position(B747DR_elec_apu_inlet_door_pos, B747_apu_inlet_door_target_pos, 0.0, 1.0, 0.7)


    -- APU GENERATOR
    if simDR_aircraft_on_ground == 1 then
        if B747DR_elec_apu_pwr_1_switch_mode == 1
            and simDR_apu_N1_pct > 95.0
            and simDR_apu_gen_on == 0
        then
            simDR_apu_gen_on = 1
        elseif B747DR_elec_apu_pwr_1_switch_mode == 0 then
            simDR_apu_gen_on = 0
        end
    else
        if simDR_apu_gen_on == 1 then
            simDR_apu_gen_on = 0
        end
    end

end

function B747_generator() -- DONT EDIT THIS

    -- ENGINE #1
    if B747DR_gen_drive_disc_status[0] == 1 then
        simDR_generator_on[0] = 0
    else
        if simDR_generator_on[0] == 0
            and B747DR_button_switch_position[22] >= 0.95
        then
            simDR_generator_on[0] = 1
        elseif simDR_generator_on[0] == 1
            and B747DR_button_switch_position[22] <= 0.05
        then
            simDR_generator_on[0] = 0
        end
    end


    -- ENGINE #2
    if B747DR_gen_drive_disc_status[1] == 1 then
        simDR_generator_on[1] = 0
    else
        if simDR_generator_on[1] == 0
                and B747DR_button_switch_position[23] >= 0.95
        then
            simDR_generator_on[1] = 1
        elseif simDR_generator_on[1] == 1
                and B747DR_button_switch_position[23] <= 0.05
        then
            simDR_generator_on[1] = 0
        end
    end


    -- ENGINE #3
    if B747DR_gen_drive_disc_status[2] == 1 then
        simDR_generator_on[2] = 0
    else
        if simDR_generator_on[2] == 0
                and B747DR_button_switch_position[24] >= 0.95
        then
            simDR_generator_on[2] = 1
        elseif simDR_generator_on[2] == 1
                and B747DR_button_switch_position[24] <= 0.05
        then
            simDR_generator_on[2] = 0
        end
    end


    -- ENGINE #4
    if B747DR_gen_drive_disc_status[3] == 1 then
        simDR_generator_on[3] = 0
    else
        if simDR_generator_on[3] == 0
                and B747DR_button_switch_position[25] >= 0.95
        then
            simDR_generator_on[3] = 1
        elseif simDR_generator_on[3] == 1
                and B747DR_button_switch_position[25] <= 0.05
        then
            simDR_generator_on[3] = 0
        end
    end

end

function B747_electrical_EICAS_msg()

    -- APU
    B747DR_CAS_advisory_status[13] = 0
    if (B747DR_elec_apu_sel_pos > 0.95 and simDR_apu_N1_pct < 0.1)
        or
        (B747DR_elec_apu_sel_pos < 0.05 and simDR_apu_N1_pct > 95.0)
    then
        B747DR_CAS_advisory_status[13] = 1
    end

    -- APU DOOR
    B747DR_CAS_advisory_status[14] = 0
    if (B747DR_elec_apu_inlet_door_pos > 0.95 and simDR_apu_running == 0)
        or
        (B747DR_elec_apu_inlet_door_pos < 0.05 and simDR_apu_running == 1)
    then
        B747DR_CAS_advisory_status[14] = 1
    end

    -- >DRIVE DISC 1
    B747DR_CAS_advisory_status[83] = 0
    if B747DR_gen_drive_disc_status[0] == 1 then B747DR_CAS_advisory_status[83] = 1 end

    -- >DRIVE DISC 2
    B747DR_CAS_advisory_status[84] = 0
    if B747DR_gen_drive_disc_status[1] == 1 then B747DR_CAS_advisory_status[84] = 1 end

    -- >DRIVE DISC 3
    B747DR_CAS_advisory_status[85] = 0
    if B747DR_gen_drive_disc_status[2] == 1 then B747DR_CAS_advisory_status[85] = 1 end

    -- >DRIVE DISC 4
    B747DR_CAS_advisory_status[86] = 0
    if B747DR_gen_drive_disc_status[3] == 1 then B747DR_CAS_advisory_status[86] = 1 end

    -- ELEC UTIL BUS L
    B747DR_CAS_advisory_status[105] = 0
    if B747DR_button_switch_position[11] < 0.05 then B747DR_CAS_advisory_status[105] = 1 end

    -- ELEC UTIL BUS R
    B747DR_CAS_advisory_status[106] = 0
    if B747DR_button_switch_position[12] < 0.05 then B747DR_CAS_advisory_status[106] = 1 end

    -- APU RUNNING
    B747DR_CAS_memo_status[1] = 0
    if B747DR_elec_apu_sel_pos == 1 and simDR_apu_N1_pct > 95.0 then
        B747DR_CAS_memo_status[1] = 1
    end

    -- STBY IGNITION ON
    B747DR_CAS_memo_status[34] = 0
    if B747DR_elec_stby_ignit_sel_pos == 0
        or B747DR_elec_stby_ignit_sel_pos == 2
    then
        B747DR_CAS_memo_status[34] = 1
    end

end

function B747_removeWarning(message)

    for i = #B747_CASwarning, 1, -1 do
        if B747_CASwarning[i] == message then
            table.remove(B747_CASwarning, i)
            break
        end
    end

end

function B747_removeCaution(message)

    for i = #B747_CAScaution, 1, -1 do
        if B747_CAScaution[i] == message then
            table.remove(B747_CAScaution, i)
            break
        end
    end

end

function B747_removeAdvisory(message)

    for i = #B747_CASadvisory, 1, -1 do
        if B747_CASadvisory[i] == message then
            table.remove(B747_CASadvisory, i)
            break
        end
    end

end

function B747_removeMemo(message)

    for i = #B747_CASmemo, 1, -1 do
        if B747_CASmemo[i] == message then
            table.remove(B747_CASmemo, i)
            break
        end
    end

end

function B747_CAS_queue() 

    for i = 1, #B747_CASwarningMsg do                                                                   -- ITERATE THE WARNINGS DATA TABLE

        if B747_CASwarningMsg[i].status ~= B747DR_CAS_warning_status[B747_CASwarningMsg[i].DRindex] then -- THE WARNING STATUS HAS CHANGED

            if B747DR_CAS_warning_status[B747_CASwarningMsg[i].DRindex] == 1 then                       -- WARNING IS ACTIVE
                table.insert(B747_CASwarning, B747_CASwarningMsg[i].name)                               -- ADD TO THE WARNING QUEUE
                B747DR_master_warning = 1                                                               -- SET THE MASTER WARNING
            elseif B747DR_CAS_warning_status[B747_CASwarningMsg[i].DRindex] == 0 then                   -- WARNING IS INACTIVE
                B747_removeWarning(B747_CASwarningMsg[i].name)                                          -- REMOVE FROM THE WARNING QUEUE
            end
            B747_CASwarningMsg[i].status = B747DR_CAS_warning_status[B747_CASwarningMsg[i].DRindex]     -- RESET WARNING STATUS

        end

    end

    for i = 1, #B747_CAScautionMsg do                                                      -- ITERATE THE CAUTIONS DATA TABLE

        if B747_CAScautionMsg[i].status ~= B747DR_CAS_caution_status[B747_CAScautionMsg[i].DRindex] then -- THE CAUTION STATUS HAS CHANGED

            if B747DR_CAS_caution_status[B747_CAScautionMsg[i].DRindex] == 1 then                 -- CAUTION IS ACTIVE
                table.insert(B747_CAScaution, B747_CAScautionMsg[i].name)                  -- ADD TO THE CAUTION QUEUE
                B747DR_master_caution = 1                                                   -- SET THE MASTER CAUTION
            elseif B747DR_CAS_caution_status[B747_CAScautionMsg[i].DRindex] == 0 then             -- CAUTION IS INACTIVE
                B747_removeCaution(B747_CAScautionMsg[i].name)                             -- REMOVE FROM THE CAUTION QUEUE
            end
            B747_CAScautionMsg[i].status = B747DR_CAS_caution_status[B747_CAScautionMsg[i].DRindex]  -- RESET CAUTION STATUS

        end

    end

    for i = 1, #B747_CASadvisoryMsg do                                                      -- ITERATE THE CAUTIONS DATA TABLE

        if B747_CASadvisoryMsg[i].status ~= B747DR_CAS_advisory_status[B747_CASadvisoryMsg[i].DRindex] then -- THE CAUTION STATUS HAS CHANGED

            if B747DR_CAS_advisory_status[B747_CASadvisoryMsg[i].DRindex] == 1 then                 -- CAUTION IS ACTIVE
                table.insert(B747_CASadvisory, B747_CASadvisoryMsg[i].name)                  -- ADD TO THE CAUTION QUEUE
            elseif B747DR_CAS_advisory_status[B747_CASadvisoryMsg[i].DRindex] == 0 then             -- CAUTION IS INACTIVE
                B747_removeAdvisory(B747_CASadvisoryMsg[i].name)                             -- REMOVE FROM THE CAUTION QUEUE
            end
            B747_CASadvisoryMsg[i].status = B747DR_CAS_advisory_status[B747_CASadvisoryMsg[i].DRindex]  -- RESET CAUTION STATUS

        end

    end

    for i = 1, #B747_CASmemoMsg do                                                          -- ITERATE THE CAUTIONS DATA TABLE

        if B747_CASmemoMsg[i].status ~= B747DR_CAS_memo_status[B747_CASmemoMsg[i].DRindex] then    -- THE CAUTION STATUS HAS CHANGED

            if B747DR_CAS_memo_status[B747_CASmemoMsg[i].DRindex] == 1 then                        -- CAUTION IS ACTIVE
                table.insert(B747_CASmemo, B747_CASmemoMsg[i].name)                         -- ADD TO THE CAUTION QUEUE
            elseif B747DR_CAS_memo_status[B747_CASmemoMsg[i].DRindex] == 0 then                    -- CAUTION IS INACTIVE
                B747_removeMemo(B747_CASmemoMsg[i].name)                                -- REMOVE FROM THE CAUTION QUEUE
            end
            B747_CASmemoMsg[i].status = B747DR_CAS_memo_status[B747_CASmemoMsg[i].DRindex]         -- RESET CAUTION STATUS

        end

    end

end

function B747_CAS_display()
    B747DR_CAS_num_msg_pages = #B747_CASwarning
    if #B747_CASwarning < 11 then
        B747DR_CAS_num_msg_pages = math.ceil(math.max(10, (#B747_CASwarning + #B747_CAScaution + #B747_CASadvisory + #B747_CASmemo)) / 11)
    end
    local numAlertPages = 10 --math.ceil((#B747_CASwarning + #B747_CAScaution + #B747_CASadvisory + #B747_CASmemo) / 11)  -- TODO:  CHANGE TO FIXED NUMBER OF PAGES (GENERIC MESSAGES)
    local genIndex = 0
    local lastGenIndex = 0

    for x = 0, NUM_ALERT_MESSAGES do
        B747DR_CAS_gen_warning_msg[x] = ""
        B747DR_CAS_gen_caution_msg[x] = ""
        B747DR_CAS_gen_advisory_msg[x] = ""
        B747DR_CAS_gen_memo_msg[x] = ""
    end
	
    for i = #B747_CASwarning, 1, -1 do                                                      -- REVERSE ITERATE THE TABLE (GET MOST RECENT FIRST)

        B747DR_CAS_gen_warning_msg[genIndex] = B747_CASwarning[i]                               -- ASSIGN ALERT TO WARNING GENERIC
        lastGenIndex = genIndex
        if #B747_CASwarning < 11 then                                                       -- NUM WARNINGS FILLS OR EXCEEDS ONE PAGE
            for page = 2, numAlertPages  do                                                 -- ITERATE ALL OTHER ALERT PAGES
                B747DR_CAS_gen_warning_msg[((page*11)-11) + genIndex] = B747DR_CAS_gen_warning_msg[genIndex]    -- DUPLICATE THE WARNING FOR ALL PAGES
            end
        end
        genIndex = genIndex + 1                                                             -- INCREMENT THE GENERIC INDEX

    end

    if #B747_CASwarning < 11 then                                                           -- FIRST PAGE NOT FULL OF WARNINGS - OK TO PROCEED
        if B747DR_CAS_caut_adv_display == 1 then

            for i = #B747_CAScaution, 1, -1 do                                                      -- REVERSE ITERATE THE TABLE (MOST RECENT MESSAGE FIRST)

                B747DR_CAS_gen_caution_msg[genIndex] = B747_CAScaution[i]                           -- ASSIGN ALERT TO CAUTION GENERIC
                lastGenIndex = genIndex
                genIndex = genIndex + 1                                                             -- INCREMENT THE GENERIC INDEX
                if math.fmod(genIndex, 11) == 0 then                                                -- END OF PAGE
                    genIndex = genIndex + #B747_CASwarning                                          -- INCREMENT THE INDEX BY THE NUM OF WARNINGS DISPLAYED (FOR NEXT PAGE)
                end


            end

            for i = #B747_CASadvisory, 1, -1 do                                                     -- REVERSE ITERATE THE TABLE (MOST RECENT MESSAGE FIRST)

                B747DR_CAS_gen_advisory_msg[genIndex] = B747_CASadvisory[i]                             -- ASSIGN ALERT TO ADVISORY GENERIC
                lastGenIndex = genIndex
                genIndex = genIndex + 1                                                             -- INCREMENT THE GENERIC INDEX
                if math.fmod(genIndex, 11) == 0 then                                                -- END OF PAGE
                    genIndex = genIndex + #B747_CASwarning                                          -- INCREMENT THE INDEX BY THE NUM OF WARNINGS DISPLAYED (FOR NEXT PAGE)
                end

            end

        end

        local memoPageCheck = 1                                                                 -- FIST MEMO PAGE CHECK FLAG
        local increment = -1                                                                    -- INITIAL DISPLAY DIRECTION IS BOTTOM UP
        --local lastIndex = genIndex                                                              -- SAVE THE LAST GENERIC INDEX
        local page = math.ceil((genIndex+1) / 11)                                               -- GET CURRENT PAGE #
        local memoStartPage = page                                                              -- ASSIGN START PAGE FOR MEMO MESSAGES

        genIndex = ((memoStartPage * 10) + (memoStartPage - 1))                                 -- START DISPLAY AT BOTTOM OF CURRENT PAGE

        for i = #B747_CASmemo, 1, -1 do                                                         -- REVERSE ITERATE THE TABLE (MOST RECENT MESSAGE FIRST)

            -- FIRST PAGE IS FILLED
            if memoPageCheck == 1                                                               -- OK TO PERFORM CHECK
                and page == memoStartPage                                                       -- STILL ON START PAGE
                and genIndex == lastGenIndex                                                    -- WE ARE AT THE LAST ADVISORY MESSAGE POSITION - START PAGE IS FILLED

            -- START NEXT PAGE
            then
                page = page + 1                                                                 -- INCREMENT PAGE # TO STOP PAGE CHECK
                genIndex = page * 11                                                            -- SET THE GENERIC INDEX TO BEGINNING OF NEXT PAGE
                increment = 1                                                                   -- CHANGE DISPLAY DIRECTION TO TOP DOWM
                memoPageCheck = 0                                                               -- SET THE FLAG TO STOP PAGE CHECK
            end

            B747DR_CAS_gen_memo_msg[genIndex] = B747_CASmemo[i]                                     -- ASSIGN MEMO TO GENERIC
            genIndex = genIndex + increment                                                     -- ADJUST THE GENERIC INDEX
            if math.fmod(genIndex, 10) == 0 then                                                -- END OF PAGE
                genIndex = genIndex + #B747_CASwarning                                          -- INCREMENT THE INDEX BY THE NUM OF WARNINGS DISPLAYED (FOR NEXT PAGE)
            end

        end
    end

end

function B747_warnings_EICAS_msg()

end






----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B747_elec_monitor_AI()

    if B747DR_init_elec_CD == 1 then
        B747_set_elec_all_modes()
        B747_set_elec_CD()
        B747DR_init_elec_CD = 2
    end

end

function B747_warning_monitor_AI()

    if B747DR_init_warning_CD == 1 then
        B747_set_warning_all_modes()
        B747_set_warning_CD()
        B747DR_init_warning_CD = 2
    end

end





----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B747_set_elec_all_modes()
	
	B747DR_init_elec_CD = 0
    B747DR_elec_stby_ignit_sel_pos = 1
    B747DR_elec_auto_ignit_sel_pos = 1

end

function B747_set_warning_all_modes()

	B747DR_init_warning_CD = 0
    B747DR_CAS_msg_page = 1
    B747DR_CAS_caut_adv_display = 1

end





----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B747_set_elec_CD()

    B747DR_elec_standby_power_sel_pos = 0
    B747DR_elec_apu_sel_pos = 0
    simDR_apu_start_switch_mode = 0

end

function B747_set_warning_CD()



end





----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function B747_set_elec_ER()
	
	
	
end	

function B747_set_warning_ER()
	
    B747DR_sfty_no_smoke_sel_dial_pos = 1
    B747DR_sfty_seat_belts_sel_dial_pos = 1
	
end






----- FLIGHT START ---------------------------------------------------------------------
function B747_flight_start_electric()

    -- ALL MODES ------------------------------------------------------------------------
    B747_set_elec_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B747_set_elec_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B747_set_elec_ER()

    end

end

function B747_flight_start_warning()

    -- ALL MODES ------------------------------------------------------------------------
    B747_set_warning_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B747_set_warning_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B747_set_warning_ER()

    end

end








--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start() 

    B747_flight_start_electric()
	B747_flight_start_warning()

end

--function flight_crash() end

--function before_physics() end

function after_physics()

    B747_battery()
    B747_external_power()
    B747_apu()
    B747_bus_tie()
    B747_generator()
	B747_CAS_queue()
    B747_CAS_display()
	
	B747_warnings_EICAS_msg()

    B747_elec_monitor_AI()
	B747_warning_monitor_AI()

end

--function after_replay() end



