# Analysis of Students AI-adoption Productivity and Mental Health

## Project Overview
Analysis of Students' AI adoption, productivity and mental health using Python, MySQL and Power BI.

## Dataset
- Source : Kaggle
- Size : 3,000 rows

## Tools Used
- Python (Pandas, Numpy, Stats)
- MySQL
- Power BI

## What I did
- Cleaned and analyzed a 3,000-row dataset - handled missing values, checked for duplicates and outliers, created new calculated columns.
- Performed statistical analysis (Two Sample T-Test, Correlation, Probability, Anova, Descriptive statistics) to identify patterns in AI usage and mental health.
- Wrote 20 MySQL queries using Joins, window functions, subqueries, CASE statements, user-defined function.
- Built a 3-page interactive Power BI dashboard with 15 visualizations, cards, slicers and DAX measures.

## Key Insights

### Statistical Analysis
-	Correlation analysis revealed no significant relationship between students' CGPA and study hours. The students’ CGPA is not related to their study hours, that is, the students’ CGPA didn’t increase if the study hours increased. 
-	Two sample t-test results indicate that the students with high AI dependency and students with Low AI dependency have the same average CGPA, there is no significant difference in their academic performance based  on their AI dependency level.
- Anova results suggest that there is no significant difference in the AI replaceability fear of students across different branches of study. Students in different branches have same level of AI replaceability fear.
  
### CGPA, Branch and Salary Expectation of Students:
- Students with CGPA between 8 to 9 have high salary expectations.
- CSE branch has the highest number of students.
- There are more number of students (378) who have low CGPA and high salary expectation than the students(290) who have high CGPA and high salary expectation.

### Placement Status 
- There are more students who were not placed compared to students who were placed and students who were doing internship.
- More number of students got placed from Civil branch compared to other branches.
- Students from Delhi were placed the most.
  
### AI Usage 
- Claude was the most used AI tool compared to other AI tools according to this dataset.
  
### Preferred programming language 
- C++ (757) and Javascript (756) are the most preferred programming languages.

### AI dependency level 
- In the high AI dependency level category, there were more number of placed students, in medium AI dependency level category, there were more number of students who were not placed and in the low AI dependency level category, there were more number of students who were not placed.
- CSE, IT, Mechanical were the branches where the CGPA of students with high AI dependency students was greater than the CGPA of students with
 of low AI dependency students
- Students (343) who have high AI dependency level were placed more than the students who have medium and low AI dependency level.

### Stress level 
- Average stress level of students(5.43) was slightly higher than the acceptable stress limit(5).
- Students in electrical department has the highest level of stress compared to students in other branches.
- Students who were placed, not placed and doing internship all have the same level of stress.
  
### Productivity 
- Students at the age of 28 have the highest level of productivity.

### Mental wellbeing 
- students at the age of 24 have the highest score of mental wellbeing.
- Students who were placed have the highest score of mental wellbeing compared to students who were not placed and students who were doing internship.
-	Only one male student has a very good mental health. Lot of students (202) have moderate mental health and very few students(16) have poor mental health according to this dataset.
