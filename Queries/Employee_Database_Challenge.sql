--Deliverable 1: Number of Retiring Employees by Title
SELECT e.emp_no,
    e.first_name,
    e.last_name,
    t.title,
    t.from_date,
    t.to_date
INTO Ret_By_Title
FROM employees as e
INNER JOIN titles as t
ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;

-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (rt.emp_no) rt.emp_no,
rt.first_name,
rt.last_name,
rt.title
INTO Unique_Titles
FROM ret_by_title as rt
ORDER BY rt.emp_no, rt.to_date DESC;

--Find Number of each title retiring
SELECT COUNT(ut.title), ut.title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY ut.title
ORDER BY COUNT(ut.title) DESC;

-- Deliverable 2: The Employees Eligible for the Mentorship Program
SELECT DISTINCT ON (e.emp_no) e.emp_no,
    e.first_name,
    e.last_name,
	e.birth_date,
	de.from_date,
	de.to_date,
    t.title
INTO mentorship_eligibility
FROM employees as e
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
INNER JOIN titles as t
ON (e.emp_no = t.emp_no)
WHERE (de.to_date = '9999-01-01')
	 AND (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no;

--Find Number of each title eligible for mentorship
SELECT COUNT(ment.title), ment.title
INTO mentorship_eligibility_count
FROM mentorship_eligibility as ment
GROUP BY ment.title
ORDER BY COUNT(ment.title) DESC;

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

select * from Total_Employees_Titles_Count
select * from retiring_titles

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