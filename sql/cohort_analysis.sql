-- Cohort retention analysis (BigQuery Standard SQL)
WITH cohorts AS (
  SELECT
    member_id,
    DATE_TRUNC(join_date, MONTH) AS cohort_month
  FROM `project.dataset.members`
),
activity AS (
  SELECT
    member_id,
    cohort_month,
    DATE_DIFF(DATE_TRUNC(visit_date, MONTH), cohort_month, MONTH) AS period
  FROM `project.dataset.visits`
  JOIN cohorts USING(member_id)
),
cohort_sizes AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT member_id) AS size
  FROM cohorts
  GROUP BY cohort_month
),
retention AS (
  SELECT
    cohort_month,
    period,
    COUNT(DISTINCT member_id) AS active
  FROM activity
  GROUP BY cohort_month, period
)
SELECT
  r.cohort_month,
  r.period,
  ROUND(active / size, 4) AS retention_rate
FROM retention r
JOIN cohort_sizes s USING(cohort_month)
ORDER BY r.cohort_month, r.period;