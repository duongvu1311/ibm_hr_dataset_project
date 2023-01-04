
## Explore Attrition main reasons
In the previous part, as we dived into the company attrition overview, we came up with a few questions that need further analysis to find the root cause behind it. They are:
* Why do Sales and HR Department have attrition rate higher than the average?
* Why do more people over 50 years old leave the company than people who aged 40-50?
* Why do people with higher pay still leave the company?
* Which factors drive employees who work at company less than 5 years to leave?
Now, let's break down each question and examine other related contributors to find out the answer.

### 1. Sales and HR Department:
**Hypothesis**: _Do employees in Sales and HR leave because they often need to work overtime, to have Business Travel or they do not have enough training for the job?_

Let's find out!

First, we will examine the Business Travel and Overtime factors.
```sql
SELECT
  Department,
  SUM(CASE WHEN BusinessTravel = 'Travel_Frequently' OR BusinessTravel = 'Travel_Rarely' THEN 1 ELSE 0 END) AS count_business_travel,
  SUM(CASE WHEN OverTime = true THEN 1 ELSE 0 END) AS count_overtime,
  SUM(COUNT(*)) OVER(PARTITION BY Department) AS count_attrition_by_department
FROM `hr-project-2022.ibm_hr_dataset.employees`
WHERE Attrition = true AND
      (Department = 'Human Resources' OR Department = 'Sales') 
GROUP BY Department  
```
![Screenshot-2023-01-04-at-3-07-35-PM.png](https://i.postimg.cc/sDMGNKLc/Screenshot-2023-01-04-at-3-07-35-PM.png)

So most of the leaving employees had to have business travel (both rarely and frequently), while around 50% of them had to work overtime often. 

Next, we will see the average training times last year for the resigned employees.
```sql
SELECT 
  Department, JobLevel, 
  ROUND(AVG(TrainingTimesLastYear),2) AS avg_training_by_level,
FROM `hr-project-2022.ibm_hr_dataset.employees`
WHERE Attrition = true AND
      (Department = 'Human Resources' OR Department = 'Sales')
GROUP BY Department, JobLevel
ORDER BY Department, JobLevel
```
![Screenshot-2023-01-04-at-3-21-54-PM.png](https://i.postimg.cc/hvVDkCkJ/Screenshot-2023-01-04-at-3-21-54-PM.png)

Now, if we compare the above results to the average training times by each department:
```sql
SELECT
  Department, 
  ROUND(AVG(TrainingTimesLastYear),2) AS avg_training_by_department
FROM `hr-project-2022.ibm_hr_dataset.employees`
WHERE (Department = 'Human Resources' OR Department = 'Sales')
GROUP BY Department
```
![Screenshot-2023-01-04-at-3-26-51-PM.png](https://i.postimg.cc/C5CZGLL6/Screenshot-2023-01-04-at-3-26-51-PM.png)

It's true that all of the leaving employees received less training times than the average training of their department, especially those employees who are in Human Resources at level 3.

Therefore, the reasons behind high attrition rate in Sales and HR Department are due to:
* Job requires Business Travel and Overtime
* Not enough training received

### 2. Employees over 50 years old 
For this question, I will examine whether job level plays any role in employees attrition for the two age groups: Over 50, and 40-50
```sql
WITH ag AS --employees by age group
(SELECT  
CASE WHEN Age<30 THEN 'Under 30'
       WHEN Age<40 THEN '30 - 40'
       WHEN Age<50 THEN '40 - 50'
  ELSE 'Over 50' END AS Age_group,
*
FROM `hr-project-2022.ibm_hr_dataset.employees`),

ag_attrition AS --attrition with an age group
(SELECT * FROM ag
WHERE Attrition = true),

sub1 AS -- >=40 age group by job level subdata
(SELECT
  ag.Age_group,
  m.JobLevel,
  COUNT(*) AS num_by_level,
FROM `hr-project-2022.ibm_hr_dataset.employees` AS m
INNER JOIN ag
ON m.EmployeeNumber = ag.EmployeeNumber
WHERE ag.Age_group IN ('40 - 50', 'Over 50')
GROUP BY Age_group, JobLevel
ORDER BY Age_group, JobLevel),

sub2 AS --attrition by >=40 age group and job level
(SELECT
  ag_attrition.Age_group,
  m.JobLevel,
  COUNT(*) AS num_attrition,
FROM `hr-project-2022.ibm_hr_dataset.employees` AS m
INNER JOIN ag_attrition
ON m.EmployeeNumber = ag_attrition.EmployeeNumber
WHERE ag_attrition.Age_group IN ('40 - 50', 'Over 50')
GROUP BY Age_group, JobLevel
ORDER BY Age_group, JobLevel)

--Calculate the attrition percentage by job level within the 40-50 and Over 50 age groups
SELECT
  *,
  ROUND(100.0 * num_attrition / num_by_level,1) AS percent_attrition
FROM sub1
LEFT JOIN sub2
USING(Age_group, JobLevel)
ORDER BY Age_group, JobLevel
```
![Screenshot-2023-01-04-at-4-05-57-PM.png](https://i.postimg.cc/zD7QJmNq/Screenshot-2023-01-04-at-4-05-57-PM.png)

In this result, employees over 50 at job level 1 and 2 account for 39.3% of the total attrition in that age group, while in age group 40-50, the number is only 22.5%.


