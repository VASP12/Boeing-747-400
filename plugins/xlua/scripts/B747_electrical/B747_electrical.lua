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


--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local B747_apu_start = 0
local B747_apu_inlet_door_target_pos = 0


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
simDR_electrical_bus_volts          = find_dataref("sim/cockpit2/electrical/bus_volts")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B747DR_button_switch_position       = find_dataref("laminar/B747/button_switch/position")
B747DR_elec_ext_pwr_1_switch_mode   = find_dataref("laminar/B747/elec_ext_pwr_1/switch_mode")
B747DR_elec_ext_pwr_2_switch_mode   = find_dataref("laminar/B747/elec_ext_pwr_2/switch_mode")
B747DR_elec_apu_pwr_1_switch_mode   = find_dataref("laminar/B747/apu_pwr_1/switch_mode")
B747DR_gen_drive_disc_status        = find_dataref("laminar/B747/electrical/generator/drive_disc_status")


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
B747DR_test = create_dataref("test", "number")

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
	
	if B747DR_elec_ext_pwr1_on == 1 or B747DR_elec_ext_pwr2_on == 1
	then
		simDR_gpu_on = 1
	else
		simDR_gpu_on = 0
	end

end

function B747_bus_tie()

	simDR_electrical_bus_volts[0] = 0
	B747DR_test = simDR_electrical_bus_volts[0]
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

--function B747_electrical_EICAS_msg()
	-- BATTERY
	-- APU
	-- APU INLET DOOR
	-- STANDBY POWER
	-- GENERATORS
	-- DRIVE DISCONNECT
	--
--end

function B747_elec_monitor_AI()

    if B747DR_init_elec_CD == 1 then
        B747_set_elec_all_modes()
        B747_set_elec_CD()
        B747DR_init_elec_CD = 2
    end

end

function B747_set_elec_all_modes()
	
	B747DR_init_elec_CD = 0
    B747DR_elec_stby_ignit_sel_pos = 1
    B747DR_elec_auto_ignit_sel_pos = 1

end

function B747_set_elec_CD()

    B747DR_elec_standby_power_sel_pos = 0
    B747DR_elec_apu_sel_pos = 0
    simDR_apu_start_switch_mode = 0

end

function B747_set_elec_ER()
	
	
	
end	

function B747_flight_start_electric()

    B747_set_elec_all_modes()
    if simDR_startup_running == 0 then

        B747_set_elec_CD()

    elseif simDR_startup_running == 1 then

		B747_set_elec_ER()

    end
end

--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start() 

    B747_flight_start_electric()
	

end

--function flight_crash() end

--function before_physics() end

function after_physics()

    B747_battery()
    B747_external_power()
    B747_apu()
    B747_bus_tie()
    B747_generator()
    B747_elec_monitor_AI()

end

--function after_replay() end



