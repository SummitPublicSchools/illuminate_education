SELECT
  local_student_id || ' ' || school_course_id AS stu_crs_lookup
  , sites.site_name
  , students.local_student_id
  , students.last_name
  , students.first_name
  , (matviews.ss_current.grade_level_id + 1) as current_grade_level
  , ssa.section_id
  , sections.local_section_id
  , departments.department_name
  , courses.school_course_id
  , courses.short_name
  , ssa.entry_date
  , ssa.leave_date
  , courses.variable_credits_high

FROM
  matviews.ss_current

LEFT JOIN section_student_aff as ssa on ssa.student_id = matviews.ss_current.student_id
LEFT JOIN students on ssa.student_id = students.student_id
LEFT JOIN sections ON ssa.section_id = sections.section_id
LEFT JOIN courses ON ssa.course_id = courses.course_id
LEFT JOIN sites on matviews.ss_current.site_id = sites.site_id
LEFT JOIN departments on courses.department_id = departments.department_id

WHERE
  matviews.ss_current.site_id NOT IN (9999998,9999999) AND
  courses.transcript_inclusion IS NOT FALSE AND
  courses.is_active IS TRUE AND
  courses.variable_credits_high  >= 0.5 AND
  (ssa.leave_date > now() OR ssa.leave_date IS NULL) AND
  ssa.entry_date > '2017-08-01'

GROUP BY
  sites.site_name
  , students.local_student_id
  , students.last_name
  , students.first_name
  , matviews.ss_current.grade_level_id
  , ssa.section_id
  , sections.local_section_id
  , departments.department_name
  , courses.school_course_id
  , courses.short_name
  , ssa.entry_date
  , ssa.leave_date
  , courses.variable_credits_high

ORDER BY
  site_name,
  current_grade_level,
  last_name,
  first_name