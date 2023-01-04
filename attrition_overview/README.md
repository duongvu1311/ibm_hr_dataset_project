## Attrition Overview

Calculate the Attrition Rate and summarize attrition by:
* Gender
* Department
* Age
* Average monthly income by job level
* Years at company

### 1. Attrition Rate
```sql 
SELECT
  Attrition,
  CONCAT(ROUND(100.0 * COUNT(*)/ SUM(COUNT(*)) OVER(),1),'%') AS Attrition_rate
FROM `hr-project-2022.ibm_hr_dataset.employees` 
GROUP BY Attrition
```
![Screenshot-2023-01-04-at-10-37-20-AM.png](https://i.postimg.cc/76wxBD6J/Screenshot-2023-01-04-at-10-37-20-AM.png)

The attrition rate of this company is 16.1%

### 2. Attrition by Gender
```sql
SELECT
  Attrition,
  Gender,
  COUNT(Gender) AS Count_gender,
  ROUND(100.0 * COUNT(*)/ SUM(COUNT(*)) OVER(PARTITION BY Gender),1) AS Attrition_by_gender
FROM `hr-project-2022.ibm_hr_dataset.employees` 
GROUP BY Attrition, Gender
ORDER BY Attrition_by_gender
```
![Screenshot-2023-01-04-at-10-45-03-AM.png](https://i.postimg.cc/CxRH1pw8/Screenshot-2023-01-04-at-10-45-03-AM.png)

Attrition rate of Male is higher than Female, 17.0% and 14.8% respectively.

### 3. Attrition by Department
```sql
SELECT
  Department,
  Attrition,
  COUNT(*) AS num,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY Department),2) AS percent
FROM `hr-project-2022.ibm_hr_dataset.employees`
GROUP BY Department, Attrition
```
![Screenshot-2023-01-04-at-10-50-03-AM.png](https://i.postimg.cc/50K2jT4H/Screenshot-2023-01-04-at-10-50-03-AM.png)

* Sales department has the highest attrition rate (20.63%)
* The rate of Human Resources department is also high, at 19.05%, which is higher than the overall rate (16.1%)

### 4. Attrition by Age groups
```sql
-- Create Age_group
WITH ag AS
(SELECT
  *,
  CASE WHEN Age<30 THEN 'Under 30'
       WHEN Age<40 THEN '30 - 40'
       WHEN Age<50 THEN '40 -50'
  ELSE 'Over 50' END AS Age_group
FROM `hr-project-2022.ibm_hr_dataset.employees`)

--Join with main data
SELECT
  m.Attrition,
  ag.Age_group,
  COUNT(*) AS num, --number of attrition value by age group
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY ag.Age_group),2) AS percent_by_age --percent of attrition by age group
FROM `hr-project-2022.ibm_hr_dataset.employees` m
INNER JOIN ag
ON m.EmployeeNumber = ag.EmployeeNumber
GROUP BY m.Attrition, ag.Age_group
ORDER BY percent_by_age DESC
```
![Screenshot-2023-01-04-at-11-02-06-AM.png](https://i.postimg.cc/BvLjHJzT/Screenshot-2023-01-04-at-11-02-06-AM.png)

* Employees who are under 30 years old have the highest attrition rate (27.91%)
* Employees over 50 years old tend to leave more than those who are 40-50 years old, which is strange. Do they leave because of retirement or any other root causes behind? We will explore this further in the next _Attrition Explore_ part.

### 5. Attrition by Monthly Income 
```sql
WITH sub1 AS --average income per job level for each department
(SELECT
  Department,
  JobLevel,
  ROUND(AVG(MonthlyIncome),1) AS avg_income
FROM `hr-project-2022.ibm_hr_dataset.employees` 
GROUP BY Department, JobLevel),

sub2 AS --average attrition income
(SELECT
  Department,
  JobLevel,
  ROUND(AVG(MonthlyIncome),1) AS attrition_avg_income
FROM `hr-project-2022.ibm_hr_dataset.employees`
WHERE Attrition = true
GROUP BY Department, JobLevel)

--show avg_income, attrition_avg_income and their difference
--to test whether employees left because they were underpaid?
SELECT 
  *,
  ROUND(sub2.attrition_avg_income - sub1.avg_income,1) AS difference
FROM sub1
INNER JOIN sub2
USING(Department, JobLevel)
ORDER BY Department, JobLevel
```
![Screenshot-2023-01-04-at-12-34-22-PM.png](https://i.postimg.cc/zD6x9Y4V/Screenshot-2023-01-04-at-12-34-22-PM.png) 

So overall, most of the employees left because they are underpaid compared to the average salary for that job level within their department.
However, both job level 2 and 5 in R&D and Sales, as well as job level 3 in HR, are paid slightly more than the average, yet they still left. We will discuss this further in the next Exploration part.

### 6. Attrition by Years At Company
```sql
SELECT 
  CASE WHEN YearsAtCompany<2 THEN 'New Hires'
        WHEN YearsAtCompany <=5 THEN '2-5 years'
        WHEN YearsAtCompany <=10 THEN '6-10 years'
        WHEN YearsAtCompany <=20 THEN '11-20 years'
        ELSE 'Over 20 years' END AS tenure_years,
  COUNT(*) AS num,
  ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER(),1) AS percent --percent per total attrition 
FROM `hr-project-2022.ibm_hr_dataset.employees` 
WHERE attrition = true
GROUP BY tenure_years
ORDER BY percent DESC
```
![Screenshot-2023-01-04-at-12-47-36-PM.png](https://i.postimg.cc/2yWj2fLP/Screenshot-2023-01-04-at-12-47-36-PM.png)

Employees who worked under 5 years at the company tend to leave the most, make up for 68.3% in total attrition.
