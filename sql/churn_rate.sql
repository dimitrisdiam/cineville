-- Monthly churn rate
WITH cancellations AS (
  SELECT DATE_TRUNC(cancel_date, MONTH) AS month, COUNT(*) AS cancels
  FROM `project.dataset.members`
  WHERE cancel_date IS NOT NULL
  GROUP BY month
),
base AS (
  SELECT DATE_TRUNC(join_date, MONTH) AS month, COUNT(*) AS joins
  FROM `project.dataset.members`
  GROUP BY month
),
active AS (
  SELECT month, COUNT(DISTINCT member_id) AS active_members
  FROM (
    SELECT m.member_id, month
    FROM `project.dataset.members` m
    JOIN UNNEST(GENERATE_DATE_ARRAY('2023-01-01','2025-06-01', INTERVAL 1 MONTH)) AS month
      ON m.join_date <= month AND (m.cancel_date IS NULL OR m.cancel_date >= month)
  )
  GROUP BY month
)
SELECT
  a.month,
  cancels / NULLIF(active_members,0) AS churn_rate
FROM active a
LEFT JOIN cancellations USING(month)
ORDER BY a.month;