* Project: WB Weather
* Created on: May 2020
* Created by: jdm
* Stata v.16

* does
	* merges weather data into GHSY2 household data
	* does this for north and south seperately

* assumes
	* cleaned GHSY2 data
	* processed wave 2 weather data
	* customsave.ado

* TO DO:
	* complete

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define paths
	loc		rootw 	= 	"$data/weather_data/nigeria/wave_2/refined"
	loc		rooth 	= 	"$data/household_data/nigeria/wave_2/refined"
	loc		export 	= 	"$data/merged_data/nigeria/wave_2"
	loc		logout 	= 	"$data/merged_data/nigeria/logs"

* open log	
	cap log close
	log 	using 		"`logout'/ghsy2_build", append

	
* **********************************************************************
* 1 - merge northern household data with rainfall data
* **********************************************************************

* import the .dta houeshold file
	use 		"`rooth'/hhfinal_ghsy2.dta", clear

* drop southern regions
	drop if		zone == 4 | zone == 5 | zone == 6
	
* generate variable to record data source
	gen 		data = "ghsy2"
	lab var 	data "Data Source"
	
* define local with all sub-folders in it
	loc 		folderList : dir "`rootw'" dirs "ghsy2_rf*"

* define local with all files in each sub-folder	
	foreach 	folder of local folderList {

	* define each file in the above local
		loc 		fileList : dir "`rootw'/`folder'" files "*_n.dta"
	
	* loop through each file in the above local
		foreach 	file in `fileList' {	
	
		* merge weather data with household data
			merge 	1:1 hhid using "`rootw'/`folder'/`file'"	
	
		* drop files that did not merge
			drop 	if 	_merge != 3
			drop 		_merge
		
		*drop variables for all years but 2012
			drop 		mean_season_1983- dry_2011 mean_season_2013- dry_2017
			drop 		mean_period_total_season- z_total_season_2011 ///
						dev_total_season_2013- z_total_season_2017
			drop 		mean_period_raindays- dev_raindays_2011 ///
						dev_raindays_2013- dev_raindays_2017
			drop 		mean_period_norain- dev_norain_2011 ///
						dev_norain_2013- dev_norain_2017
			drop 		mean_period_percent_raindays- dev_percent_raindays_2011 ///
						dev_percent_raindays_2013- dev_percent_raindays_2017
		
		* define file naming criteria
			loc 		sat = substr("`file'", 10, 3)
			loc 		ext = substr("`file'", 7, 2)
			
		* generate variable to record extraction method
			gen 		`sat'_`ext' = "`sat'_`ext'"
			lab var 	`sat'_`ext' "Satellite/Extraction"			
		
		* rename variables by dropping the year suffix
			gen 		v01_`sat'_`ext' = mean_season_2012 if year == 2012
			lab var		v01_`sat'_`ext' "Mean Daily Rainfall"
		
			gen 		v02_`sat'_`ext' = median_season_2012 if year == 2012
			lab var		v02_`sat'_`ext' "Median Daily Rainfall"

			gen 		v03_`sat'_`ext' = sd_season_2012 if year == 2012
			lab var		v03_`sat'_`ext' "Variance of Daily Rainfall"

			gen 		v04_`sat'_`ext' = skew_season_2012 if year == 2012
			lab var		v04_`sat'_`ext' "Skew of Daily Rainfall"

			gen 		v05_`sat'_`ext' = total_season_2012 if year == 2012
			lab var		v05_`sat'_`ext' "Total Rainfall"

			gen 		v06_`sat'_`ext' = dev_total_season_2012 if year == 2012
			lab var		v06_`sat'_`ext' "Deviation in Total Rainfalll"

			gen 		v07_`sat'_`ext' = z_total_season_2012 if year == 2012
			lab var		v07_`sat'_`ext' "Z-Score of Total Rainfall"	

			gen 		v08_`sat'_`ext' = raindays_2012 if year == 2012
			lab var		v08_`sat'_`ext' "Rainy Days"

			gen 		v09_`sat'_`ext' = dev_raindays_2012 if year == 2012
			lab var		v09_`sat'_`ext' "Deviation in Rainy Days"

			gen 		v10_`sat'_`ext' = norain_2012 if year == 2012	
			lab var		v10_`sat'_`ext' "No Rain Days"

			gen 		v11_`sat'_`ext' = dev_norain_2012 if year == 2012
			lab var		v11_`sat'_`ext' "Deviation in No Rain Days"

			gen 		v12_`sat'_`ext' = percent_raindays_2012 if year == 2012
			lab var		v12_`sat'_`ext' "% Rainy Days"

			gen 		v13_`sat'_`ext' = dev_percent_raindays_2012 if year == 2012
			lab var		v13_`sat'_`ext' "Deviation in % Rainy Days"

			gen 		v14_`sat'_`ext' = dry_2012 if year == 2012
			lab var		v14_`sat'_`ext' "Longest Dry Spell"
		
		* drop year variables
			drop 		*2012
		}
}

	
* **********************************************************************
* 2 - merge northern temperature data with household data
* **********************************************************************

* define local with all sub-folders in it
	loc 		folderList : dir "`rootw'" dirs "ghsy2_t*"

* define local with all files in each sub-folder	
	foreach 	folder of local folderList {

* define each file in the above local
	loc 		fileList : dir "`rootw'/`folder'" files "*_n.dta"
	
* loop through each file in the above local
	foreach 	file in `fileList' {	
	
	* merge weather data with household data
		merge 	1:1 hhid using "`rootw'/`folder'/`file'"	
	
		* drop files that did not merge
			drop 	if 	_merge != 3
			drop 		_merge
		
		* drop variables for all years but 2012
			drop 		mean_season_1983- tempbin1002011 ///
						mean_season_2013- tempbin1002017
			drop 		mean_gdd- z_gdd_2011 dev_gdd_2013- z_gdd_2017
		
		* define file naming criteria
			loc 		sat = substr("`file'", 11, 1)
			loc 		ext = substr("`file'", 7, 2)
			
		* generate variable to record extraction method
			gen 		tp`sat'_`ext' = "tp`sat'_`ext'"
			lab var 	tp`sat'_`ext' "Satellite/Extraction"
		
		* rename variables but dropping the year suffix
			gen 		v15_tp`sat'_`ext' = mean_season_2012 if year == 2012
			lab var		v15_tp`sat'_`ext' "Mean Daily Temperature"

			gen 		v16_tp`sat'_`ext' = median_season_2012 if year == 2012
			lab var		v16_tp`sat'_`ext' "Median Daily Temperature"

			gen 		v17_tp`sat'_`ext' = sd_season_2012 if year == 2012
			lab var		v17_tp`sat'_`ext' "Variance of Daily Temperature"

			gen 		v18_tp`sat'_`ext' = skew_season_2012 if year == 2012
			lab var		v18_tp`sat'_`ext' "Skew of Daily Temperature"	

			gen 		v19_tp`sat'_`ext' = gdd_2012 if year == 2012
			lab var		v19_tp`sat'_`ext' "Growing Degree Days (GDD)"	

			gen 		v20_tp`sat'_`ext' = dev_gdd_2012 if year == 2012
			lab var		v20_tp`sat'_`ext' "Deviation in GDD"	

			gen 		v21_tp`sat'_`ext' = z_gdd_2012 if year == 2012
			lab var		v21_tp`sat'_`ext' "Z-Score of GDD"	

			gen 		v22_tp`sat'_`ext' = max_season_2012 if year == 2012
			lab var		v22_tp`sat'_`ext' "Maximum Daily Temperature"

			gen 		v23_tp`sat'_`ext' = tempbin202012 if year == 2012
			lab var		v23_tp`sat'_`ext' "Temperature Bin 0-20"	

			gen 		v24_tp`sat'_`ext' = tempbin402012 if year == 2012
			lab var		v24_tp`sat'_`ext' "Temperature Bin 20-40"	

			gen 		v25_tp`sat'_`ext' = tempbin602012 if year == 2012
			lab var		v25_tp`sat'_`ext' "Temperature Bin 40-60"	

			gen 		v26_tp`sat'_`ext' = tempbin802012 if year == 2012
			lab var		v26_tp`sat'_`ext' "Temperature Bin 60-80"	

			gen 		v27_tp`sat'_`ext' = tempbin1002012 if year == 2012
			lab var		v27_tp`sat'_`ext' "Temperature Bin 80-100"
		
		* drop year variables
			drop 		*2012
	}
}

* save file
	qui: compress
	customsave 	, idvar(hhid) filename("ghsy2_merged_n.dta") ///
		path("`export'") dofile(ghsy2_build) user($user)

	
* **********************************************************************
* 3 - merge southern household data with rainfall data
* **********************************************************************

* import the .dta houeshold file
	use 		"`rooth'/hhfinal_ghsy2.dta", clear

* drop northern regions
	drop if		zone == 1 | zone == 2 | zone == 3
	
* generate variable to record data source
	gen 		data = "ghsy2"
	lab var 	data "Data Source"
	
* define local with all sub-folders in it
	loc 		folderList : dir "`rootw'" dirs "ghsy2_rf*"

* define local with all files in each sub-folder	
	foreach 	folder of local folderList {

	* define each file in the above local
		loc 		fileList : dir "`rootw'/`folder'" files "*_s.dta"
	
	* loop through each file in the above local
		foreach 	file in `fileList' {	
	
		* merge weather data with household data
			merge 	1:1 hhid using "`rootw'/`folder'/`file'"	
	
		* drop files that did not merge
			drop 	if 	_merge != 3
			drop 		_merge
		
		*drop variables for all years but 2012
			drop 		mean_season_1983- dry_2011 mean_season_2013- dry_2017
			drop 		mean_period_total_season- z_total_season_2011 ///
						dev_total_season_2013- z_total_season_2017
			drop 		mean_period_raindays- dev_raindays_2011 ///
						dev_raindays_2013- dev_raindays_2017
			drop 		mean_period_norain- dev_norain_2011 ///
						dev_norain_2013- dev_norain_2017
			drop 		mean_period_percent_raindays- dev_percent_raindays_2011 ///
						dev_percent_raindays_2013- dev_percent_raindays_2017
		
		* define file naming criteria
			loc 		sat = substr("`file'", 10, 3)
			loc 		ext = substr("`file'", 7, 2)
			
		* generate variable to record extraction method
			gen 		`sat'_`ext' = "`sat'_`ext'"
			lab var 	`sat'_`ext' "Satellite/Extraction"			
		
		* rename variables by dropping the year suffix
			gen 		v01_`sat'_`ext' = mean_season_2012 if year == 2012
			lab var		v01_`sat'_`ext' "Mean Daily Rainfall"
		
			gen 		v02_`sat'_`ext' = median_season_2012 if year == 2012
			lab var		v02_`sat'_`ext' "Median Daily Rainfall"

			gen 		v03_`sat'_`ext' = sd_season_2012 if year == 2012
			lab var		v03_`sat'_`ext' "Variance of Daily Rainfall"

			gen 		v04_`sat'_`ext' = skew_season_2012 if year == 2012
			lab var		v04_`sat'_`ext' "Skew of Daily Rainfall"

			gen 		v05_`sat'_`ext' = total_season_2012 if year == 2012
			lab var		v05_`sat'_`ext' "Total Rainfall"

			gen 		v06_`sat'_`ext' = dev_total_season_2012 if year == 2012
			lab var		v06_`sat'_`ext' "Deviation in Total Rainfalll"

			gen 		v07_`sat'_`ext' = z_total_season_2012 if year == 2012
			lab var		v07_`sat'_`ext' "Z-Score of Total Rainfall"	

			gen 		v08_`sat'_`ext' = raindays_2012 if year == 2012
			lab var		v08_`sat'_`ext' "Rainy Days"

			gen 		v09_`sat'_`ext' = dev_raindays_2012 if year == 2012
			lab var		v09_`sat'_`ext' "Deviation in Rainy Days"

			gen 		v10_`sat'_`ext' = norain_2012 if year == 2012	
			lab var		v10_`sat'_`ext' "No Rain Days"

			gen 		v11_`sat'_`ext' = dev_norain_2012 if year == 2012
			lab var		v11_`sat'_`ext' "Deviation in No Rain Days"

			gen 		v12_`sat'_`ext' = percent_raindays_2012 if year == 2012
			lab var		v12_`sat'_`ext' "% Rainy Days"

			gen 		v13_`sat'_`ext' = dev_percent_raindays_2012 if year == 2012
			lab var		v13_`sat'_`ext' "Deviation in % Rainy Days"

			gen 		v14_`sat'_`ext' = dry_2012 if year == 2012
			lab var		v14_`sat'_`ext' "Longest Dry Spell"
		
		* drop year variables
			drop 		*2012
		}
}

	
* **********************************************************************
* 4 - merge northern temperature data with household data
* **********************************************************************

* define local with all sub-folders in it
	loc 		folderList : dir "`rootw'" dirs "ghsy2_t*"

* define local with all files in each sub-folder	
	foreach 	folder of local folderList {

* define each file in the above local
	loc 		fileList : dir "`rootw'/`folder'" files "*_s.dta"
	
* loop through each file in the above local
	foreach 	file in `fileList' {	
	
	* merge weather data with household data
		merge 	1:1 hhid using "`rootw'/`folder'/`file'"	
	
		* drop files that did not merge
			drop 	if 	_merge != 3
			drop 		_merge
		
		* drop variables for all years but 2012
			drop 		mean_season_1983- tempbin1002011 ///
						mean_season_2013- tempbin1002017
			drop 		mean_gdd- z_gdd_2011 dev_gdd_2013- z_gdd_2017
		
		* define file naming criteria
			loc 		sat = substr("`file'", 11, 1)
			loc 		ext = substr("`file'", 7, 2)
			
		* generate variable to record extraction method
			gen 		tp`sat'_`ext' = "tp`sat'_`ext'"
			lab var 	tp`sat'_`ext' "Satellite/Extraction"
		
		* rename variables but dropping the year suffix
			gen 		v15_tp`sat'_`ext' = mean_season_2012 if year == 2012
			lab var		v15_tp`sat'_`ext' "Mean Daily Temperature"

			gen 		v16_tp`sat'_`ext' = median_season_2012 if year == 2012
			lab var		v16_tp`sat'_`ext' "Median Daily Temperature"

			gen 		v17_tp`sat'_`ext' = sd_season_2012 if year == 2012
			lab var		v17_tp`sat'_`ext' "Variance of Daily Temperature"

			gen 		v18_tp`sat'_`ext' = skew_season_2012 if year == 2012
			lab var		v18_tp`sat'_`ext' "Skew of Daily Temperature"	

			gen 		v19_tp`sat'_`ext' = gdd_2012 if year == 2012
			lab var		v19_tp`sat'_`ext' "Growing Degree Days (GDD)"	

			gen 		v20_tp`sat'_`ext' = dev_gdd_2012 if year == 2012
			lab var		v20_tp`sat'_`ext' "Deviation in GDD"	

			gen 		v21_tp`sat'_`ext' = z_gdd_2012 if year == 2012
			lab var		v21_tp`sat'_`ext' "Z-Score of GDD"	

			gen 		v22_tp`sat'_`ext' = max_season_2012 if year == 2012
			lab var		v22_tp`sat'_`ext' "Maximum Daily Temperature"

			gen 		v23_tp`sat'_`ext' = tempbin202012 if year == 2012
			lab var		v23_tp`sat'_`ext' "Temperature Bin 0-20"	

			gen 		v24_tp`sat'_`ext' = tempbin402012 if year == 2012
			lab var		v24_tp`sat'_`ext' "Temperature Bin 20-40"	

			gen 		v25_tp`sat'_`ext' = tempbin602012 if year == 2012
			lab var		v25_tp`sat'_`ext' "Temperature Bin 40-60"	

			gen 		v26_tp`sat'_`ext' = tempbin802012 if year == 2012
			lab var		v26_tp`sat'_`ext' "Temperature Bin 60-80"	

			gen 		v27_tp`sat'_`ext' = tempbin1002012 if year == 2012
			lab var		v27_tp`sat'_`ext' "Temperature Bin 80-100"
		
		* drop year variables
			drop 		*2012
	}
}

* save file
	qui: compress
	customsave 	, idvar(hhid) filename("ghsy2_merged_s.dta") ///
		path("`export'") dofile(ghsy2_build) user($user)

	
* **********************************************************************
* 5 - append northern and southern data sets
* **********************************************************************

* import northern data
	use 		"`export'/ghsy2_merged_n.dta", clear

* append southern data
	append		using "`export'/ghsy2_merged_s.dta", force

* check to verify that there are observations for all variables
	sum
	*** missing observations in z-gdd
	*** this is because those osbervations always have the same number of gdd
	*** thus, they have no standard deviation and thus a z-score of infinity
	*** we recode these as zeros because a z-score equal to 0 represents an element equal to the mean
	
* replace missing z-gdd with missing
	loc	zgdd			v21_*
	foreach v of varlist `zgdd'{
	    replace		`v' = 0 if `v' == .
	}		
	
	qui: compress	
	describe
	summarize 
	
* save file
	customsave 	, idvar(hhid) filename("ghsy2_merged.dta") ///
		path("`export'") dofile(ghsy2_build) user($user)

* erase northern and southern files
	erase		"`export'/ghsy2_merged_n.dta"
	erase		"`export'/ghsy2_merged_s.dta"

* close the log
	log	close

/* END */
