CREATE VIEW vw_chat_dialogs AS
SELECT 
    s.session_id,
    s.user_id,
    s.platform,
    s.created_at AS session_start,
    m.message_id,
    m.sender,
    m.message_text,
    m.sent_at,
    e.score,
    e.is_safe,
    CASE 
        WHEN e.score >= 80 THEN 'High'
        WHEN e.score BETWEEN 50 AND 79 THEN 'Medium'
        WHEN e.score < 50 THEN 'Low'
        ELSE 'Unrated'
    END AS quality_tier
FROM bot_sessions s
INNER JOIN chat_messages m ON s.session_id = m.session_id
LEFT JOIN response_evaluations e ON m.message_id = e.message_id;
GO

CREATE PROCEDURE sp_get_platform_metrics
    @Start_Date DATETIME,
    @End_Date DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.platform,
        COUNT(DISTINCT s.session_id) AS total_sessions,
        COUNT(DISTINCT s.user_id) AS unique_users,
        COUNT(m.message_id) AS total_messages,
        AVG(CAST(e.score AS FLOAT)) AS avg_eval_score,
        SUM(CASE WHEN e.is_safe = 0 THEN 1 ELSE 0 END) AS total_flagged_issues
    FROM bot_sessions s
    LEFT JOIN chat_messages m ON s.session_id = m.session_id
    LEFT JOIN response_evaluations e ON m.message_id = e.message_id
    WHERE s.created_at BETWEEN @Start_Date AND @End_Date
    GROUP BY s.platform
    ORDER BY total_sessions DESC;
END;
GO

WITH session_stats AS (
    SELECT 
        s.user_id,
        s.session_id,
        s.platform,
        COUNT(m.message_id) AS msg_count,
        MIN(m.sent_at) AS first_msg,
        MAX(m.sent_at) AS last_msg,
        AVG(CAST(e.score AS FLOAT)) AS avg_session_score
    FROM bot_sessions s
    JOIN chat_messages m ON s.session_id = m.session_id
    LEFT JOIN response_evaluations e ON m.message_id = e.message_id
    GROUP BY s.user_id, s.session_id, s.platform
),
user_ranking AS (
    SELECT 
        user_id,
        session_id,
        platform,
        msg_count,
        avg_session_score,
        DATEDIFF(SECOND, first_msg, last_msg) AS session_duration_seconds,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY first_msg DESC) AS session_rank,
        AVG(avg_session_score) OVER (PARTITION BY platform) AS platform_avg_score
    FROM session_stats
)
SELECT 
    user_id,
    session_id,
    platform,
    msg_count,
    session_duration_seconds,
    ROUND(avg_session_score, 2) AS user_session_score,
    ROUND(platform_avg_score, 2) AS overall_platform_score,
    CASE 
        WHEN avg_session_score < platform_avg_score THEN 'Needs Improvement'
        ELSE 'Above Average'
    END AS performance_status
FROM user_ranking
WHERE session_rank = 1
ORDER BY session_duration_seconds DESC;