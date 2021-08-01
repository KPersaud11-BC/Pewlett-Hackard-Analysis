# Pewlett-Hackard-Analysis by Kieran Persaud

## Overview of the Pewlett Hackard Analysis

Pewlett Hackard is a large company with several thousand employees. With Baby-Boomers retiring, it has tasked its HR group to do two main tasks. First, it wants to know how many of its employees are retirement eligible. Second, it wants to know what positions will become vacant so that it can adequately plan to fill them in the future. Furthermore, I am to determine the number of retiring employees per title, and identify employees who are eligible to participate in a mentorship program.

## Resources
- Data Sources: employees.csv, departments.csv, titles.csv, salaries.csv, dept_emp.csv, dept_manager.csv
- Software: PostGreSQL 11, pgAdmin 4, Visual Studio Code

## Results

### Deliverable 1: The Number of Retiring Employees by Title

The first deliverable was to create tables that listed all employees who were retirement eligible, and then a final table that has the number of retirement-age employees by their most recent job title. This filtered the employees.csv by those born between 1952 and 1955, and joining it with the titles.csv to determine the employees' titles. By utilizing ```INNER JOIN```, ```DISTINCT ON```, ```ORDER BY```, and ```COUNT()```, I created the following list.

![Retiring Titles](https://user-images.githubusercontent.com/84286467/127759997-ac68724c-e999-4115-a57a-c6b132d90dab.PNG)

The table shows that Pewlett Hackard has 29,414 Senior Engineers and 28,254 Senior Staff employees who are retirement eligible. In total, 90,398 employees could retire. But it begs a question; how much is that compared to Pewlett Hackard's entire workforce? This will be explored in the summary.

### Deliverable 2: The Employees Eligible for the Mentorship Program

The second deliverable sought to determine how many employees were eligible for the Mentorship program. These were individual 10 years from retirement (aged 55) and could train and advise new hires/promoted employees in their functions. Again, I employed functions like ```INNER JOIN```, ```DISTINCT ON```, ```ORDER BY```, and ```COUNT()``` on the Employees and Department Employees tables. The resulting Mentorship Eligibility Table was exported as a csv and is shown here. 1,549 would be eligible under the

![Mentorship Eligibility](https://user-images.githubusercontent.com/84286467/127760639-468a4645-392b-47aa-8abd-7997dc025c06.PNG)

1,549 Pewlett Hackard employees would be eligible under the current requirements of the Mentorship program. A pivot table of the csv shows that most of the eligible mentors were hired in 1999 and have 21 years in their title. On average, the eligible mentors have 27 years experience.

![Mentorship Pivot](https://user-images.githubusercontent.com/84286467/127760968-049dc661-7e45-4b37-b72f-3b98d4f68800.PNG)

## Summary

- **How many roles will need to be filled as the "silver tsunami" begins to make an impact?**

Based on Deliverable 1, 90,398 Pewlett Hackard employees are retirement eligible. If they all decide to retire, all 90,398 positions would need to be filled.

- **Are there enough qualified, retirement-ready employees in the departments to mentor the next generation of Pewlett Hackard employees?**

Based on Deliverable 2, there are only 1,549 eligible employees that could be part of the mentorship program. On a 1-to-1 training basis, this would certainly not be enough to mentor all new hires and promotions.

- **Additional questions and views:**

As mentioned before, while 90,398 retirement eligible employees is a large amount, what is that in comparison to the entire organization? The following table answers that very question.

The following query joined the total employee table with the titles table, and then summarized the count of each title. 

```
--Total Number of Employees by Title
SELECT e.emp_no,
    e.first_name,
    e.last_name,
    t.title,
    t.from_date,
    t.to_date
INTO Total_Employees_Titles_Mid
FROM employees as e
INNER JOIN titles as t
ON (e.emp_no = t.emp_no)
ORDER BY e.emp_no;

-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (TETM.emp_no) TETM.emp_no,
TETM.first_name,
TETM.last_name,
TETM.title
INTO Total_Employees_Titles
FROM Total_Employees_Titles_Mid as TETM
ORDER BY TETM.emp_no, TETM.to_date DESC;

--Find Number of each title
SELECT COUNT(TET.title), TET.title
INTO Total_Employees_Titles_Count
FROM Total_Employees_Titles as TET
GROUP BY TET.title
ORDER BY COUNT(TET.title) DESC;
```

Then, using an ```INNER JOIN ``` to the retiring_titles table, it compared the counts of the retiring titles to the total counts, and calculated the percentage. Below is the code and the resulting table.

```
--Change Column names
ALTER TABLE Total_Employees_Titles_Count RENAME "count" TO Total_Count;
ALTER TABLE retiring_titles RENAME "count" TO Retiring_Count;

-- Join Total Count and Retiring Title Count on Title
SELECT DISTINCT ON (TETC.title) TETC.title,
    TETC.total_count,
    rt.retiring_count
INTO Comparison_table
FROM Total_Employees_Titles_Count as TETC
INNER JOIN retiring_titles as rt
ON (TETC.title = rt.title);

select * from comparison_table

--Calculate Percent Retiring
Select *, round(((retiring_count*1.00/total_count) * 100),1) as "%Retiring"
From Comparison_table;
```

![Comparison Table](https://user-images.githubusercontent.com/84286467/127761261-28956416-6906-420c-9cf6-c2146cd2d487.PNG)

We see that in all cases, except for Manager, Pewlett Hackard could lose approximately 30% of its workforce. This would be devastating for their operations, and would require aggressive hiring.

Second, I stated that a 1-to-1 Mentoring model would not be possible given the number of eligible mentors. The following code examined how many mentees would each mentor have if all vacancies from retirement-eligible employees needed to be filled and all mentorship-eligible employees agreed to mentor.

```
--Calculate how many employees the eligible mentors would have to advise
ALTER TABLE Mentorship_eligibility_count RENAME "count" TO Mentor_Count;

SELECT CT.title,
CT.total_count,
CT.retiring_count,
MEC.mentor_count
INTO Mentor_Comparison
FROM Comparison_table as CT
INNER JOIN Mentorship_eligibility_count as MEC
ON (CT.title = MEC.title);

Select *, round(((retiring_count*1.00/mentor_count)),0) as "Employees per Mentor"
From Mentor_Comparison;
```

![Employees Per Mentor](https://user-images.githubusercontent.com/84286467/127761393-f0000f38-6ea4-4956-8f24-af098bfc978b.PNG)

The table shows that Senior Staff and Senior Engineers would need to mentor significantly higher promoted employees than other titles.

## Conclusion
In summary, Pewlett Hackard should take the following points and recommendations from this analysis,
- Approximately 30% of its workforce is retirement-eligible. If they all chose to retire, over 90,000 employees would leave.
- Pewlett Hackard should begin working on an aggressive hiring plan to fill these vacancies, or determine if only a portion will be filled.
- It does not have enough eligible mentors to adequetely advise new hires/promotions.
- Even if Pewlett Hackard were to divide up the employees among the mentors, Senior Staff and Senior Engineers would have significantly larger loads.
- As such, Pewlett Hackard may need to expand the age range of its mentorship program, or hire training staff to adequately mentor senior engineers and senior staff.
