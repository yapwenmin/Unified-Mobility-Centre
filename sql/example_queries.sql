-- Sample SQL queries for the Unified Mobility Centre

-- 1. Retrieve the top 5 most congested routes
SELECT origin_station, destination_station, AVG(congestion_score) AS avg_congestion
FROM routes
GROUP BY origin_station, destination_station
ORDER BY avg_congestion DESC
LIMIT 5;

-- 2. Check subsidy eligibility for a user by IC
SELECT u.user_id, u.ic_number, s.eligible_for_my50, s.eligible_for_ron95
FROM users u
JOIN subsidies s ON u.user_id = s.user_id
WHERE u.ic_number = '880101-14-1234';
