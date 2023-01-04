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

Employees who are under 30 years old have the highest attrition rate (27.91%)
