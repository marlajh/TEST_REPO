

/*
This code for weekly crisis high utilizer report.  To be run on Monday of each week.
Recipients as of May 9, 2022 : 
Follett, Adrienne <Adrienne.Follett@kingcounty.gov>; Paz, Brandon <branpaz@kingcounty.gov>; 
Rea Smith, Terra <terra.reasmith@kingcounty.gov>; Smith, Robyn <robysmith@kingcounty.gov>; 
Floyd, Daniel-DCHS <Daniel-DCHS.Floyd@kingcounty.gov>; Hatting, Kristina <khatting@kingcounty.gov>;
Clinton, Shanna <sclinton@kingcounty.gov>; Mitchell, Christopher (DCHS) <chmitch@kingcounty.gov>; 
Hamilton, Jon <jhamilto@kingcounty.gov>

Instructions:  
Run as-is
The code produces two output datasets

The first output dataset goes on the first tab of the excel report document, 
with that tab labelled '3+ Crisis,IP and IT-30 days'.  
Sort order rows by 'crisis_auths_past30day__excludes_IP_IT' (descending order), then by kcid (ascending order)


The second output dataset goes on the second tab of the excel report document, 
with that tab labelled '2+ IT or 5+ Crisis,IP,IT 30 days'. Sort order rows by KCID ( ascending order)
Sort second tab by kcid (ascending order).

With the exception of any NULL values for 'MCO' column on first tab, change all NULL values in the output datasets to 0

*/




use php96

declare @date_30days_prior_to_rundate date,
        @date_90days_prior_to_rundate date,
		@baseline_date date

set  @baseline_date = getdate()
set  @date_30days_prior_to_rundate  = dateadd(dd,-30,getdate() ) 
set  @date_90days_prior_to_rundate  = dateadd(dd,-90,getdate() ) 


drop table if exists #2plusIT_or_5plus_crisis_past_30days 
drop table if exists #crisis_auths_past30days
drop table if exists #business_calls_past30days_by_kcid

drop table if exists #crisis_calls_past30days_by_kcid

drop table if exists #call_log_data__redundant 
drop table if exists #call_log_data__unredundant
drop table if exists #second_tab_of_final_file___2plusIT_or_5plus_crisis_past_30days
drop table if exists #5_or_more_crisis_auths_past30days

drop table if exists #2_or_more_IT_past30days

drop table if exists  #tab1_and_tab2_kcids 
drop table if exists #second_tab_of_final_file___2plusIT_or_5plus_crisis


drop table if exists  #first_tab_of_final_file___3plus_crisis_IP_or_IT_past_30days 
drop table if exists  #MCO_data 
 
drop table if exists #MCO_most_recent_date 


drop table if exists #3_or_more_crisis_auths_past30days


drop table if exists  #crisis_auths_past30days___by_program

drop table if exists #crisis_auths_past30days_excluding_IP_IT

drop table if exists #crisis_auths_past90days

drop table if exists  #call_log_data

create table #business_calls_past30days_by_kcid (
kcid integer,
total_business_calls integer)

create table #crisis_calls_past30days_by_kcid (
kcid integer,
total_crisis_calls integer)


create table #call_log_data__redundant (
kcid integer,
call_date date,
call_type char(33)

) 

create table #call_log_data__unredundant(
kcid integer,
call_date date,
call_type char(33)

) 

 create table #tab1_and_tab2_kcids ( kcid integer) 

 create table #first_tab_of_final_file___3plus_crisis_IP_or_IT_past_30days (

 kcid integer
, CCORS_code_13 integer
, CCORS_Intensive_code_15 integer
, Adult_Crisis_Stabilization_code_40 integer
, Adult_Diversion_Bed_code_74 integer
, Crisis_Triage_Diversion_Bed_DESC_code_75 integer
, Mobile_Crisis_Team_code_76 integer
, Crisis_Diversion_Interim_Services_code_79 integer
, Crisis_Diversion_Facility_Team_code_80 integer
, CORS_YA_code_120 integer
, Involuntary_Treatment_Triage_code_160 integer
, DTX integer
, IP integer
, IT integer
   ,crisis_auths_past30days__excludes_IP_IT  integer
   ,crisis_auths_past30days__includes_IP_IT integer
   ,crisis_auths_past90days__includes_IP_IT integer
   ,MCO char(66)
   ,MCO_yrmo integer
   ,age_today integer
   , today date
  
    )                                               
	  

/* Add a second tab to the final file.  
This second tab obtained by going back to the original 30-day file,
 pivoting on program, and restricting to people with either 2+IT or 5+crisis/IT/IP total
*/

create table #second_tab_of_final_file___2plusIT_or_5plus_crisis_past_30days (
kcid integer
, MCO char(12)
, CCORS_code_13 integer
, CCORS_Intensive_code_15 integer
, Adult_Crisis_Stabilization_code_40 integer
, Adult_Diversion_Bed_code_74 integer
, Crisis_Triage_Diversion_Bed_DESC_code_75 integer
, Mobile_Crisis_Team_code_76 integer
, Crisis_Diversion_Interim_Services_code_79 integer
, Crisis_Diversion_Facility_Team_code_80 integer
, CORS_YA_code_120 integer
, Involuntary_Treatment_Triage_code_160 integer
, DTX integer
, IP integer
, IT integer
,crisis_auths_past30days__includes_IP_IT integer
,Two_plus_IT char(1)
,Five_plus_Crisis_Including_IP_and_IT char(1)

   )   





/* This table contains all the people with 3+ crisis auths (including IP and IT) in past 30 days
 
 */
/* MCO data for left join to final file */

create table #MCO_data (
   kcid integer,
   MCO char(66),
   MCO_yrmo integer
)

/* for each person the final file, ie with 3+ total crisis auths during past 30 days */
/* get date of most recent MCO record from ep_coverage_MCO */

create table #MCO_most_recent_date (
   kcid integer ,
   most_recent_date date
   )

create table #crisis_auths_past30days (
  kcid integer,
  total_crisis_auths_past30days__includes_IP_IT integer
)


/* this table contains all the people in the final file - those with 3+ crisis auths starting past 30 days */

create table #3_or_more_crisis_auths_past30days
(
       kcid integer
      ,total_crisis_auths_past30days__includes_IP_IT integer
)


create table #5_or_more_crisis_auths_past30days
(
       kcid integer
      ,total_crisis_auths_past30days__includes_IP_IT integer
)

create table #2_or_more_IT_past30days
(
       kcid integer
      ,total_IT_auths_past30days integer
)

create table #2plusIT_or_5plus_crisis_past_30days (
    kcid integer
) 

/*  gets count of  total crisis auths by program, for crisis auths starting during last 30 days */

create table #crisis_auths_past30days___by_program
(
       kcid integer
	  ,program char(66)
	  ,program_name char(66)
      ,number_of_auths integer
)




/* This table contains all the people with crisis auths in past 30 days, 
   but only if they have auths other than IP and IT auths
 
   The only reason this table is here to get total crisis auths during past 30 days,
   excluding IP and IT auths.
    
	joining to this table will have to be a left join since it only 
	uses people with auths other than IP and IT during last 30 days */

create table #crisis_auths_past30days_excluding_IP_IT
(
       kcid integer
      ,total_crisis_auths_past30days__excludes_IP_IT  integer
)


/* This table gets total crisis auths during past 90 days but only for 
  people with 3+ crisis auths during past 30 days */

create table #crisis_auths_past90days
(
       kcid integer
      ,total_crisis_auths_past90days__includes_IP_IT integer
)



/*
13
15
40
74
75
76
79
80
120
160
DTX
IP
IT
*/



/*

BULK INSERT #call_log_data__redundant
FROM '\\DCHS-SQLPROD\hoffmanm\crisis and business calls last 30 days.csv'


WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to !=xt row
    TABLOCK
)

*/

insert into #call_log_data__unredundant
select  distinct
kcid ,
call_date ,
call_type 
from  #call_log_data__redundant

     
insert into  #business_calls_past30days_by_kcid 
select kcid, count(*) as total_business_calls
from #call_log_data__unredundant
where call_type = 'business'
and call_date >=	@date_30days_prior_to_rundate  
group by kcid


insert  #crisis_calls_past30days_by_kcid 
select kcid, count(*) as total_crisis_calls
from #call_log_data__unredundant
where call_type = 'crisis'
and call_date >=	@date_30days_prior_to_rundate  
group by kcid

	insert into #crisis_auths_past30days 
	select 
	kcid ,
	count(distinct auth_no) as total_crisis_auths_past30days__includes_IP_IT 
	FROM 	 
	au_master WHERE (start_date >= @date_30days_prior_to_rundate and start_date <= @baseline_date ) 
	--and program in ('IT',  'IP','80', '75', '74', '40', '15', '13', '120','79', 'DTX','76', '160')
	and program in ('13','15','40','74','75','76','79','80','120','160','DTX','IP','IT')
	and status_code <> 'CX'
	group by kcid


                                 


/* This table contains all the people with 3+ crisis auths (including IP and IT) in past 30 days
 
 */

insert into  #3_or_more_crisis_auths_past30days
select kcid
,count(distinct auth_no)  as total_crisis_auths_past30days__includes_IP_IT
	   FROM 
	 
      au_master WHERE (start_date >= @date_30days_prior_to_rundate and start_date <= @baseline_date ) 
	  --and program in ('IT',  'IP','80', '75', '74', '40', '15', '13', '120','79', 'DTX','76', '160')
	  and program in ('13','15','40','74','75','76','79','80','120','160','DTX','IP','IT')
	  and status_code <> 'CX'
	  group by kcid
    having count(distinct auth_no) >= 3

	

/* This table contains all the people with crisis auths in past 30 days, 
   but only if they have auths other than IP and IT auths
 
   To the join to this table to get total crisis auths excluding IP and IT
   will have to be a left join */
insert into #crisis_auths_past30days_excluding_IP_IT
select
       kcid 
      ,count(distinct auth_no) as total_crisis_auths_past30days__excludes_IP_IT 
 FROM 
	 
      au_master WHERE (start_date >= @date_30days_prior_to_rundate  and start_date <= @baseline_date  ) 
	  --and program in ('IT',  'IP','80', '75', '74', '40', '15', '13', '120','79', 'DTX','76', '160')
	  and program in ('13','15','40','74','75','76','79','80','120','160','DTX')
	  and status_code <> 'CX'
	 
	  group by kcid

	  /*  gets people with 5 or more crisis auths during past 30 days */
	  
insert into  #5_or_more_crisis_auths_past30days
select kcid
,count(distinct auth_no)  as total_crisis_auths_past30days__includes_IP_IT
	   FROM 
	 
      au_master WHERE (start_date >= @date_30days_prior_to_rundate and start_date <= @baseline_date  ) 
	  --and program in ('IT',  'IP','80', '75', '74', '40', '15', '13', '120','79', 'DTX','76', '160')
	  and program in ('13','15','40','74','75','76','79','80','120','160','DTX','IP','IT')
	  and status_code <> 'CX'
	  group by kcid
    having count(distinct auth_no) >= 5



  /*  gets people with two or more IT auths during past 30 days */
insert into #2_or_more_IT_past30days
     select kcid
 ,count(distinct auth_no)  as total_IT_auths_past30days 
 FROM 
	 
      au_master WHERE (start_date >= @date_30days_prior_to_rundate and start_date <= @baseline_date  ) 
	  and program = 'IT'
	  and status_code <> 'CX'
	  group by kcid
    having count(distinct auth_no) >= 2



insert into #2plusIT_or_5plus_crisis_past_30days 
   select distinct
    a1.kcid 
	from #5_or_more_crisis_auths_past30days a1
	union
	select distinct
	a2.kcid 
	from #2_or_more_IT_past30days a2
	where a2.kcid not in (select  kcid from #5_or_more_crisis_auths_past30days ) 


/* for people with 3+ crisis auths during past 30 days, include IP and IT, gets total number of crisis auths,
including IP and IT
*/
insert into  #crisis_auths_past90days
select a1.kcid
,count(distinct a1.auth_no)  as total_crisis_auths_past90days__includes_IP_IT
	   FROM  au_master a1
	  join 	#3_or_more_crisis_auths_past30days a2
	  on a1.kcid = a2.kcid
	   WHERE (a1.start_date >= @date_90days_prior_to_rundate and start_date <= @baseline_date  ) 
	  --and program in ('IT',  'IP','80', '75', '74', '40', '15', '13', '120','79', 'DTX','76', '160')
	  and a1.program in ('13','15','40','74','75','76','79','80','120','160','DTX','IP','IT')
	  and a1.status_code <> 'CX'
	  group by a1.kcid
	  -- for validation, direct from Deb's code 13, 15, 40, 74, 75, 76, 79, 80, 120, 160, DTX, IP, IT

/*  Gets count of  total crisis auths by program, for crisis auths starting during last 30 days */

	insert into #crisis_auths_past30days___by_program
  select
	   kcid 	 
	  ,program
	  ,case
	   when program = '13' then 'CCORS-code 13'
	   when program = '15' then 'CCORS Intensive-code 15'
	   when program = '40' then 'Adult Crisis Stabilization-code 40'
	   when program = '74' then 'Adult Diversion Bed-code 74'
	   when program = '75' then 'Crisis Triage Diversion Bed DESC-code 75'
	   when program = '76' then 'Mobile Crisis Team -code 76'
	   when program = '79' then 'Crisis Diversion Interim Services-code 79'
	   when program = '80' then 'Crisis Diversion Facility Team-code 80'
	   when program = '120' then 'CORS-YA -code 120'
	   when program = '160' then 'Involuntary Treatment Triage-code 160'
	   when program = 'DTX' then 'DTX'
	   when program = 'IP' then 'IP'
	   when program = 'IT' then 'IT' 
	   end 
	                                                                         
	   as program_name 
	   , count(distinct auth_no)
	   FROM 
	 
      au_master WHERE (start_date >= @date_30days_prior_to_rundate and start_date <= @baseline_date  ) 
	  --and program in ('IT',  'IP','80', '75', '74', '40', '15', '13', '120','79', 'DTX','76', '160')
	  and program in ('13','15','40','74','75','76','79','80','120','160','DTX','IP','IT')
	  and status_code <> 'CX'
	  --and kcid in (select kcid from  #3_or_more_crisis_auths_past30days)
	  group by kcid
	  ,program
	  ,case
	   when program = '13' then 'CCORS-code 13'
	   when program = '15' then 'CCORS Intensive-code 15'
	   when program = '40' then 'Adult Crisis Stabilization-code 40'
	   when program = '74' then 'Adult Diversion Bed-code 74'
	   when program = '75' then 'Crisis Triage Diversion Bed DESC-code 75'
	   when program = '76' then 'Mobile Crisis Team -code 76'
	   when program = '79' then 'Crisis Diversion Interim Services-code 79'
	   when program = '80' then 'Crisis Diversion Facility Team-code 80'
	   when program = '120' then 'CORS-YA -code 120'
	   when program = '160' then 'Involuntary Treatment Triage-code 160'
	   when program = 'DTX' then 'DTX'
	   when program = 'IP' then 'IP'
	   when program = 'IT' then 'IT'
	   end 
	
insert into #tab1_and_tab2_kcids 
   select distinct
    a1.kcid 
	from #3_or_more_crisis_auths_past30days a1
	union
	select distinct
	a2.kcid 
	from #2plusIT_or_5plus_crisis_past_30days a2	
	                        
insert into  #MCO_most_recent_date
select 
   a1.kcid ,
   max(a2.start_date) as most_recent_date
   from  #tab1_and_tab2_kcids a1
   left join  ep_coverage_MCO a2
   on a1.kcid = a2.kcid
   group by a1.kcid

insert into  #MCO_data
 select 
   a1.kcid 
   ,a2.agency_id MCO 
   ,year(a2.start_date) * 100 + month(a2.start_date) as MCO_yrmo 
   from #MCO_most_recent_date a1
   join ep_coverage_MCO a2
   on a1.kcid = a2.kcid
   and
   a1.most_recent_date = a2.start_date



 insert into #first_tab_of_final_file___3plus_crisis_IP_or_IT_past_30days
   select 
   a1.kcid
   ,a2.number_of_auths as 'CCORS_code_13'
   ,a3.number_of_auths as  'CCORS_Intensive_code_15'
   ,a4.number_of_auths as 'Adult_Crisis_Stabilization_code_40'
   ,a5.number_of_auths as'Adult_Diversion_Bed_code_74'
   ,a6.number_of_auths as 'Crisis_Triage_Diversion_Bed_DESC_code_75'
   ,a7.number_of_auths as 'Mobile_Crisis_Team_code_76'
   ,a8.number_of_auths as  'Crisis_Diversion_Interim_Services_code_79'
   ,a9.number_of_auths as  'Crisis_Diversion_Facility_Team_code_80'
   ,a10.number_of_auths as 'CORS_YA_code_120'
   ,a11.number_of_auths as  'Involuntary_Treatment_Triage_code_160'
   ,a12.number_of_auths as  'DTX'
   ,a13.number_of_auths as 'IP'
   ,a14.number_of_auths as  'IT'
   ,a15.total_crisis_auths_past30days__excludes_IP_IT 
   ,a1.total_crisis_auths_past30days__includes_IP_IT
   ,a16.total_crisis_auths_past90days__includes_IP_IT
   ,a20.MCO
   ,a20.MCO_yrmo
   , datediff(dd,a30.dob, getdate())/365.25   as age_today
   ,getdate() as today


    from 
	#3_or_more_crisis_auths_past30days a1

	left join #crisis_auths_past30days___by_program a2
	on a1.kcid = a2.kcid
	and
	a2.program = '13'
	left join #crisis_auths_past30days___by_program a3
	on a1.kcid = a3.kcid
	and
	a3.program = '15'
	left join #crisis_auths_past30days___by_program a4
	on a1.kcid = a4.kcid
	and
	a4.program = '40'
	left join #crisis_auths_past30days___by_program a5
	on a1.kcid = a5.kcid
	and
	a5.program = '74'
	left join #crisis_auths_past30days___by_program a6
	on a1.kcid = a6.kcid
	and
	a6.program = '75'
	left join #crisis_auths_past30days___by_program a7
	on a1.kcid = a7.kcid
	and
	a7.program = '76'

	
	left join #crisis_auths_past30days___by_program a8
	on a1.kcid = a8.kcid
	and
	a8.program = '79'
	left join #crisis_auths_past30days___by_program a9
	on a1.kcid = a9.kcid
	and
	a9.program = '80'
	left join #crisis_auths_past30days___by_program a10
	on a1.kcid = a10.kcid
	and
	a10.program = '120'
	left join #crisis_auths_past30days___by_program a11
	on a1.kcid = a11.kcid
	and
	a11.program = '160'
	left join #crisis_auths_past30days___by_program a12
	on a1.kcid = a12.kcid
	and
	a12.program = 'DTX'
	left join #crisis_auths_past30days___by_program a13
	on a1.kcid = a13.kcid
	and
	a13.program = 'IP'
		left join #crisis_auths_past30days___by_program a14
	on a1.kcid = a14.kcid
	and
	a14.program = 'IT'
	left join #crisis_auths_past30days_excluding_IP_IT a15
	on a1.kcid = a15.kcid
	left join #crisis_auths_past90days a16
	on a1.kcid = a16.kcid
	left join #MCO_data a20
	on a1.kcid = a20.kcid
	join g_person a30
	on a1.kcid = a30.kcid




	 insert into #second_tab_of_final_file___2plusIT_or_5plus_crisis_past_30days
   select 
   a1.kcid
   ,a100.MCO
   ,a2.number_of_auths as 'CCORS_code_13'
   ,a3.number_of_auths as  'CCORS_Intensive_code_15'
   ,a4.number_of_auths as 'Adult_Crisis_Stabilization_code_40'
   ,a5.number_of_auths as'Adult_Diversion_Bed_code_74'
   ,a6.number_of_auths as 'Crisis_Triage_Diversion_Bed_DESC_code_75'
   ,a7.number_of_auths as 'Mobile_Crisis_Team_code_76'
   ,a8.number_of_auths as  'Crisis_Diversion_Interim_Services_code_79'
   ,a9.number_of_auths as  'Crisis_Diversion_Facility_Team_code_80'
   ,a10.number_of_auths as 'CORS_YA_code_120'
   ,a11.number_of_auths as  'Involuntary_Treatment_Triage_code_160'
   ,a12.number_of_auths as  'DTX'
   ,a13.number_of_auths as 'IP'
   ,a14.number_of_auths as  'IT'  

   ,a30.total_crisis_auths_past30days__includes_IP_IT 
   ,
   case
   when a14.number_of_auths >= 2 then 'Y'
   when a14.number_of_auths < 2 or a14.number_of_auths is null then 'N'
   end
   as Two_plus_IT 
   ,
   case
   when a30.total_crisis_auths_past30days__includes_IP_IT >= 5 then 'Y'
   when a30.total_crisis_auths_past30days__includes_IP_IT  < 5 or a30.total_crisis_auths_past30days__includes_IP_IT is null then 'N'
   end
   as Five_plus_Crisis_Including_IP_and_IT 
    from 
	#2plusIT_or_5plus_crisis_past_30days  a1

	left join #crisis_auths_past30days___by_program a2
	on a1.kcid = a2.kcid
	and
	a2.program = '13'
	left join #crisis_auths_past30days___by_program a3
	on a1.kcid = a3.kcid
	and
	a3.program = '15'
	left join #crisis_auths_past30days___by_program a4
	on a1.kcid = a4.kcid
	and
	a4.program = '40'
	left join #crisis_auths_past30days___by_program a5
	on a1.kcid = a5.kcid
	and
	a5.program = '74'
	left join #crisis_auths_past30days___by_program a6
	on a1.kcid = a6.kcid
	and
	a6.program = '75'
	left join #crisis_auths_past30days___by_program a7
	on a1.kcid = a7.kcid
	and
	a7.program = '76'

	
	left join #crisis_auths_past30days___by_program a8
	on a1.kcid = a8.kcid
	and
	a8.program = '79'
	left join #crisis_auths_past30days___by_program a9
	on a1.kcid = a9.kcid
	and
	a9.program = '80'
	left join #crisis_auths_past30days___by_program a10
	on a1.kcid = a10.kcid
	and
	a10.program = '120'
	left join #crisis_auths_past30days___by_program a11
	on a1.kcid = a11.kcid
	and
	a11.program = '160'
	left join #crisis_auths_past30days___by_program a12
	on a1.kcid = a12.kcid
	and
	a12.program = 'DTX'
	left join #crisis_auths_past30days___by_program a13
	on a1.kcid = a13.kcid
	and
	a13.program = 'IP'
	left join #crisis_auths_past30days___by_program a14
	on a1.kcid = a14.kcid
	and
	a14.program = 'IT'
	left join  #crisis_auths_past30days a30
	on a1.kcid = a30.kcid
	left join #MCO_data a100
	on a1.kcid = a100.kcid

	select * from #first_tab_of_final_file___3plus_crisis_IP_or_IT_past_30days

	select * from #second_tab_of_final_file___2plusIT_or_5plus_crisis_past_30days