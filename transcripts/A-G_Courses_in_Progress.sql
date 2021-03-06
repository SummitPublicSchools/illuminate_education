-- This counts the number of courses that each currently-enrolled student is enrolled in by A-G category.

SELECT
  students.local_student_id                 AS local_id,
  students.last_name,
  students.first_name,
  sites.site_name AS site,
  (ssc.grade_level_id - 1)  AS current_grade,
  sum(CASE WHEN
    left(courses.school_course_id,1) = 'A' THEN 1 ELSE 0 END) AS hist_enrolled,
  SUM(CASE WHEN
    left(courses.school_course_id,1) = 'B' THEN 1 ELSE 0 END) AS eng_enrolled,
  SUM(CASE WHEN
    left(courses.school_course_id,1) = 'C' THEN 1 ELSE 0 END) AS math_enrolled,
  SUM(CASE WHEN
    left(courses.school_course_id,1) = 'D' THEN 1 ELSE 0 END) AS science_enrolled,
  SUM(CASE WHEN
    left(courses.school_course_id,1) = 'E' THEN 1 ELSE 0 END) AS forlang_enrolled,
  SUM(CASE WHEN
      left(courses.school_course_id,1) = 'F' THEN 1 ELSE 0 END) AS vpa_enrolled,
  SUM(CASE WHEN
      left(courses.school_course_id,1) = 'G' THEN 1 ELSE 0 END) AS ucelec_enrolled

FROM matviews.ss_current ssc

LEFT JOIN students on students.student_id = ssc.student_id
LEFT JOIN sites on sites.site_id = ssc.site_id
LEFT JOIN section_student_aff ssa on ssa.student_id = ssc.student_id
LEFT JOIN courses on courses.course_id = ssa.course_id
LEFT JOIN section_term_aff sta on sta.section_id = ssa.section_id
LEFT JOIN terms on sta.term_id = terms.term_id

WHERE sites.site_id < 100
  AND (terms.start_date < now() AND terms.end_date > now())
  AND (ssa.leave_date > now() OR ssa.leave_date IS NULL)

GROUP BY local_id,
  students.last_name,
  students.first_name,
  site,
  current_grade

ORDER BY students.local_student_id;
