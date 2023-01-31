SELECT * FROM Mech order by mech_no

UPDATE	Mech 
SET		mech_no = REPLACE(RTRIM(mech_no), '"', ''), 
		fname = REPLACE(fname, '"', ''), 
		lname = REPLACE(lname, '"', ''), 
		depot_loc = REPLACE(depot_loc, '"', ''), 
		phone_no = REPLACE(phone_no, '"', ''),
		mech_type = REPLACE(mech_type, '"', '')
		
DELETE Mech WHERE mech_no = '202' AND DEPOT_LOC = 'ALLIANCE'