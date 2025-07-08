-- Top 20 theaters by total visits
SELECT
  t.theater_id,
  t.name,
  t.city,
  t.country,
  COUNT(*) AS total_visits
FROM `project.dataset.visits` v
JOIN `project.dataset.theaters` t USING(theater_id)
GROUP BY t.theater_id, t.name, t.city, t.country
ORDER BY total_visits DESC
LIMIT 20;