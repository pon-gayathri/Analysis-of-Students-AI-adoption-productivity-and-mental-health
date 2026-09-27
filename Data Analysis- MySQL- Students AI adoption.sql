create database student_AI_adoptability_and_mental_health; 
use student_AI_adoptability_and_mental_health;
select * from indian_students_ai_dataset;

-- Business Insights

-- Q1. classify the mental health of students and count the number of students in each category. 
select gender,
count(case 
          when productivity_score > 90 and mental_wellbeing_score > 90 and sleep_hours > 7 and stress_level <= 1 then 1 end) as Very_good,
count(case	
          when productivity_score between 50 and 90 and
               mental_wellbeing_score between 50 and 90 and 
               sleep_hours between 5 and 7 and 
			   stress_level between 2 and 5
          then 1 end) as Moderate,
count(case	
          when productivity_score < 50 and mental_wellbeing_score < 50 and sleep_hours < 5 and stress_level > 5 then 1 end) as Not_good
from indian_students_ai_dataset
group by gender;
/* There is only 1 male student in "Very good" category, no female students in this category. There are 105 female and 97 male students 
in "Moderate" category. There are 10 female and 6 male students in "Not good" category. Lot of students fall under "Moderate" category*/

-- Q2. classify the students based on their cgpa and in which category the average expected salary is higher? 
select 
case 
    when cgpa >= 9 then "Above 9"
    when cgpa >= 8 then "8 to 9"
    when cgpa >= 6 then "6 to 8"
    else "Below 6"
end as classification, 
round((avg(daily_study_hours)),2) as avg_study_hours,
round((avg(daily_chatgpt_usage_hours)),2) as chatgpt_usage,
round((avg(stress_level)),2) as avg_stress,
round((avg(expected_salary_lpa)),2) as avg_expected_salary,
dense_rank() over(order by round((avg(expected_salary_lpa)),2) desc) as salary_rank
from  indian_students_ai_dataset
group by classification;
-- Average expected salary of students whose CGPA is between 8 to 9 is the highest.

-- Q3. In each branch, the number of students in which placement status is the highest? 
select branch, placement_status, placementwise_count, total_students, percentage, placement_rank
from
    (select e.branch, 
            e.placement_status, 
            t.total_students,
			count(e.student_id) as placementwise_count,
            round((count(e.student_id) * 100/t.total_students),2) as percentage,
            dense_rank() over 
                             (partition by branch order by (count(e.student_id) * 100/t.total_students) desc) as placement_rank
       from indian_students_ai_dataset e 
join
     (select branch, count(student_id) as total_students
      from indian_students_ai_dataset
      group by branch) as t
      on e.branch = t.branch
      group by e.branch, e.placement_status) as subquery
where placement_rank = 1
order by percentage desc;

-- Q4. For each AI dependency level, show the average CGPA, average productivity, average stress level and total students for each placement status.
select ai_dependency_level, 
       placement_status, 
	   round((avg(cgpa)),2) as avg_cgpa, 
       round((avg(productivity_score)),2) as avg_productivity, 
       round((avg(stress_level)),2) as avg_stress,
       count(student_id) as total_students
from indian_student_ai_dataset
where placement_status in ("placed", "internship")
group by ai_dependency_level, placement_status
order by total_students desc;
-- Highest number of students are in category where the AI dependency level is high and placement status is "Placed".

-- Q5. Rank the branch of study by total number of students and also rank the branch of study by total number of placed students.
select e.branch, 
       count(e.student_id) as total_students,
	   dense_rank() over(order by count(e.student_id) desc) as total_students_rank,
       t.placement_status, 
       t.placed_students,
       dense_rank() over(order by t.placed_students desc) as placement_rank
from indian_students_ai_dataset e 
join
    (select branch, 
            placement_status, 
            count(student_id) as placed_students
     from indian_students_ai_dataset 
     where placement_status = "placed"
	 group by branch, placement_status) as t
on e.branch = t.branch
group by e.branch
order by total_students_rank;
/* Branch (CSE) with highest number of students has lower number(rank 6/7) of placed students and 
branch (Civil) with lower number of students rank(6/7) has the highest number of placed students*/

-- Q6. show the mental_wellbeing and ai_repalceability_fear of female and male students agewise and rank them by their mental_wellbeing_score.
select e.gender, 
       e.age, 
       round((avg(e.mental_wellbeing_score)),1) as female_mental_health,
       dense_rank() over (order by round((avg(e.mental_wellbeing_score)),1) desc) as female_mental_health_rank, 
	   round((avg(e.ai_replaceability_fear)),1) as female_ai_replaceablity_fear,
       t.gender, 
       t.male_mental_health, 
       dense_rank() over(order by t.male_mental_health desc) as male_mental_health_rank, 
       t.male_ai_replaceablity_fear
from indian_students_ai_dataset e
join
    (select gender, 
            age, 
            round((avg(mental_wellbeing_score)),1) as male_mental_health, 
            round((avg(ai_replaceability_fear)),1) as male_ai_replaceablity_fear
	from indian_students_ai_dataset
    where gender = "Male"
    group by gender, age) as t
on e.age = t.age
where e.gender = "Female"
group by e.gender, e.age
order by e.gender, e.age;
-- Female students at age 27 has the highest mental wellbeing score and male students at age 24 has the highest mental wellbeing score. 

/* Q7. For each programming language, show the total number of students and average coding hours for each AI dependency level.
Rank the AI dependency level based on the total number of students in each programming language*/
select preferred_programming_language, 
       ai_dependency_level, 
       count(student_id) as total_students,
       dense_rank() over 
                       (partition by  preferred_programming_language order by count(student_id) desc) as AI_dependency_rank,
       round((avg(daily_coding_hours)),2) as avg_coding_hours
from indian_students_ai_dataset
group by  preferred_programming_language, ai_dependency_level
order by  preferred_programming_language, AI_dependency_rank;

-- Q8. Students from which city were placed the most?
select city, 
       placement_status, 
       count(student_id) as placed_students,
	   dense_rank() over (order by count(student_id) desc) as city_rank
from indian_students_ai_dataset
where placement_status = "placed"
group by city, placement_status
order by city_rank;
-- Students from Delhi were placed the most.

-- Q9. Create a function to  view the learning hours and performance of the students.
delimiter ^^
create function learning_hours(study_hours decimal(5,2), chatgpt_usage decimal(5,2), coding_hours decimal(5,2))
returns decimal(5,2)
deterministic
begin
     return study_hours + chatgpt_usage + coding_hours ;
end ^^
delimiter ;

select student_id, gender, age, branch, year_of_study, 
learning_hours(daily_study_hours, daily_chatgpt_usage_hours, daily_coding_hours) as learning_hours, cgpa,
dense_rank() over(order by cgpa desc) as rank_of_students
from indian_students_ai_dataset
order by rank_of_students;

-- Q10. Show the students whose total screentime is above the overall average screentime and CGPA is above 9.
select student_id, total_screen_time, cgpa 
from indian_students_ai_dataset
where
total_screen_time > (select avg(total_screen_time) from indian_students_ai_dataset)
and
cgpa > 9;

/*Q11. Find students whose daily ChatGPT usage hours are above the average of their own branch AND who 
also have a stress level above the overall average stress level. Display their student_id, branch, cgpa, and stress_level.*/

select e.branch, e.student_id, e.cgpa, e.daily_chatgpt_usage_hours, t.avg_chatgpt_usage, e.stress_level
from indian_students_ai_dataset e
join
    (select branch, 
            round((avg(daily_chatgpt_usage_hours)),2) as avg_chatgpt_usage
	 from indian_students_ai_dataset
     group by branch) as t
on e.branch = t.branch
where e.daily_chatgpt_usage_hours > t.avg_chatgpt_usage 
and 
e.stress_level > (select avg(stress_level) from indian_student_ai_dataset)
order by e.branch;

/*Q12. Find the top 2 cities by average expected salary for each preferred programming language. Use window functions and return only rank 1 and 2.*/

select preferred_programming_language, city, avg_salary, city_rank 
from 
    (select preferred_programming_language, 
            city,  
            round((avg(expected_salary_lpa)),2) as avg_salary,
            dense_rank() over 
                             (partition by preferred_programming_language order by avg(expected_salary_lpa) desc) as city_rank
     from indian_students_ai_dataset 
     group by preferred_programming_language, city) as t
where city_rank <= 2
order by preferred_programming_language, city_rank ;

/*Q13. For each branch, find the student who has the highest productivity score but is still "Not Placed".
 Display student_id, branch, productivity_score, cgpa, and expected_salary_lpa.*/
select branch, student_id, cgpa, expected_salary_lpa, placement_status, productivity_score, productivity_rank
from
    (select branch, student_id, cgpa, expected_salary_lpa, placement_status, productivity_score,
     dense_rank() over (partition by branch order by productivity_score desc) as productivity_rank 
	 from indian_students_ai_dataset
     where placement_status = "Not Placed") as t
where productivity_rank = 1
order by branch;

/*Q14. Calculate the percentage contribution of each AI tool's user count to the total student count within each branch. 
 Sort by branch and percentage descending.*/
select e.branch, 
       e.favorite_ai_tool, 
       count(e.student_id) as ai_tool_users, 
       t.total_students,
       round((count(e.student_id) * 100/t.total_students),2) as percentage,
	   dense_rank() over(partition by e.branch order by count(e.student_id) * 100/t.total_students desc) as AI_tool_users_rank
from indian_students_ai_dataset e 
join 
    (select branch, 
            count(student_id) as total_students
     from indian_students_ai_dataset
     group by branch) as t
on e.branch = t.branch
group by e.branch, e.favorite_ai_tool
order by e.branch, percentage desc;

/*Q15. Find branches where the average CGPA of "High" AI dependency students is greater than the average CGPA of "Low" 
AI dependency students in the same branch. Show both averages and the difference.*/
select branch, ai_dependency_level, cgpa_of_high_dependency, cgpa_of_low_depencency 
from
(select e.branch, 
        e.ai_dependency_level, 
        round((avg(e.cgpa)),2) as cgpa_of_high_dependency, 
        t.cgpa_of_low_depencency
from indian_students_ai_dataset e 
join
    (select branch, 
            ai_dependency_level, 
            round((avg(cgpa)),2) as cgpa_of_low_depencency
     from indian_students_ai_dataset  
     where ai_dependency_level = "Low"
     group by branch) as t
on e.branch = t.branch
where e.ai_dependency_level = "High"
group by e.branch, e.ai_dependency_level) as subquery
where cgpa_of_high_dependency > cgpa_of_low_depencency
order by branch;
/* CSE, IT, Mechanical were the branches where the average CGPA of high AI dependency students was greater than the average CGPA 
 of low AI dependency students */
 
/*Q16. Among students who sleep less than 6 hours AND have stress level above 7, find which city has the most number of students 
who are still "Placed". Also show what percentage they are of the total placed students in that city.*/

select e.city, 
       count(e.student_id) as poor_mental_health_students, 
       t.placed_students,
	   count(e.student_id) * 100/t.placed_students as percentage
from indian_students_ai_dataset e 
join
    (select city, 
            count(student_id) as placed_students
     from indian_students_ai_dataset
     where placement_status = "placed"
     group by city) as t
on e.city = t.city
where e.sleep_hours < 6 
      and 
      e.stress_level > 7 
      and 
      e.placement_status = "placed"
group by e.city
order by percentage;
-- Students from Hyderabad who were placed has the most poor mental health compared to placed students from other cities.

/*Q17. Rank the top 3 branches by average CGPA within each city using window functions. Only show branches where the student count is more than 10.*/

select city, branch, avg_cgpa, total_students , d_rank
from
    (select city, branch, avg_cgpa, total_students , d_rank
    from 
        (select city, 
                branch, 
                round((avg(cgpa)),2) as avg_cgpa, 
                count(student_id) as total_students,
                dense_rank() over (partition by city order by avg(cgpa) desc) as d_rank
         from indian_students_ai_dataset
		 group by city, branch) as t
    where d_rank <= 3) as s
where total_students > 10
order by city, d_rank;

/*Q18. Identify students whose daily ChatGPT usage is above the overall average, but whose productivity score is 
below the average of their branch. Display their dependency level, CGPA, and stress level. 
Rank them within each branch based on ChatGPT usage.*/

select e.branch, e.student_id, e.productivity_score, t.avg_productivity_score, e.daily_chatgpt_usage_hours,
       e.ai_dependency_level, e.cgpa, e.stress_level,
	   dense_rank() over (partition by e.branch order by e.daily_chatgpt_usage_hours desc) as d_rank
from indian_students_ai_dataset e 
join 
    (select branch, 
            avg(productivity_score) as avg_productivity_score 
	 from indian_students_ai_dataset
	 group by branch) as t
on e.branch = t.branch 
where  e.productivity_score < t.avg_productivity_score
and 
e.daily_chatgpt_usage_hours > (select avg(daily_chatgpt_usage_hours) as avg_chatgpt_usage_hours
                               from indian_student_ai_dataset);

/*Q19. Find students whose expected salary is greater than the average salary of their branch, but whose CGPA is below the branch average.
 These students have unusually high salary expectations despite relatively lower academic performance.*/
 
select e.branch, e.student_id, e.age, e.gender, e.year_of_study, e.expected_salary_lpa, e.cgpa 
from indian_students_ai_dataset e 
join
    (select branch, 
            avg(expected_salary_lpa) as avg_expected_salary, 
            avg(cgpa) as avg_cgpa
     from indian_students_ai_dataset
	 group by branch) as t
on e.branch = t.branch
where e.expected_salary_lpa > t.avg_expected_salary 
and
e.cgpa < t.avg_cgpa;

/*Q20. Among students who have high productivity (above overall average) and low stress (below overall average), 
determine which AI tool is most commonly used. Also calculate the average salary expectation and placement percentage for each AI tool.*/

select favorite_ai_tool, 
       count(student_id) as total_students, 
       round((avg(expected_salary_lpa)),2) as avg_salary,
       count(case when placement_status = "placed" then 1 end) as placed_students,
       round((count(case when placement_status = "placed" then 1 end) * 100/count(student_id)),2) as percentage
from indian_students_ai_dataset 
where 
productivity_score > (select avg(productivity_score) as avg_productivity from indian_students_ai_dataset)
and
stress_level < (select avg(stress_level) as avg_stress from indian_students_ai_dataset)
group by favorite_ai_tool
order by total_students desc;
-- Chatgpt is the most commonly used AI tool among the students who have high productivity (above overall average) and low stress (below overall average). 