-- Boeing 747-400 Inertial Reference System
-- Version: 0.0.1
-- Authors: Reddeviln, YesAviation (Daniel)

simDR_latitude					= find_dataref("sim/flightmodel/position/latitude")
simDR_longitude					= find_dataref("sim/flightmodel/position/longitude")
B747DR_irsL_status        		= find_dataref("laminar/B747/flt_mgmt/iru/mode_sel_dial_pos[0]")
B747DR_irsC_status        		= find_dataref("laminar/B747/flt_mgmt/iru/mode_sel_dial_pos[1]")
B747DR_irsR_status        		= find_dataref("laminar/B747/flt_mgmt/iru/mode_sel_dial_pos[2]")
simDR_onground            		= find_dataref("sim/flightmodel/failures/onground_all")
simDR_battery_on                = find_dataref("sim/cockpit2/electrical/battery_on")
B747DR_CAS_warning_status       = find_dataref("laminar/B747/CAS/warning_status")
B747DR_CAS_advisory_status      = find_dataref("laminar/B747/CAS/advisory_status")

local irsL_aligned = 0
local irsC_aligned = 0
local irsR_aligned = 0
local irs_aligned_all = 0
test = create_dataref("irutest","numbers")

function decimal_to_DegMinSec(decimal)

degree = math.modf(decimal)
minutes = math.modf(math.modf(math.abs(decimal)*60)%60)
seconds = math.modf(math.modf(math.abs(decimal)*3600)%60)
return degree,minutes,seconds
end

function IRS_system()
	if (simDR_battery_on == 0) then
		return
	end
	(latdeg,latmin,latsec) = decimal_to_DegMinSec(simDR_latitude)
	(londeg,lonmin,lonsec) = decimal_to_DegMinSec(simDR_longitude)
	if(irs_aligned_all == 0 && simDR_onground == 1) then
		if(irs_alignedL == 0) then
			if(math.abs(latdeg)<82) then
				if(B747DR_irsL_status == 2) then
					start_irsL_align()
				elseif(B747DR_irsL_status == 3) then
					start_irsL_att_align()
				end
			else
				-- high latitude alignment necessary
				if(B747DR_irsL_status ==1) then 
					start_irsL_highlat_align()
				else 
					B747DR_CAS_advisory_status[232] == 1
					B747DR_CAS_advisory_status[302] == 1
				end
		end 
		if(irs_alignedC == 0) then
			if(math.abs(latdeg)<82) then
				if(B747DR_irsC_status == 2)then
					start_irsC__align()
				elseif(B747DR_irsC_status == 3)then
					start_irsC_att_align()
				end
			else
				-- high latitude alignment necessary
				if(B747DR_irsC_status ==1)then
					start_irsC_highlat_align()
				else 
					B747DR_CAS_advisory_status[228] == 1
					B747DR_CAS_advisory_status[302] == 1
				end
			end
		end
		if(irs_alignedR == 0) then
			if(math.abs(latdeg)<82) then
				if(B747DR_irsR_status == 2) then
					start_irsR_align()
				elseif(B747DR_irsR_status == 3) then
					start_irsR_att_align()
				end
			end
			else
				-- high latitude alignment necessary
				if(B747DR_irsR_status ==1) then
					start_irsR_highlat_align()
				else 
					B747DR_CAS_advisory_status[234] == 1
					B747DR_CAS_advisory_status[302] == 1
				end
			end
		end
	end
	if(irs_alignedL == 1 && simDR_onground == 1) then
		if(B747DR_irsL_status == 0) then
			irsL_shutdown()
		elseif (B747DR_irsL_status == 1) then
			irsL_realign()
		elseif (B747DR_irsL_status == 3) then
			irsL_att_realign()
		end
	end
	if(irs_alignedC == 1 && simDR_onground == 1) then
		if(B747DR_irsC_status == 0) then
			irsC_shutdown()
		elseif (B747DR_irsC_status == 1) then
			irsC_realign()
		elseif (B747DR_irsC_status == 3) then
			irsC_att_realign()
		end
	end
	if(irs_alignedR == 1 && simDR_onground == 1) then
		if(B747DR_irsR_status == 0) then
			irsR_shutdown()
		elseif (B747DR_irsR_status == 1) then
			irsR_realign()
		elseif (B747DR_irsR_status == 3) then
			irsR_att_realign()
		end
	end
	if(irs_alignedL == 1 && simDR_onground == 0) then
		if(B747DR_irsL_status == 0) then
			irsL_shutdown()
		if(B747DR_irsL_status == 1) then
			irsL_shutdown()
		elseif (B747DR_irsL_status == 3) then
			irsL_att_realign()
		end
	end
	if(irs_alignedC == 1 && simDR_onground == 0) then
		if(B747DR_irsC_status == 0) then
			irsC_shutdown()
		if(B747DR_irsC_status == 1) then
			irsC_shutdown()
		elseif (B747DR_irsC_status == 3) then
			irsC_att_realign()
		end
	end
	if(irs_alignedR == 1 && simDR_onground == 0) then
		if(B747DR_irsL_status == 0) then
			irsR_shutdown()
		if(B747DR_irsL_status == 1) then
			irsR_shutdown()
		elseif (B747DR_irsR_status == 3) then
			irsR_att_realign()
		end
	end
end

			
		
		

	



