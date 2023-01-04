--Calculate the Attrition Rate
SELECT
  Attrition,
  CONCAT(ROUND(100.0 * COUNT(*)/ SUM(COUNT(*)) OVER(),1),'%') AS Attrition_rate
FROM `hr-project-2022.ibm_hr_dataset.employees` 
GROUP BY Attrition

--Attrition by Gender
SELECT
  Attrition,
  Gender,
  COUNT(Gender) AS Count_gender,
  ROUND(100.0 * COUNT(*)/ SUM(COUNT(*)) OVER(PARTITION BY Gender),1) AS Attrition_by_gender
FROM `hr-project-2022.ibm_hr_dataset.employees` 
GROUP BY Attrition, Gender
ORDER BY Attrition_by_gender

--Attrition by Department
SELECT
  Department,
  Attrition,
  COUNT(*) AS num,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY Department),2) AS percent
FROM `hr-project-2022.ibm_hr_dataset.employees`
GROUP BY Department, Attrition

--Attrition by Age group
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

--Attrition by Monthly Income
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

--Attrition by Years at company
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
