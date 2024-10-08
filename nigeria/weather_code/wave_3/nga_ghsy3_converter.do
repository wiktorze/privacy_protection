* Project: WB Weather
* Created on: April 2020
* Created by: alj
* Stata v.16

* does
	* reads in Nigeria, wave 3 .csv files
	* outputs .dta file ready for processing by the weather program
	* does the above for both rainfall and temperature data

* assumes
	* customsave.ado

* TO DO:
	* completed

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* set user
*	global user "jdmichler" // global user set in TZA_NPS_masterdo

* define paths
	loc root = "$data/weather_data/nigeria/wave_3/raw"
	loc export = "$data/weather_data/nigeria/wave_3/daily"
	loc logout = "$data/weather_data/nigeria/logs"

* open log
	log using "`logout'/nga_ghsy3_converter", replace
	
	
* **********************************************************************
* 1 - converts rainfall data
* **********************************************************************

* define local with all sub-folders in it
	loc folderList : dir "`root'" dirs "GHSY3_rf*"

* loop through each of the sub-folders in the above local
foreach folder of local folderList {
	
	*create directories to write output to
	qui: capture mkdir "`export'/`folder'/"
	
	* define local with all files in each sub-folder	
		loc fileList : dir "`root'/`folder'" files "*.csv"
		
	* loop through each file in the above local	
	foreach file in `fileList' {
		
		* import the .csv files - this takes time	
		import delimited "`root'/`folder'/`file'", varnames (1) clear

		* define locals to govern file naming
			loc dat = substr("`file'", 1, 5)
			loc ext = substr("`file'", 7, 2)
			loc sat = substr("`file'", 10, 3)

		* save file
		customsave , idvar(hhid) filename("`dat'_`ext'_`sat'_daily.dta") ///
			path("`export'/`folder'") dofile(NGA_GHSY3_converter) user($user)
	}
}		


* **********************************************************************
* 2 - converts temperature data
* **********************************************************************

* define local with all sub-folders in it
	loc folderList : dir "`root'" dirs "GHSY3_t*"

* loop through each of the sub-folders in the above local
foreach folder of local folderList {
	
	*create directories to write output to
	qui: capture mkdir "`export'/`folder'/"
	
	* define local with all files in each sub-folder	
		loc fileList : dir "`root'/`folder'" files "*.csv"
		
	* loop through each file in the above local	
	foreach file in `fileList' {
		
		* import the .csv files - this takes time	
		import delimited "`root'/`folder'/`file'", varnames (1) clear

		* define locals to govern file naming
			loc dat = substr("`file'", 1, 5)
			loc ext = substr("`file'", 7, 2)
			loc sat = substr("`file'", 10, 2)

		* save file
		customsave , idvar(hhid) filename("`dat'_`ext'_`sat'_daily.dta") ///
			path("`export'/`folder'") dofile(NGA_GHSY3_converter) user($user)
	}
}

* close the log
	log	close

/* END */
