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
