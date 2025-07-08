-- Monthly Active Members and Visits
WITH months AS (
  SELECT
    month
  FROM UNNEST(GENERATE_DATE_ARRAY('2023-01-01','2025-06-01', INTERVAL 1 MONTH)) AS month
),
active_members AS (
  SELECT
    m.member_id,
    month
  FROM `project.dataset.members` m
  JOIN months ON m.join_date <= month
    AND (m.cancel_date IS NULL OR m.cancel_date >= month)
),
mam AS (
  SELECT month, COUNT(DISTINCT member_id) AS active_members
  FROM active_members
  GROUP BY month
),
mv AS (
  SELECT DATE_TRUNC(visit_date, MONTH) AS month, COUNT(*) AS visits
  FROM `project.dataset.visits`
  GROUP BY month
)
SELECT
  months.month,
  COALESCE(active_members,0) AS active_members,
  COALESCE(visits,0) AS visits
FROM months
LEFT JOIN mam USING(month)
LEFT JOIN mv USING(month)
ORDER BY months.month;