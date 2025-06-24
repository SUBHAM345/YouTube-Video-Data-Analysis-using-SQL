# YouTube-Video-Data-Analysis-using-SQL
SQL: Trending YouTube Videos Dataset
Dataset Link: SQL: [Trending YouTube Videos Dataset](https://drive.google.com/file/d/12flMJXROE0OFrTPVjL8aFLRhxOCpnFtY/view?usp=drive_link)

# This dataset captures detailed information about YouTube videos that trended across various categories and channels. It includes video metadata, engagement metrics (views, likes, dislikes, comments), content type, and technical attributes like video resolution and duration. It's ideal for SQL-based exploration of video performance, content trends, and audience interaction patterns.

# Alphabet Dataset Overview
Rows: 115
Columns: 17
Column Description
channelId: Unique ID of the channel that uploaded the video.
channelTitle: Display name of the channel.
videoId: Unique video identifier.
publishedAt: Upload timestamp of the video.
videoTitle: Title of the video.
videoDescription: Description text provided by the uploader.
videoCategoryId: Numeric ID assigned to video categories.
videoCategoryLabel: Human-readable category name.
duration: ISO 8601 format duration of the video.
durationSec: Video length in seconds.
definition: Video resolution – either “sd” or “hd”.
caption: Boolean indicating whether captions are available.
viewCount: Total number of views.
likeCount: Total number of likes.
dislikeCount: Total number of dislikes.
commentCount: Total number of comments.
# Questions
1. Data Cleaning And Preprocessing
Convert publishedAt into DATE and TIME using SQL date functions.
Replace missing values in likeCount, dislikeCount, and commentCount with 0 or filter them out.
Remove videos with null or missing videoId, viewCount, or durationSec.

2. Video Engagement And Popularity Analysis
Top 10 Most Viewed Videos: Based on viewCount.
Top 5 Most Liked Videos: Based on likeCount.
Engagement Rate: Calculate likes + dislikes + comments per 1000 views.
Average Views By Category: Group by videoCategoryLabel and calculate average viewCount.
Short VS Long Video Views: Compare average views for:
Short videos (durationSec < 300)
Long videos (durationSec > 900)

3. Content And Category Trends
Most Common Video Category: Category with the highest number of videos.
View Distribution By Definition: Compare views between HD and SD videos.
Top Categories By Total Engagement: Sum of likes + comments grouped by category.
Daily Uploads Trend: Extract upload day from publishedAt and count uploads per day.

4. Advanced SQL Queries
Engagement Leaders: Use window functions (RANK() or DENSE_RANK()) to find the top video per category by engagement.
Trending Time Analysis: Extract upload hour and find the peak time range for video uploads.
Performance Outliers: Find videos with a likeCount significantly higher than the average for their category.
Boolean Flag: Create a flag for videos where viewCount > 10000 AND likeCount/viewCount > 0.1 → “High Engagement”.
