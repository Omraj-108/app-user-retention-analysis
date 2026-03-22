CREATE DATABASE IF NOT EXISTS retention_analysis;

USE retention_analysis;

DROP TABLE IF EXISTS user_behavior;

CREATE TABLE user_behavior (
    User_ID                    INT,
    Device_Model               VARCHAR(100),
    Operating_System           VARCHAR(50),
    App_Usage_Time_min_day     FLOAT,
    Screen_On_Time_hours_day   FLOAT,
    Battery_Drain_mAh_day      FLOAT,
    Number_of_Apps_Installed   INT,
    Data_Usage_MB_day          FLOAT,
    Age                        INT,
    Gender                     VARCHAR(20),
    User_Behavior_Class        INT,
    Age_Group                  VARCHAR(50),
    Engagement_Level           VARCHAR(50),
    Retention_Risk             VARCHAR(20)
);

SELECT COUNT(*) AS total_rows FROM user_behavior;

SELECT * FROM user_behavior LIMIT 5;


SELECT
    User_Behavior_Class,
    COUNT(*)                                   AS total_users,
    ROUND(AVG(App_Usage_Time_min_day), 2)      AS avg_usage_min,
    ROUND(AVG(Screen_On_Time_hours_day), 2)    AS avg_screen_hrs,
    ROUND(AVG(Battery_Drain_mAh_day), 2)       AS avg_battery_drain,
    ROUND(AVG(Data_Usage_MB_day), 2)           AS avg_data_MB,
    ROUND(AVG(Number_of_Apps_Installed), 1)    AS avg_apps_installed
FROM user_behavior
GROUP BY User_Behavior_Class
ORDER BY User_Behavior_Class;


SELECT
    Retention_Risk,
    COUNT(*)                                                           AS user_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_behavior), 2) AS percentage
FROM user_behavior
GROUP BY Retention_Risk
ORDER BY user_count DESC;


SELECT
    Device_Model,
    COUNT(*)                                  AS user_count,
    ROUND(AVG(App_Usage_Time_min_day), 1)     AS avg_usage_min,
    ROUND(AVG(User_Behavior_Class), 2)        AS avg_behavior_class
FROM user_behavior
GROUP BY Device_Model
HAVING COUNT(*) >= 5
ORDER BY avg_usage_min DESC
LIMIT 5;


SELECT
    Gender,
    Retention_Risk,
    COUNT(*)                                  AS user_count,
    ROUND(AVG(App_Usage_Time_min_day), 1)     AS avg_usage_min
FROM user_behavior
GROUP BY Gender, Retention_Risk
ORDER BY Gender, user_count DESC;


SELECT
    Age_Group,
    COUNT(*)                                                                  AS total_users,
    SUM(CASE WHEN Engagement_Level = 'Power User (5hrs+)' THEN 1 ELSE 0 END) AS power_users,
    ROUND(
        SUM(CASE WHEN Engagement_Level = 'Power User (5hrs+)' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                                                                         AS power_user_pct
FROM user_behavior
GROUP BY Age_Group
ORDER BY power_user_pct DESC;


SELECT
    Operating_System,
    COUNT(*)                                  AS total_users,
    ROUND(AVG(App_Usage_Time_min_day), 1)     AS avg_usage_min,
    ROUND(AVG(Screen_On_Time_hours_day), 2)   AS avg_screen_hrs,
    ROUND(AVG(Data_Usage_MB_day), 1)          AS avg_data_MB
FROM user_behavior
GROUP BY Operating_System
ORDER BY avg_usage_min DESC;


SELECT
    Age_Group,
    Gender,
    Operating_System,
    COUNT(*)                                  AS user_count,
    ROUND(AVG(App_Usage_Time_min_day), 1)     AS avg_usage_min,
    ROUND(AVG(Number_of_Apps_Installed), 1)   AS avg_apps,
    ROUND(AVG(Data_Usage_MB_day), 1)          AS avg_data_MB
FROM user_behavior
WHERE User_Behavior_Class >= 4
GROUP BY Age_Group, Gender, Operating_System
ORDER BY avg_usage_min DESC
LIMIT 10;


SELECT
    Operating_System,
    Engagement_Level,
    COUNT(*)                                                          AS user_count,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Operating_System), 1)       AS pct_within_os
FROM user_behavior
GROUP BY Operating_System, Engagement_Level
ORDER BY Operating_System, user_count DESC;


SELECT
    Age_Group,
    COUNT(*)                                                              AS total_users,
    SUM(CASE WHEN Retention_Risk = 'High Risk' THEN 1 ELSE 0 END)        AS high_risk_count,
    ROUND(
        SUM(CASE WHEN Retention_Risk = 'High Risk' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                                                                     AS high_risk_pct
FROM user_behavior
GROUP BY Age_Group
ORDER BY high_risk_pct DESC;


SELECT
    User_Behavior_Class                     AS behavior_class,
    COUNT(*)                                AS total_users,
    ROUND(AVG(App_Usage_Time_min_day), 1)   AS avg_daily_usage_min,
    ROUND(AVG(Age), 1)                      AS avg_age,
    SUM(CASE WHEN Retention_Risk = 'High Risk'
             THEN 1 ELSE 0 END)             AS high_risk_users,
    SUM(CASE WHEN Retention_Risk = 'Low Risk'
             THEN 1 ELSE 0 END)             AS low_risk_users,
    ROUND(
        SUM(CASE WHEN Retention_Risk = 'High Risk' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                                       AS high_risk_pct
FROM user_behavior
GROUP BY User_Behavior_Class
ORDER BY User_Behavior_Class;
