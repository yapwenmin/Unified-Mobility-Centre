-- Unified Mobility Centre Example Queries

-- 1. Simulate a multimodal journey across stations
WITH mrt_leg AS (
    SELECT r.route_id, r.duration_min
    FROM routes r
    JOIN stations s1 ON r.origin_station = s1.station_id
    JOIN stations s2 ON r.destination_station = s2.station_id
    WHERE s1.name = 'Station A'
      AND s2.name = 'Station B'
      AND r.mode = 'MRT'
),
feeder_leg AS (
    SELECT f.service_id, f.frequency_min
    FROM feeder_services f
    JOIN stations s ON f.station_id = s.station_id
    WHERE s.name = 'Station B'
),
walk_leg AS (
    SELECT 10::INT AS duration_min
)
SELECT 'MRT' AS mode, mrt_leg.duration_min AS duration
FROM mrt_leg
UNION ALL
SELECT 'Feeder Bus' AS mode, feeder_leg.frequency_min AS duration
FROM feeder_leg
UNION ALL
SELECT 'Walk' AS mode, walk_leg.duration_min AS duration
FROM walk_leg;

-- 2. Validate MyKad-linked subsidy eligibility
SELECT u.user_id, u.ic_number, s.eligible_for_my50, s.eligible_for_ron95
FROM users u
JOIN subsidies s ON u.user_id = s.user_id
WHERE u.ic_number = '880101-14-1234';

-- 3. Identify underutilized MRT stations
WITH station_usage AS (
    SELECT st.station_id, st.name, COUNT(j.journey_id) AS journey_count
    FROM stations st
    LEFT JOIN journeys j ON st.station_id = j.origin OR st.station_id = j.destination
    WHERE st.type = 'MRT'
    GROUP BY st.station_id, st.name
)
SELECT station_id, name, journey_count
FROM station_usage
ORDER BY journey_count ASC
LIMIT 10;

-- 4. Retrieve the top 5 most congested routes or areas
SELECT r.origin_station, r.destination_station, AVG(r.congestion_score) AS avg_congestion
FROM routes r
GROUP BY r.origin_station, r.destination_station
ORDER BY avg_congestion DESC
LIMIT 5;

-- 5. Find park-and-ride stations with >50% available lots within 500m
WITH nearby_stations AS (
    SELECT st.station_id, st.name, st.latitude, st.longitude
    FROM stations st
    WHERE st.is_park_and_ride = TRUE
      AND ST_DistanceSphere(
            ST_MakePoint(st.longitude, st.latitude),
            ST_MakePoint(:user_lon, :user_lat)
          ) <= 500
)
SELECT ns.name AS station_name, pr.available_lots, pr.total_lots
FROM nearby_stations ns
JOIN park_ride pr ON ns.station_id = pr.station_id
WHERE (pr.available_lots::DECIMAL / pr.total_lots) > 0.5;

-- 6. Calculate average journey duration by income group
WITH income_grouped AS (
    SELECT u.user_id,
           CASE WHEN u.income_bracket <= 4000 THEN 'B40'
                WHEN u.income_bracket <= 8000 THEN 'M40'
                ELSE 'T20'
           END AS income_group
    FROM users u
)
SELECT ig.income_group, AVG(j.total_duration) AS avg_journey_minutes
FROM journeys j
JOIN income_grouped ig ON j.user_id = ig.user_id
GROUP BY ig.income_group
ORDER BY ig.income_group;

-- 7. Link congestion data with journey logs
WITH journey_routes AS (
    SELECT j.journey_id, unnest(string_to_array(j.route_sequence, ','))::INT AS route_id
    FROM journeys j
),
route_congestion AS (
    SELECT jr.journey_id, r.route_id, r.congestion_score
    FROM journey_routes jr
    JOIN routes r ON jr.route_id = r.route_id
)
SELECT j.journey_id, AVG(rc.congestion_score) AS avg_congestion_score, j.total_duration
FROM journeys j
JOIN route_congestion rc ON j.journey_id = rc.journey_id
GROUP BY j.journey_id, j.total_duration
ORDER BY avg_congestion_score DESC;

-- 8. Generate SQL views for dashboards
CREATE OR REPLACE VIEW view_congestion_trends AS
SELECT DATE_TRUNC('hour', r.timestamp) AS hour, AVG(r.congestion_score) AS avg_congestion
FROM routes r
GROUP BY DATE_TRUNC('hour', r.timestamp)
ORDER BY hour;

CREATE OR REPLACE VIEW view_user_journey_patterns AS
SELECT origin, destination, COUNT(*) AS journey_count
FROM journeys
GROUP BY origin, destination
ORDER BY journey_count DESC;
