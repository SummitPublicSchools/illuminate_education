/*

Summary
• Pulls a list of currently enrolled students and demographic factors

Level of Detail
• student

*/


SELECT

  -- Student Demographic Information
    TRIM(sites.site_name) AS "Site"
  , grade_levels.short_name::INTEGER AS "Grade Level"
  , students.local_student_id AS "SPS ID"
  , students.student_id AS "Illuminate Student ID"
  , students.state_student_id AS "State Student ID"
  , TRIM(students.last_name) AS "Student Last Name"
  , TRIM(students.first_name) AS "Student First Name"
  , TRIM(students.middle_name) AS "Student Middle Name"
  , LOWER(students.email) AS "Student Email"
  , users.last_name AS "Mentor Last Name"
  , users.first_name AS "Mentor First Name"
  , LOWER(users.email1) AS "Mentor Email"
  , students.school_enter_date AS "School Enter Date"
  , students.birth_date AS "Birth Date"
  , students.gender AS "Gender"
  , race_ethnicity.combined_race_ethnicity AS "Federal Reported Race"
  , students.is_hispanic AS "Hispanic / Latino Status"
  , (
      COALESCE
        (
          el.code_translation,  -- CA
          programs.code_translation  -- WA
        )
    ) AS "English Proficiency"
  , demographics.sed AS "SED Status"
  , demographics.is_specialed AS "SPED Status"


FROM
  -- Start with ss_current to pull only currently enrolled students
  matviews.ss_current AS ss

  -- Join current students to students, grade levels, and sites
  INNER JOIN students
    USING (student_id)
  INNER JOIN grade_levels
    USING (grade_level_id)
  INNER JOIN sites
    ON sites.site_id = ss.site_id
    AND sites.exclude_from_current_sites IS FALSE   -- excludes SPS as a district
    AND sites.site_name <> 'SPS Tour'

  -- Join current students to counselors (mentors)
  LEFT JOIN student_counselor_aff AS counselors
    ON counselors.student_id = ss.student_id
    AND counselors.start_date <= CURRENT_DATE
    AND (counselors.end_date IS NULL OR counselors.end_date > CURRENT_DATE)
  LEFT JOIN users
    ON counselors.user_id = users.user_id

  -- Join current students to demographics
  LEFT JOIN student_common_demographics AS demographics
    ON demographics.student_id = ss.student_id
  LEFT JOIN race_ethnicity_combined AS race_ethnicity
    ON race_ethnicity.student_id = ss.student_id
  LEFT JOIN codes.english_proficiency AS el  -- CA
    ON el.code_id = demographics.english_proficiency
  LEFT JOIN codes.student_programs AS programs  -- WA
    ON programs.code_id = demographics.ell_program_id


ORDER BY
    "Site"
  , "Grade Level"
  , "Student Last Name"
  , "Student First Name"
