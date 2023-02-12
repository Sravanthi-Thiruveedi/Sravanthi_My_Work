--1.Write a query to Return the first 6 characters of the "PrimaryDiagnosis" from the "PrimaryDiagnosis" table

select left("PrimaryDiagnosis",6),"PrimaryDiagnosis" as First6Characters from "PrimaryDiagnosis"

--2. Write a query to return the last 4 digits of the Pulse.

select right(cast("Pulse" as varchar),4) as Last4DigitsofPulse from "AmbulatoryVisits"

--3. Write a query using a CTE  to show the first 7 characters from  "PrimaryDiagnosis" 
--and also the lower case version for the Diagnosis_ID=PD005.

with cte as(
select substring("PrimaryDiagnosis" from 1 for 7),lower("Diagnosis_ID") from "PrimaryDiagnosis"
)select * from cte

--or

with cte as(
select left("PrimaryDiagnosis",7),lower("Diagnosis_ID") from "PrimaryDiagnosis"
)select * from cte

--4. Write a query to display the Count of patients discharged by day of week. 
--(Hint- Sunday-0, Monday-1, Tuesday-2, Wednesday-3, Thursday-4, Friday-5, Saturday-6)

select date_part('dow',"DischargeDate") as DayofDischarge,count("Patient_ID") as CountofPatients from "Discharges" 
group by DayofDischarge order by DayofDischarge

--5. Write a query to find how many unique patients are there in public."AmbulatoryVisits".

select distinct count("Patient_ID") as UniqueNumberofPatients from "AmbulatoryVisits"

--6. Write a query to show the count of patients as per Race.

select count("Patient_ID"),r."Race" from "Patients" pa
join "Race" r on pa."Race_ID"=r."Race_ID"
group by r."Race"

--7. write a query using ARRAY_AGG function to get a list of Patient names, Age, Language and Race. 
--( Note : as shown in the output given)

select array_agg(p."FirstName" ||' '|| p."LastName"||' '||age("DateOfBirth")||' '||l."Language"||' '||r."Race") 
from "Patients" p
join "Language" l on p."Language_ID"=l."Language_ID"
join "Race" r on p."Race_ID" = r."Race_ID"
group by p."Patient_ID"

--8. Write the query to mark the patient id as ‘high’ if the pulse rate is greater than 80, ’low’ 
--if pulse rate is less than 60, ‘normal’ if within range.

select "Patient_ID","Pulse",
case
	when "Pulse">80 then 'high'
	when "Pulse"<60 then 'low'
	else 'normal' 
end as PulseRange	
from "AmbulatoryVisits"

--9. Write a query to find out the number of patients with first name 'Aleshia' who was born on '1960-01-01'.

select "FirstName","DateOfBirth",count("Patient_ID") as CountofPatients from "Patients" 
where "FirstName"='Aleshia' and "DateOfBirth"='1960-01-01' group by "FirstName","DateOfBirth"

--10. Write a query to return the last record in descending order of patient id with people having same last name. 
--(Hint -Use windows functions).

select "Patient_ID","LastName",
row_number() over(partition by "LastName" order by "Patient_ID" desc) as rw_num
from "Patients"
order by rw_num desc
limit 1

--11.Write a query to show for each primary diagnosis, no of patients admitted and max expected length of stay. 
--(Hint- Use Window functions).

select p."PrimaryDiagnosis",count(d."Patient_ID") as NumberofPatients,max(d."ExpectedLOS") from "PrimaryDiagnosis" p
join "Discharges" d on p."Diagnosis_ID" = d."Diagnosis_ID"
group by p."PrimaryDiagnosis" 
--doubt
with x as(
select "Patient_ID","Diagnosis_ID","ExpectedLOS",
dense_rank() over(partition by "Diagnosis_ID" order by "ExpectedLOS" desc) as den_rnk
from "Discharges" d
) 
select p."PrimaryDiagnosis",count(x."Patient_ID"),x."ExpectedLOS" from x
join "PrimaryDiagnosis" p on x."Diagnosis_ID"=p."Diagnosis_ID"
group by p."PrimaryDiagnosis",x."ExpectedLOS"
having x."den_rnk"=max(x."den_rnk")


--12.Find the reason of visit for max number of patients.

select r."ReasonForVisit",count(e."Patient_ID") as NumberofPatients from "ReasonForVisit" r
join "EDVisits" e on r."Rsv_ID" = e."Rsv_ID"
group by r."ReasonForVisit" order by NumberofPatients desc limit 1

--13.Write a query to get list of Provider names whose name’s are starting with Mi and ending with rt.

select "ProviderName" from "Providers" where "ProviderName" like 'Mi%rt'

--14.Write a query to Split provider’s First name and Last name into different column.

select split_part("ProviderName",' ',1) as FirstName, split_part("ProviderName",' ',2) as LastName from "Providers"

--15.Write a query to get the list of Patient Names and their Id’s order by their Date of birth to show 1’s 
--who are older ones on top.
--doubt

select "FirstName","LastName","Patient_ID","DateOfBirth" from "Patients" order by "DateOfBirth" desc

--16.Write a query to creating view a on table EDUnique by selecting  PatientID and last 3 columns 
--and also write a query to drop the same View.

create view view_name as
select e."Patient_ID" from "EDVisits" e

--select * from view_name

drop view view_name

--17.Write a query to get list of Patient ID's where Providers ID is 11 and Pulse is between 70 to 90 
--order to view lowest pulse rate on top.

select "Patient_ID","Provider_ID","Pulse" from "AmbulatoryVisits"
where "Provider_ID"=11 and "Pulse" between 70 and 90
order by "Pulse"

--18.Write the query to create Index on table Providers by selecting a column and, also write a query 
--to drop the same index.

create index idx_name on "Providers"("ProviderName")

drop index idx_name 

--19.Write a query to Count number of unique patients EDDisposition wise.

select e1."EDDisposition",count(e2."Patient_ID") as NumberOfPatients from "EDDisposition" e1
join "EDVisits" e2 on e1."EDD_ID"=e2."EDD_ID"
group by e1."EDDisposition"

--20.Write a query to get list of Patient ID's where Visitdepartment ID is 8 or BloodPressureDiastolic is NULL	

select "Patient_ID" from "AmbulatoryVisits" 
where "VisitDepartmentID" = 8 or "BloodPressureDiastolic" IS NULL

--21.Write the query to find the number of patients readmitted by Service.

select s."Service",count(r."Patient_ID") as NumberOfPatients from  "Service" s
join "ReAdmissionRegistry" r on s."Service_ID" = r."Service_ID"
where "ReadmissionFlag"=1
group by s."Service"

--22.Write a query to display the data for all 'White Female' patients above the age of 50, 
--with patients full name. (Hint- Firstname + Lastname)

select p."Patient_ID",concat(p."FirstName",' ',p."LastName") as FullName,date_part('year',age(p."DateOfBirth")) 
as Age,g."Gender",r."Race",l."Language" from "Patients" p
join "Gender" g on p."Gender_ID" = g."Gender_ID"
join "Race" r on p."Race_ID" = r."Race_ID"
join "Language" l on p."Language_ID" = l."Language_ID"
where g."Gender" = 'Female' and r."Race" = 'White' and date_part('year',age(p."DateOfBirth"))>50 
									  
--23.Write a query to calculate the time spent in ED Department for each visit.

select "EDVisit_ID","VisitTimestamp","EDDischargeTimestamp",age("EDDischargeTimestamp","VisitTimestamp") 
as TimeSpent from "EDVisits"

--24.Write a query to find reasonForVisit with highest count of acuity 5 patients.

select r."ReasonForVisit",e."Acuity",count(e."Patient_ID") as NumberOfPatients from "EDVisits" e
join "ReasonForVisit" r on e."Rsv_ID" = r."Rsv_ID"
where "Acuity"=5
group by r."ReasonForVisit",e."Acuity" order by NumberOfPatients desc limit 1

--25.Write a query to show which PrimaryDiagnosis has the biggest difference between maximum and minimum 
--Expected LOS?

select p."PrimaryDiagnosis",(max(d."ExpectedLOS")-min(d."ExpectedLOS")) as difference from "PrimaryDiagnosis" p
join "Discharges" d on p."Diagnosis_ID" = d."Diagnosis_ID"
group by p."PrimaryDiagnosis" order by difference desc limit 1

--26.write a query to get the list of patient ids which are not there in ReadmissionRegistry.

select p."Patient_ID" from "Patients" p
left join "ReAdmissionRegistry" r on p."Patient_ID" = r."Patient_ID"
where r."Patient_ID" is null
--or
select * from "Patients" where "Patient_ID" not in (select "Patient_ID" from "ReAdmissionRegistry")

--27.Write a query to find mean , median and mode for systolic measure.

select avg("BloodPressureSystolic") as Mean,percentile_cont(0.5) within group(order by "BloodPressureSystolic") 
as median, mode() within group(order by "BloodPressureSystolic") as mode1 
from "AmbulatoryVisits"

--28.Write a query to find the 7 characters of PrimaryDiagnosis in lower cases.

select lower(left("PrimaryDiagnosis",7)) from "PrimaryDiagnosis"

--29.Write a query to find the current age of the patients.

select "Patient_ID",date_part('year',age("DateOfBirth")) as Age from "Patients"

--30.Write a query using the Dense_Rank function and display any result of your choice.

select * from
(
select "Patient_ID","Diagnosis_ID","ExpectedMortality",
dense_rank() over(partition by "Diagnosis_ID" order by "ExpectedMortality" desc) as den_rnk
from "Discharges" d
) x
where x.den_rnk<3

--31.Write a query to create a role(any) in postgress via query.
--32.Write a query to list all users in DB.
--33.Write a query to display the Mortality Rate by Primary Diagnosis.

select * from "ReAdmissionRegistry"
--DischargeDisposition"

--34.Write a query to insert a row into the table Primary Diagnosis.
--35.Write a query to modified a row in the Primary Diagnosis.
--36.Write a query to find the ProviderName and Provider Speciality for PS_ID = 'PSID02'.

select p1."ProviderName",p2."ProviderSpeciality" from "Providers" p1
join "ProviderSpeciality" p2 on p1."PS_ID" = p2."PS_ID"
where p1."PS_ID"='PSID02'

--37.Write a query to find Average age for admission by service.

select Avg(date_part('year',age(p."DateOfBirth"))) as avgage,s."Service" from "Patients" p
join "ReAdmissionRegistry" r on p."Patient_ID"=r."Patient_ID"
join "Service" s on r."Service_ID"=s."Service_ID"
group by s."Service"

--38.Write a query to provide month wise count of patients who expired.

select date_part('month',d1."DischargeDate") as monthname,count(d1."Patient_ID") as NumberofPatients 
from "Discharges" d1
join "DischargeDisposition" d2 on d1."Discharge_ID"=d2."Discharge_ID"
where d2."DischargeDisposition" = 'Expired'
group by date_part('month',d1."DischargeDate") order by monthname 

--39.Write a query  to fetch out all details of a patient from system using last name.

select 

--40.Write a function to find patient  name who used ambulance to visit hospital 
--and provider ID is 2 using "EXIST" Function. 

select "FirstName","LastName" from "Patients" p where exists(
select 1 from "AmbulatoryVisits" a where "Provider_ID"=2 and p."Patient_ID" = a."Patient_ID")

--41.Write a query to display count of patients by each providers in year 2019

select p."ProviderName",count(a."Patient_ID") as NumberofPatients from "AmbulatoryVisits" a
join "Providers" p on a."Provider_ID"=p."Provider_ID"
where date_part('year',a."DateofVisit")=2019
group by p."ProviderName"

--42.Write a query to list the Providers with the number of Patients they treated.

select p."ProviderName",count(a."Patient_ID") as NumberofPatients from "AmbulatoryVisits" a
join "Providers" p on a."Provider_ID"=p."Provider_ID"
group by p."ProviderName"

--43.Write a query to find 5 patients with random BloodPressureDiastolic.

select "Patient_ID","BloodPressureDiastolic" from "AmbulatoryVisits"
limit 5

--44.Write a query to get the count of patients by language.

select l."Language",count(p."Patient_ID") as NumberofPatients from "Patients" p
join "Language" l on p."Language_ID" = l."Language_ID"
group by l."Language"

--45.Write a query to get the list of patients who were admitted for 5 days in ICU.

select "Patient_ID" from "Discharges"
where date_part('day',"DischargeDate"-"AdmissionDate")=5

--46.Write a query to list Patient names based on the given Provider.

select p."FirstName",p."LastName",pr."ProviderName" from "Patients" p
join "AmbulatoryVisits" a on p."Patient_ID"=a."Patient_ID"
join "Providers" pr on a."Provider_ID"=pr."Provider_ID"
where pr."ProviderName" = 'Ted Green'

--47.Write a query to get a list of patient ID's whose PrimaryDiagnosis is 'Flu'. order by patient_ID.

select d."Patient_ID" from "Discharges" d
join "PrimaryDiagnosis" p on d."Diagnosis_ID"=p."Diagnosis_ID"
where p."PrimaryDiagnosis" = 'Flu'
order by d."Patient_ID"

--48.Write a query to get list of Patients order by DateOfBirth ascending order.

select "Patient_ID","DateOfBirth" from "Patients"
order by "DateOfBirth" asc

--49.Write a query to display the Firstname and Lastname of patients who speaks ‘Spanish’ language.

select "FirstName","LastName" from "Patients" p
join "Language" l on p."Language_ID" = l."Language_ID"
where l."Language"='Spanish'

--50.Write a query to get list of patient ID's whose PrimaryDiagnosis is 'Heart Failure' and order by patient_ID.

select d."Patient_ID" from "Discharges" d
join "PrimaryDiagnosis" p on d."Diagnosis_ID"=p."Diagnosis_ID"
where p."PrimaryDiagnosis" = 'Heart Failure'
order by d."Patient_ID"

--51.Write a query to find the Patient_ID and Admission_ID for the patients whose Primary diaganosis is ‘Pneumonia’.

select "Patient_ID","Admission_ID" from "ReAdmissionRegistry" r
join "PrimaryDiagnosis" p on r."Diagnosis_ID" = p."Diagnosis_ID"
where p."PrimaryDiagnosis"='Pneumonia'

--52.Write a query to find the list of patient_ID's discharged with Service in SID01, SID02, SID03, SID05.

select "Patient_ID" from "Discharges" where "Service_ID" in('SID01','SID02','SID03','SID05')

--53.Write a query to display the output as below:

select concat('Mr.',"FirstName") as First_Name,"LastName" from "Patients"

--54.Write a query to find first 5 outpatients with lowest pulse rate by using Fetch.

 select d."Patient_ID",a."Pulse" from "Discharges" d
 join "AmbulatoryVisits" a on d."Patient_ID" = a."Patient_ID"
 order by a."Pulse" asc fetch first 5 row only

--55.Write a query to get list of Patients whose gender is ‘Male’ and who speak ‘English’ and whose race is ‘White’.

select p."Patient_ID",g."Gender",r."Race",l."Language" from "Patients" p
join "Gender" g on p."Gender_ID" = g."Gender_ID"
join "Race" r on p."Race_ID" = r."Race_ID"
join "Language" l on p."Language_ID" = l."Language_ID"
where g."Gender" = 'Male' and r."Race" = 'White' and l."Language"='White'

--56.Write a query to get the count of the number of expired patients due to each illness type.

select p."PrimaryDiagnosis",count(d1."Patient_ID") as NumberofPatients from "Discharges" d1
join "PrimaryDiagnosis" p on p."Diagnosis_ID"=d1."Diagnosis_ID"
join "DischargeDisposition" d2 on d1."Diagnosis_ID"=d1."Diagnosis_ID"
where d2."DischargeDisposition" ='Expired'
group by p."PrimaryDiagnosis"

--57.Write a query to get the number of patient visiting each day.

select "DateofVisit",count("Patient_ID") as NumberofPatients from "AmbulatoryVisits"
group by "DateofVisit" order by "DateofVisit"

--58.Write a query to get the number of patients who have at least two visits to the hospital.

select "Patient_ID",count("DateofVisit") as NumberofVisits from "AmbulatoryVisits"
group by "Patient_ID" having count("DateofVisit")>=2

--59.Write a query to create a trigger to execute after inserting a record into Patients table. 
--Insert value to display result. 

--60.Write a query to find the patients whose reason for visit is ‘stomach ache’ and ‘shortness of breath’. 
--Display patientid, firstname, lastname, DOB, gender, reason of visit.

select distinct e."Patient_ID",p."FirstName",p."LastName",p."DateOfBirth",g."Gender",r."ReasonForVisit"
from "EDVisits" e 
join "Patients" p on e."Patient_ID" = p."Patient_ID"
join "Gender" g on p."Gender_ID"=g."Gender_ID"
join "ReasonForVisit" r on e."Rsv_ID" = r."Rsv_ID"
where r."ReasonForVisit" in ('Stomach Ache','Shortness of Breath')

--61.Write a query to display the male patient names and ages whose age is between 30-60.

select p."FirstName",p."LastName",date_part('year',age(p."DateOfBirth")) as Age from "Patients" p
join "Gender" g on p."Gender_ID" = g."Gender_ID"
where date_part('year',age("DateOfBirth")) between 30 and 60 and g."Gender"='Male'

--62.Write a query to show which patient has the 3rd highest expected length of stay for the primary diagnosis Fever. 
--Display the patient’s Firstname, Last name, Gender, Race, Expected LOS, Primary diagnosis.

with t as(
select row_number() over(
order by d."ExpectedLOS" desc
) row_num,
d."Patient_ID",p."FirstName",p."LastName",g."Gender",r."Race",p1."PrimaryDiagnosis",d."ExpectedLOS"
from "Discharges" d 
join "Patients" p on d."Patient_ID" = p."Patient_ID"
join "Gender" g on p."Gender_ID"=g."Gender_ID"
join "Race" r on p."Race_ID"=r."Race_ID"
join "PrimaryDiagnosis" p1 on d."Diagnosis_ID" = p1."Diagnosis_ID"
where p1."PrimaryDiagnosis"='Fever'
)
select * from t where row_num=3

--63.Write a query to create view on table Provider on columns PS_ID and ProviderName.

--64.Write a query to classify the patients based on blood pressure levels using the below conditions:
--Display patient name, Id, blood pressure systolic, blood pressure diastolic and BPRisk.
		
select p."FirstName",p."LastName",a."Patient_ID",a."BloodPressureSystolic",a."BloodPressureDiastolic",
case when (a."BloodPressureSystolic" >=120 and a."BloodPressureSystolic" <130 and a."BloodPressureDiastolic" < 80)
    	then 'Elevated BP'
	 when (a."BloodPressureSystolic" >=130 and a."BloodPressureSystolic" < 140) or (a."BloodPressureDiastolic" >= 80 and a."BloodPressureDiastolic" < 90)
    	then 'Stage 1 Hypertension'
	 when (a."BloodPressureSystolic">=140 or a."BloodPressureDiastolic" >= 90)
    	then 'Stage 2 Hypertension'
end as BPRisk
from "AmbulatoryVisits" a
join "Patients" p on a."Patient_ID" = p."Patient_ID"
		
--65.Write a query to get a list the patients who were admitted in ICU for ‘Pneumonia’.

select "Patient_ID" from "Discharges" d
join "Service" s on d."Service_ID" = s."Service_ID"
join "PrimaryDiagnosis" p on d."Diagnosis_ID"=p."Diagnosis_ID"
where s."Service"='ICU' and p."PrimaryDiagnosis" = 'Pneumonia'

--66.Write a query to get which month had the highest number of readmissions in the year 2018.

select to_char("AdmissionDate",'Month') as AdmissionMonth,count("Patient_ID") as NumberofPatients 
from "ReAdmissionRegistry"
group by AdmissionMonth
order by NumberofPatients desc limit 1

--67.Write a query to get List of female patients over the age of 40 who have undergone surgery from 
--January-March 2019.

select p."Patient_ID",g."Gender",date_part('Year',age(p."DateOfBirth")) as Age,a."DateofVisit",pr."ProviderSpeciality"
from "Patients" p
join "Gender" g on p."Gender_ID"=g."Gender_ID"
join "AmbulatoryVisits" a on p."Patient_ID"=a."Patient_ID"
join "Providers" pr1 on a."Provider_ID"=pr1."Provider_ID"
join "ProviderSpeciality" pr on pr."PS_ID"=pr1."PS_ID"
where pr."ProviderSpeciality"='Surgery' and g."Gender"='Female'
and date_part('month',a."DateofVisit") in (1,2,3)
and date_part('Year',a."DateofVisit")='2019' 
and date_part('Year',age(p."DateOfBirth"))>40

--68.Write a query to display the count of patients whose Readmissionflag is 1.

select count("Patient_ID") as Countofpatients from "ReAdmissionRegistry" where "ReadmissionFlag"=1

--69.Write a query to display  which Service has the highest number of Patients.

select s."Service",count(d."Patient_ID") as NumberofPatients from "Discharges" d
join "Service" s on d."Service_ID" = s."Service_ID"
group by s."Service"
order by NumberofPatients desc limit 1

--70.Write a query to show which Primary Diagnosis has the highest LOS.

select p."PrimaryDiagnosis",(d."DischargeDate"-d."AdmissionDate") as LOS from "Discharges" d
join "PrimaryDiagnosis" p on d."Diagnosis_ID"=p."Diagnosis_ID"
order by LOS desc limit 1

--71.Write a Query to get list of Male patients.

select p."Patient_ID",p."FirstName",p."LastName" from "Patients" p
join "Gender" g on p."Gender_ID"=g."Gender_ID"
where g."Gender"='Male'

--72.Write a query to get a list of patient ID's who were discharged to home.

select d1."Patient_ID" from "Discharges" d1
join "DischargeDisposition" d2 on d1."Discharge_ID"=d2."Discharge_ID"
where d2."DischargeDisposition" = 'Home'

--73.Write a query to find the category of illness(Stomach Ache or Migrane) that has maximum number of patient.

select r."ReasonForVisit",count(e."Patient_ID") as numberofpatients from "EDVisits" e
join "ReasonForVisit" r on r."Rsv_ID" = e."Rsv_ID"
where r."ReasonForVisit" in ('Stomach Ache','Migraine')
group by r."ReasonForVisit"
order by numberofpatients desc limit 1

--74.Write a query to get list of New Patient ID's.

select "Patient_ID" from "ReAdmissionRegistry" where "ReadmissionFlag" is null

--75.Select all providers with a name starting 'h' followed by any character ,followed by 'r', 
--followed by any character,followed by 'y'

select "ProviderName" from "Providers" where "ProviderName" like 'H_r_y%'

--76.Write a query to show the list of the patients who have cancelled their appointment

select a."Patient_ID" from "AmbulatoryVisits" a
join "VisitStatus" v on a."VisitStatus_ID"=v."VisitStatus_ID"
where v."VisitStatus" = 'Canceled'

--77.Write a query to get list of ProviderName's with a name starting 'ted'

select "ProviderName" from "Providers" where "ProviderName" like 'Ted%'

--78.Write a query to show position of letter 'r' in name of the Patients.

select "FirstName",position('r' in "FirstName") as positionofr from "Patients"

--79.Write is query to find the list outpatient names whose first name start with 'W' and categorize Age group wise 
--(Hint : less than 40 are Young Adult ,age between 59-40 are Middle Age Adult and age 60 and 
 --greater than are "Old Adult" )
 
select d."Patient_ID",date_part('year',age(p."DateOfBirth")) as Age,
case 
	when date_part('year',age(p."DateOfBirth"))<40 then 'Young Adult'
	when date_part('year',age(p."DateOfBirth")) between 40 and 59 then 'Middle Age Adult'
	when date_part('year',age(p."DateOfBirth"))>=60 then 'Old Adult'
end as agecategory
from "Discharges" d
join "Patients" p on d."Patient_ID"=p."Patient_ID"
where p."FirstName" like 'W%'

--80.Write a query to find the Provider(s) who has most experience based on Provider Date On Staff.

select *,age("ProviderDateOnStaff") as experience from "Providers"
order by experience desc limit 1

--81.Write a query to show Providers who share same LastName.

select p1."Provider_ID",substring(p1."ProviderName" from position(' ' in p1."ProviderName")) as LastName 
from "Providers" p1
join "Providers" p2
on substring(p1."ProviderName" from position(' ' in p1."ProviderName"))=
substring(p2."ProviderName" from position(' ' in p2."ProviderName"))
and p1."Provider_ID"<>p2."Provider_ID"

--82.Write a query to create a view without using any schema or table and check the created view using 
--select statement.


--83.Write a query to get unique list of Patient Id's whose reason for visit is ‘car accident’.

select e."Patient_ID",r."ReasonForVisit" from "EDVisits" e
join "ReasonForVisit" r on e."Rsv_ID"=r."Rsv_ID"
where r."ReasonForVisit" = 'Car Accident'

--84.Write a query to get the list of patient names whose primary diagnosis as 'Spinal Cord injury' 
--having Expected LOS is greater than 15

select d."Patient_ID",p."PrimaryDiagnosis",d."ExpectedLOS" from "Discharges" d
join "PrimaryDiagnosis" p on d."Diagnosis_ID" = p."Diagnosis_ID"
where p."PrimaryDiagnosis"='Spinal Cord Injury' and d."ExpectedLOS">15

--85.Write a query to get list of Patient names who haven't been discharged.

select p."FirstName",p."LastName" from "Patients" p
left join "Discharges" d on p."Patient_ID"=d."Patient_ID"
where d."Patient_ID" is null

--86.Write a query to get list of Provider names whose ProviderSpecialty is Pediatrics.

select p."ProviderName" from "Providers" p
join "ProviderSpeciality" p1 on p."PS_ID" = p1."PS_ID"
where p1."ProviderSpeciality" = 'Pediatrics'

--87.Write a query to get list of patient ID's who has admitted on 1/7/2018 and discharged on 1/15/2018.

select * from "Discharges" where "AdmissionDate" = '2018-01-07' and date("DischargeDate")= '2018-01-15'

--88.Write a query to find outpatients vs inpatients by monthwise (hint: consider readmission/discharges 
--and ambulatory visits table for inpatients and outpatients).
--doubt
select extract('Month' from a."DateofVisit") as Month,count(d."Patient_ID") as Outpatients,
count(a."Patient_ID") as Inpatients from "Discharges" d
right join "AmbulatoryVisits" a on extract('Month' from d."DischargeDate") = extract('Month' from a."DateofVisit")
group by extract('Month' from d."DischargeDate"),extract('Month' from a."DateofVisit")
order by extract('Month' from a."DateofVisit")

--89.Write a query to get list of Number of Ambulatory Visits by Provider Speciality per month.

select count(a."Provider_ID") as NumberofVisits,p2."ProviderSpeciality",extract('Month' from a."DateofVisit") as month
from "AmbulatoryVisits" a
join "Providers" p1 on a."Provider_ID" = p1."Provider_ID"
join "ProviderSpeciality" p2 on p1."PS_ID" = p2."PS_ID"
group by p2."ProviderSpeciality",month
order by month

--90.Write a query to get list of patient with their full names whose names contains "Ma".

select concat("FirstName",' ',"LastName") as PatientFullname from "Patients" 
where position('ma' in concat("FirstName",' ',"LastName"))>0

--91.Write a query to do Partition the table according to Service_ID and use windows function 
--to  calculate percent rank Order by ExpectedLOS.

select *,
percent_rank() over(partition by "Service_ID" order by "ExpectedLOS")
from "Discharges" 

--92.Write a query by using common table expressions and case statements to  display year of birth ranges. 
--(Ex: 1960-1970)

with cte as
(
	select extract('year' from "DateOfBirth") as Yearofbirth,
	case
		when extract('year' from "DateOfBirth")>=1960 and extract('year' from "DateOfBirth")<1970 then '1960-1970'
		when extract('year' from "DateOfBirth")>=1970 and extract('year' from "DateOfBirth")<1980 then '1970-1980'
		when extract('year' from "DateOfBirth")>=1980 and extract('year' from "DateOfBirth")<1990 then '1980-1990'
	end as DOBRange
	from "Patients"
)
select * from cte

--93.Write a query to get list of Provider names whose ProviderSpeciality is Surgery.

select p."ProviderName" from "Providers" p
join "ProviderSpeciality" p1 on p."PS_ID" = p1."PS_ID"
where p1."ProviderSpeciality" = 'Surgery'

--94.Write a query to get List of patients from rows 11-20 without using WHERE condition. 

select * from "Patients" 
offset 10 rows
fetch next 10 rows only

--95.Write a query as to how to find triggers from table AmbulatoryVisits

--96.Recreate the below expected output using Substring

select "Gender",
case
	when "Gender"='Male' then 'M'
	when "Gender"='Female' then 'F'
end as gender
from "Gender"

--97.Obtain the below output by grouping the patients. 

select "Patient_ID","FirstName",
case
	when "FirstName" like 'L%' then 'L'
end as patient_group
from "Patients"
where "FirstName" like 'L%'

--98.Please go through the below screenshot and create the exact output. 

select "FirstName",char_length("FirstName") as unknown from "Patients"

--99.Please go through the below screenshot and create the exact output.

select "BloodPressureDiastolic","Pulse",ceil("BloodPressureDiastolic") as bpd,floor("Pulse") as heartbeat 
from "AmbulatoryVisits"
offset 1 row
fetch first 21 rows only

--100.Please go through the below screenshot and create the exact output.

select "BloodPressureSystolic",concat('The Systolic Blood pressure is ',round(cast("BloodPressureSystolic" as numeric),1)) as Message
from "AmbulatoryVisits"

