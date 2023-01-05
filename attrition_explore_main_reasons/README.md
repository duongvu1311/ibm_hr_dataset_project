
## Explore Attrition main reasons
In the previous part, as we dived into the company attrition overview, we came up with a few questions that need further analysis to find the root cause behind it. They are:
* Why do more people over 50 years old leave the company than people who aged 40-50?
* Why do people with higher pay still leave the company?
* Which factors drive employees who work at company less than 5 years to leave?

Now, let's break down each question and examine other related contributors to find out the answer.


### 1. Employees over 50 years old 
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

### 2. Employees with higher pay:
In the previous part, the top employees with higher than average pay that still leave are:

Department | Job Level | $ higher than monthly average
--- | --- | ---
HR | 3 | $593 
R&D | 5 | $331.5 
Sales | 5 | $246.5

I will check on the Job Involvement, Job Satisfaction, Environment Satisfaction, and Training Time Last Year factors.
```sql
WITH filter AS --create subdata for the targeted employees
(SELECT *
FROM `hr-project-2022.ibm_hr_dataset.employees` 
WHERE Attrition = true AND
      ((JobLevel = 3 AND Department = 'Human Resources') OR
      ((JobLevel = 5 AND Department = 'Sales') OR (JobLevel = 5 AND Department = 'Research & Development')))
)
SELECT
      JobLevel,
      CASE WHEN (JobSatisfaction <3 OR JobInvolvement <3) THEN 'true' ELSE 'false' END AS job_unsatisfied,
      CASE WHEN EnvironmentSatisfaction <3 THEN 'true' ELSE 'false' END AS env_unsatisfied,
      TrainingTimesLastYear
FROM filter
ORDER BY JobLevel
```
![Screenshot-2023-01-04-at-5-39-29-PM.png](https://i.postimg.cc/tgvPC8Pf/Screenshot-2023-01-04-at-5-39-29-PM.png)

In order to compare the training times easily, here are the average training times last year per department:
```sql
SELECT
  Department, 
  ROUND(AVG(TrainingTimesLastYear),2) AS avg_training_by_department
FROM `hr-project-2022.ibm_hr_dataset.employees`
GROUP BY Department
```
![Screenshot-2023-01-05-at-6-59-06-PM.png](https://i.postimg.cc/FHzLTNkn/Screenshot-2023-01-05-at-6-59-06-PM.png)

* For HR-level 3 employees: they left because they were both unsatisfied with the job and environment. Besides, their training times were less than the average (2.56 for HR Dept)
* For level 5 employees: they left mostly due to job dissatisfaction. 

### 3. Employees with YearsAtCompany <=5
In this part, I will check their Satisfaction on the job, environment, relationship, as well as the average years that they stayed at their previous companies.

First, I will count how many of those employees left with Low Satisfaction on the three areas.
```sql 
SELECT 
  SUM(CASE WHEN JobSatisfaction=1 THEN 1 ELSE 0 END) AS job_unsatisfied,
  SUM(CASE WHEN EnvironmentSatisfaction=1 THEN 1 ELSE 0 END) AS env_unsatisfied,
  SUM(CASE WHEN RelationshipSatisfaction=1 THEN 1 ELSE 0 END) AS rela_unsatisfied
FROM `hr-project-2022.ibm_hr_dataset.employees` 
WHERE YearsAtCompany <=5 AND Attrition =true
```
![Screenshot-2023-01-05-at-11-08-57-AM.png](https://i.postimg.cc/GpxSkjFP/Screenshot-2023-01-05-at-11-08-57-AM.png)

We can easily see that **environment dissatisfaction** has the highest vote.

Next, I will check the average years that these employees stayed at their previous companies and compare it to the average of the whole company.
```sql
WITH sub AS --create a subdata that calculate the average years per previous company
(SELECT 
  *,
  CASE WHEN NumCompaniesWorked = 0 THEN TotalWorkingYears ELSE TotalWorkingYears/ NumCompaniesWorked END AS years_per_company 
--if that employee never worked at any company before, then years_per_company = total_working_years
FROM `hr-project-2022.ibm_hr_dataset.employees`)

SELECT
  Attrition,
  ROUND(AVG(sub.years_per_company),1) AS avg_years
FROM `hr-project-2022.ibm_hr_dataset.employees` AS main
INNER JOIN sub
USING(Attrition)
GROUP BY Attrition
```
![Screenshot-2023-01-05-at-11-32-03-AM.png](https://i.postimg.cc/QtH67Z05/Screenshot-2023-01-05-at-11-32-03-AM.png)

_So the average years of **total attrition ones** are **4.2**_

Now, let's see the number for the ones who stay less than 5 years. I will just use the same queries and add another filter for YearsAtCompany.

```sql
WITH sub AS --create a subdata that calculate the average years per previous company (for YearsAtCompany <=5 years)
(SELECT 
  *,
  CASE WHEN NumCompaniesWorked = 0 THEN TotalWorkingYears ELSE TotalWorkingYears/ NumCompaniesWorked END AS years_per_company 
--if that employee never worked at any company before, then years_per_company = total_working_years
FROM `hr-project-2022.ibm_hr_dataset.employees`
WHERE YearsAtCompany <=5)

SELECT
  Attrition,
  ROUND(AVG(sub.years_per_company),1) AS avg_years
FROM `hr-project-2022.ibm_hr_dataset.employees` AS main
INNER JOIN sub
USING(Attrition)
GROUP BY Attrition
```
![Screenshot-2023-01-05-at-11-41-14-AM.png](https://i.postimg.cc/MKF1cfgs/Screenshot-2023-01-05-at-11-41-14-AM.png)

So the attrition ones, who left after 5 years or less at current company, have the average **2.2 years** at previous employers. This number is a big difference compared to the total 4.2. 

_Overall, employees who worked less than or equal to 5 years in this company left with Low Satisfaction of the environment, and in their work history, they also have low average years (2.2) per company._
