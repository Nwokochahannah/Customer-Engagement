# **Interactive Student Analytics Dashboard**

This project analyzes and visualizes student registration and engagement data, answering critical business questions about course popularity, user trends, and platform usage. The interactive dashboard was built using SQL and Tableau.

---

## **Project Objectives**

The goal of this project was to analyze student behavior and platform engagement, focusing on:  
- Identifying the most-watched courses and their ratings.  
- Understanding monthly registration trends and onboarding success.  
- Comparing engagement levels (minutes watched) between free-plan and paid users.  
- Detecting seasonal or temporal variations in content consumption.  
- Assessing country-level registrations and engagement to identify top-performing regions.

---

## **Tools and Technologies**
- **SQL**: Data querying, transformation, and preparation of the dataset.  
- **Tableau**: Dashboard creation and visualization.  

---

## **Data Overview**

### **Data Source**  
The data was retrieved from a SQL database created using provided starter scripts. The analysis utilized the following key views and tables:  
1. **Course Data**: Course details, ratings, and engagement metrics.  
2. **Student Info**: Registration, onboarding, subscription, and engagement details.  

---

## **SQL Query Overview**

### **Task 1: Course Engagement and Ratings**
The following query created views to calculate:  
- Total minutes watched per course.  
- Average minutes watched per course.  
- Number of ratings and average rating per course.

```sql
CREATE VIEW course_data AS 
SELECT course_id, course_title
FROM 365_course_info; 

CREATE VIEW course_minutes AS 
SELECT 
	course_id, 
    SUM(minutes_watched) AS total_minutes_watched, 
    (SUM(minutes_watched)/COUNT(student_id)) AS average_minutes
FROM 365_student_learning
GROUP BY course_id;

CREATE VIEW course_ratings AS 
SELECT 
	course_id,
	count(course_rating) AS number_of_ratings, 
	round((sum(course_rating)/count(student_id)), 2) AS average_rating
FROM 365_course_ratings
GROUP BY course_id;

SELECT 
	cd.course_id,
    cd.course_title,
    cm.total_minutes_watched,
    cm.average_minutes,
    cr.number_of_ratings,
    cr.average_rating
FROM course_data cd
INNER JOIN course_minutes cm ON cd.course_id = cm.course_id
LEFT JOIN course_ratings cr ON cm.course_id = cr.course_id;
```

---

### **Task 2: Subscription Information**
This section calculates subscription durations for students based on their purchase type (Monthly, Quarterly, or Annually).

```sql
CREATE VIEW purchases_info AS
SELECT 
	purchase_id,
    student_id,
    purchase_type,
    (date_purchased) AS date_start,
    CASE
		WHEN purchase_type = 'Monthly' THEN date_add(date_purchased, INTERVAL 1 MONTH)
		WHEN purchase_type = 'Quarterly' THEN date_add(date_purchased, INTERVAL 3 MONTH)
		ELSE date_add(date_purchased, INTERVAL 12 MONTH)
	END AS date_end
FROM 365_student_purchases;

CREATE VIEW subscription AS (
	SELECT student_id, 
	MIN(date_start) AS date_start,
	MAX(date_end) AS date_end
	FROM purchases_info
	GROUP BY student_id
);
```

---

### **Task 3: Student Data and Engagement**
This section integrates student information with their engagement (minutes watched, onboarding, and payment status).

```sql
SELECT 
	si.student_id,
    si.student_country,
    si.date_registered,
    COALESCE(sl.date_watched, NULL) AS date_watched,
    COALESCE(sl.minutes_watched, 0) AS minutes_watched,
    CASE
		WHEN sl.student_id IS NOT NULL THEN 'YES'
        ELSE 'NO'
	END AS Onboarded,
    CASE
		WHEN sp.student_id IS NOT NULL
			AND sp.date_start <= COALESCE(sl.date_watched, CURDATE())
            AND sp.date_end >= COALESCE(sl.date_watched, CURDATE())
		THEN 1
        ELSE 0
	END AS paid
FROM
	365_student_info si
LEFT JOIN
	365_student_learning sl 
    ON si.student_id = sl.student_id
LEFT JOIN
	subscription sp 
    ON si.student_id = sp.student_id;
```

---

## **Dashboard Development**

### **1. Data Transformation**  
- Created calculated fields and parameters in Tableau for dynamic filtering:
  - **Student Type**: Differentiates Free, Paid, or Both users.  
  - **Registration Month**: Filters data by student registration month.  
  - **Date Range**: Filters data based on specific date ranges for analysis.  

### **2. Visualizations**  
The dashboard includes the following visualizations:  
- **KPIs**:
  - Number of registered students.  
  - Minutes watched (total and average).  
  - Onboarding percentage.  
- **Bar and Funnel Charts**:
  - Country-level registration and engagement metrics.  
- **Combo Charts**:
  - Monthly trends for minutes watched.  
- **Stacked Bar Charts**:
  - Onboarding success visualized against monthly registrations.
- **Table**:
  - Course trend based on the total minutes watched.

---

## Dashboard Overview
Here is a preview of the Tableau dashboard created for this project:
<img src="./Images/Dashboard 1.png" alt="Dashboard 1">
<img src="./Images/Dashboard 2.png" alt="Dashboard 2">
<img src="./Images/Dashboard 3.png" alt="Dashboard 3">

---

## **Insights Delivered**

- **Most Watched Courses and Ratings**:  
  Introduction to Data Science and SQL were the most popular, with average ratings of 5 and 5, respectively.  

- **Registration and Onboarding Trends**:  
  Monthly registrations showed steady growth. Onboarding rates ranged between 70% and 90%.  

- **Engagement Based on User Type**:  
  Paid users consistently watched 11 minutes more per month than free-plan users.  

- **Country-wise Insights**:  
  US had the highest registrations, and led in total minutes watched, highlighting higher engagement per user.

---

## **How to Use This Repository**

1. Clone the repository:  
   ```bash
   git clone https://github.com/Nwokochahannah/Customer-Engagement.git
   ```

2. Use the SQL queries in the `sql` folder to recreate the database and views.  

3. Open the Tableau workbook (`.twb` file) in Tableau to explore the dashboard.  

4. Interact with filters and parameters to view dynamic insights.  

---

## **Acknowledgments**
- **365 Data Science**: Provided the project idea and starter resources.  
- SQL and Tableau were instrumental in executing this project.  

---
