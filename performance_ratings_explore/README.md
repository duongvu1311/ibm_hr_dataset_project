## Explore Performance Rating 

[Link](https://docs.google.com/spreadsheets/d/1Sxeu9XsImI4EbGLbjEz1SjFZe3Zib-HS6ZD3gsPQ3d0/edit#gid=171840667) to view the spreadsheet online.

First of all, after browsing through the data, I noticed that the ratings only include score of 3 or 4. 
So I decided to calculate the percentage of each result to the total answers.

![Screenshot-2023-01-05-at-7-25-57-PM.png](https://i.postimg.cc/d1Ks7cM0/Screenshot-2023-01-05-at-7-25-57-PM.png)

It turned out that score 3 consists of nearly 85% of the data, resulting in imbalanced data sample.

With that in mind, I tried to run a multiple regression to test the correlations.
The explanatory variables that I chose are: 
* Education
* JobInvolvement	
* TotalWorkingYears	
* TrainingTimesLastYear	
* WorkLifeBalance

Using the =LINEST() function, here are the results:

![Screenshot-2023-01-05-at-7-39-06-PM.png](https://i.postimg.cc/d1z0jZTJ/Screenshot-2023-01-05-at-7-39-06-PM.png)

This result can be interpreted as:

**PerformanceRating = 3.2223 + 0.0015 * Education + (-0.0046) * JobInvolvement + 0.0005 * TotalWorkingYears + (-0.0143) * TrainingTimesLastYear + (-0.0089) * WorkLifeBalance**

So Performance Rating has:
* Positive correlation with: Education, Total Working Years
* Negative correlation with: Job Involvement, Training Times, Work Life Balance

Or put it another way, for example, _if Education increase by 1 score, Performance Rating will increase by 0.0015. And if Work Life Balance increase by 1 score, Performance Rating will decrease by 0.0089._

We can see that all the coefficients are so small that there is no significant difference that can affect Performance Rating. The fact that score 3 outnumbers 4 in the original dataset may be the main cause to this problem.

