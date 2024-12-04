-- *************************************************** --
-- ******************** Task 1 *********************** -- 
-- *************************************************** --

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

-- *************************************************** --
-- ******************** Task 2 *********************** -- 
-- *************************************************** --

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

-- *************************************************** --
-- ******************** Task 3 *********************** -- 
-- *************************************************** --
CREATE VIEW subscription AS (
	SELECT student_id, 
	MIN(date_start) AS date_start,
	MAX(date_end) AS date_end
	FROM purchases_info
	GROUP BY student_id
);

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
    ON sl.student_id = si.student_id
LEFT JOIN
	subscription sp 
    ON si.student_id = sp.student_id;