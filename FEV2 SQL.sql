--Create the Table
CREATE TABLE youtube_data (
    channelId TEXT,
    channelTitle TEXT,
    videoId TEXT,
    publishedAt TEXT,
    videoTitle TEXT,
    videoDescription TEXT,
    videoCategoryId INTEGER,
    videoCategoryLabel TEXT,
    duration TEXT,
    durationSec INTEGER,
    definition TEXT,
    caption BOOLEAN,
    viewCount INTEGER,
    likeCount INTEGER,
    dislikeCount INTEGER,
    commentCount INTEGER
);


--import the data 
COPY youtube_data
FROM 'D:\Subham\FEV SQL\Trending videos on youtube dataset new.csv'
DELIMITER ','
CSV HEADER
NULL 'NULL';


--Convert publishedAt into DATE and TIME using SQL date functions
-- Add new columns for date and time
ALTER TABLE youtube_data
ADD COLUMN publishedDate DATE,
ADD COLUMN publishedTime TIME;
-- Update the columns with date and time extracted from publishedAt
UPDATE youtube_data
SET 
    publishedDate = CAST(publishedAt AS TIMESTAMP)::DATE,
    publishedTime = CAST(publishedAt AS TIMESTAMP)::TIME;
--display the first 10 rows, including the publishedAt, publishedDate, and publishedTime columns.	
SELECT videoId, publishedAt, publishedDate, publishedTime
FROM youtube_data
LIMIT 10;


---- Replace missing values (NULL) with 0 in likeCount, dislikeCount, and commentCount
UPDATE youtube_data
SET
    likeCount = COALESCE(likeCount, 0),
    dislikeCount = COALESCE(dislikeCount, 0),
    commentCount = COALESCE(commentCount, 0);


-- Delete rows with NULL in videoId, viewCount, or durationSec
DELETE FROM youtube_data
WHERE videoId IS NULL
   OR viewCount IS NULL
   OR durationSec IS NULL;


--Top 10 Most Viewed Videos: Based on viewCount.
SELECT 
    videoTitle,
    channelTitle,
    viewCount
FROM 
    youtube_data
ORDER BY 
    viewCount DESC
LIMIT 10;


--Top 5 Most Liked Videos: Based on likeCount.
SELECT 
    videoTitle,
    channelTitle,
    likeCount
FROM 
    youtube_data
ORDER BY 
    likeCount DESC
LIMIT 5;


--Engagement Rate: Calculate likes + dislikes + comments per 1000 views.
SELECT 
    videoTitle,
    channelTitle,
    viewCount,
    likeCount,
    dislikeCount,
    commentCount,
    ROUND(((likeCount + dislikeCount + commentCount) * 1000.0) / NULLIF(viewCount, 0), 2) AS engagement_rate_per_1000_views
FROM 
    youtube_data
ORDER BY 
    engagement_rate_per_1000_views DESC;


--average views by video category
SELECT 
    videoCategoryLabel,
    ROUND(AVG(viewCount), 2) AS average_views
FROM 
    youtube_data
GROUP BY 
    videoCategoryLabel
ORDER BY 
    average_views DESC;


--Short VS Long Video Views
SELECT 
    CASE 
        WHEN durationSec < 300 THEN 'Short Video (<5 min)'
        WHEN durationSec > 900 THEN 'Long Video (>15 min)'
        ELSE 'Other'
    END AS video_type,
    COUNT(*) AS total_videos,
    ROUND(AVG(viewCount), 2) AS average_views
FROM 
    youtube_data
WHERE 
    durationSec < 300 OR durationSec > 900
GROUP BY 
    video_type
ORDER BY 
    average_views DESC;


--Most Common Video Category: Category with the highest number of videos.
SELECT 
    videoCategoryLabel,
    COUNT(*) AS total_videos
FROM 
    youtube_data
GROUP BY 
    videoCategoryLabel
ORDER BY 
    total_videos DESC
LIMIT 1;


--Compare views between HD and SD videos.
SELECT 
    definition,
    COUNT(*) AS total_videos,
    SUM(viewCount) AS total_views,
    ROUND(AVG(viewCount), 2) AS average_views
FROM 
    youtube_data
WHERE 
    definition IN ('hd', 'sd')
GROUP BY 
    definition
ORDER BY 
    total_views DESC;


--Top Categories By Total Engagement: Sum of likes + comments grouped by category.
SELECT 
    videoCategoryLabel,
    COUNT(*) AS total_videos,
    SUM(likeCount + commentCount) AS total_engagement,
    ROUND(AVG(likeCount + commentCount), 2) AS avg_engagement_per_video
FROM 
    youtube_data
GROUP BY 
    videoCategoryLabel
ORDER BY 
    total_engagement DESC;


--Daily Uploads Trend: Extract upload day from publishedAt and count uploads per day.
SELECT 
    CAST(publishedAt AS DATE) AS upload_date,
    COUNT(*) AS total_uploads
FROM 
    youtube_data
GROUP BY 
    upload_date
ORDER BY 
    upload_date;


--Engagement Leaders: Use window functions (RANK() or DENSE_RANK()) to find the top video per category by engagement.
SELECT 
    videoCategoryLabel,
    videoTitle,
    likeCount + commentCount AS total_engagement,
    RANK() OVER (PARTITION BY videoCategoryLabel ORDER BY (likeCount + commentCount) DESC) AS rank
FROM 
    youtube_data
WHERE 
    likeCount IS NOT NULL AND commentCount IS NOT NULL
ORDER BY 
    videoCategoryLabel, rank;


--Trending Time Analysis: Extract upload hour and find the peak time range for video uploads.
SELECT 
    EXTRACT(HOUR FROM CAST(publishedAt AS TIMESTAMP)) AS upload_hour,
    COUNT(*) AS total_uploads
FROM 
    youtube_data
GROUP BY 
    upload_hour
ORDER BY 
    total_uploads DESC;


--Performance Outliers: Find videos with a likeCount significantly higher than the average for their category.
WITH CategoryAvgLikes AS (
    SELECT 
        videoCategoryLabel,
        AVG(likeCount) AS avg_likeCount
    FROM 
        youtube_data
    GROUP BY 
        videoCategoryLabel
)

SELECT 
    y.videoCategoryLabel,
    y.videoTitle,
    y.likeCount,
    c.avg_likeCount,
    (y.likeCount - c.avg_likeCount) AS likeCount_diff
FROM 
    youtube_data y
JOIN 
    CategoryAvgLikes c ON y.videoCategoryLabel = c.videoCategoryLabel
WHERE 
    y.likeCount > (c.avg_likeCount * 1.5) -- Videos with likeCount 50% higher than the average
ORDER BY 
    y.videoCategoryLabel, likeCount_diff DESC;



--Boolean Flag: Create a flag for videos where viewCount > 10000 AND likeCount/viewCount > 0.1 → “High Engagement”.
SELECT 
    videoId,
    videoTitle,
    viewCount,
    likeCount,
    CASE 
        WHEN viewCount > 10000 AND (likeCount::float / viewCount) > 0.1 THEN 'High Engagement'
        ELSE 'Low Engagement'
    END AS engagement_flag
FROM 
    youtube_data
ORDER BY 
    engagement_flag DESC, viewCount DESC;

