create database hr; 

use hr;

select * from hr;

describe hr; 

set sql_safe_updates =0;

update hr
set birthdate = case
                when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y')'%Y-%m-%d')
                when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m/%d/%Y')'%Y-%m-%d')
                else null 
                end;
                
alter table hr
modify column birthdate date;

update hr
set hire_date = case
                when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y')'%Y-%m-%d')
                when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m/%d/%Y')'%Y-%m-%d')
                else null 
                end;
                
alter table hr
modify column hire_date date;


UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE; 

-- Add a column as age

alter table hr
add column age int;

update hr
set age = timestampdiff(Year, birthdate, curdate());

-- Find the oldest and the youngest employee

select max(age) as oldest, min(age) as youngest
from hr;

-- How many of the employees has age less than 18

select count(*)
from hr
where age <18;

-- Project 

-- 1. What is the gender breakdown of employees in the company

select gender, count(*) as count
from hr
where age >=18 and termdate = '0000-00-00'
group by gender;


-- 2. What is the race / ethinicity breakdown of employees in the company?

 select race, count(*) as count
 from hr
 where age >=18 and termdate = '0000-00-00'
 group by race
 order by count(*);


-- 3. What is the age distribution of employees in the company?

select case 
            when age >= 18 and age <= 24 then '18-24'
            when age >= 25 and age <= 34 then '25-34'
            when age >= 35 and age <= 44 then '35-44'
            when age >= 45 and age <= 54 then '45-54'
            when age >= 55 and age <= 64 then '45-54'
            else '65+'
end as age_group, gender,
count(*) as count 
from hr
 where age >=18 and termdate = '0000-00-00'
 group by age_group, gender
 order by age_group; 
 
 
 -- 4. How many employees work at headquaters vs remote locations?
 
 select location, count(*) as count
 from hr 
  where age >=18 and termdate = '0000-00-00'
  group by location; 
  
  
  -- 5. What is the average years of employment for employees who have been terminated?
  
  select termdate from hr;
  
  select 
  floor(avg( timestampdiff(Year, hire_date, termdate))) as avg_emp
  from hr
   where age >=18 and termdate <= curdate() and termdate is not null;


-- 6. How does the gender distribution vary across departments?

select department, gender, count(*) as count
from hr
where age >=18 and termdate = '0000-00-00' 
group by gender, department
order by department; 

-- 7. What is the distribution of job title across the company?

select jobtitle, count(*) as count
from hr
where age >=18 and termdate = '0000-00-00' 
group by jobtitle
order by jobtitle desc; 

-- 8. Which department has the highest turnover rate?

select department, total_count, terminated_count, concat(round((terminated_count/total_count)*100,0),'%') as termination_rate
from (
select department, 
	   count(*) as total_count,
       sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >=18 and termdate <> '0000-00-00'
group by department) as subquery
order by termination_rate; 


-- 9. What is the distribution of employees across states?

select location_state, count(*) as count
from hr
where age >=18 and termdate <> '0000-00-00'
group by location_state
order by location_state; 

-- 10. How has the company's employee count changed over time based on hire and termdate?

select year, hires, terminations, (hires-terminations) as net_change, round(((hires-terminations)/hires) *100, 0) as net_change_percent
from (
     select year(hire_date) as year,
     count(*) as hires,
     sum(case when termdate <> '0000-00-00'and termdate <= curdate() then 1 else 0 end )as terminations
     from hr
     where age >=18
     group by year(hire_date)) as subquery
     order by year asc;

-- 11. What is the tenure distribution of each department?

select department, round((timestampdiff(Year, hire_date, termdate)), 0) as avg_tenure
from hr
where termdate <> '0000-00-00'and termdate <= curdate() and age >= 18
group by department;

-- 12. What are the total no. of employees?

select count(distinct(emp_id)) as count
from hr 
where termdate <> '0000-00-00'and termdate <= curdate() and age >= 18;

-- 13. Termination rate

select  total_count, terminated_count, concat(round((terminated_count/total_count)*100,0),'%') as termination_rate
from (
select department, 
	   count(*) as total_count,
       sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >=18 and termdate <> '0000-00-00') as s_query;