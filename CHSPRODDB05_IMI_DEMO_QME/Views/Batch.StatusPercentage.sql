SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Batch].[StatusPercentage] AS
WITH SpecialWeightsBase AS
(
	SELECT	'L' AS BatchStatus, 3096 AS [Weight]
	UNION
	SELECT	'P' AS BatchStatus, 309600 AS [Weight]
	UNION
	SELECT	'F' AS BatchStatus, 102400 AS [Weight]
),
SpecialWeights AS
(
	SELECT	SWB.BatchStatus,
			BS.BatchStatusID,
	        SWB.[Weight]
	FROM	Batch.[Status] AS BS
			INNER JOIN SpecialWeightsBase AS SWB
					ON BS.Abbrev = SWB.BatchStatus
),
BatchStatusTotalBase AS
(
	SELECT	BS.BatchStatusID, 
			CASE WHEN SW.[Weight] IS NOT NULL THEN SW.[Weight] WHEN BS.BatchStatusID > 0 AND BS.DoesWork = 1 THEN 1 ELSE 0 END AS [Weight]
	FROM	Batch.[Status] AS BS	
			LEFT OUTER JOIN SpecialWeights AS SW
					ON BS.BatchStatusID = SW.BatchStatusID
),
BatchStatusTotal AS
(
	SELECT	SUM([Weight]) AS PointTotal
	FROM	BatchStatusTotalBase
),
BatchStatusPercentagePoint AS
(
	SELECT	1 / CONVERT(decimal(24,16), PointTotal) AS PercentagePoint
	FROM	BatchStatusTotal
	WHERE	PointTotal > 0
),
BatchStatusPercentageBase AS
(
	SELECT	BatchStatusID,
	        ROW_NUMBER() OVER (PARTITION BY CASE WHEN BatchStatusID > 0 THEN 1 ELSE 0 END ORDER BY BatchStatusID ASC) AS StatusOrder
	FROM	Batch.[Status]
),
BatchStatusPercentageWeights AS
(
	SELECT	BSPB.BatchStatusID, SUM(SW.[Weight]) AS [Weight] 
	FROM	BatchStatusPercentageBase AS BSPB
			INNER JOIN BatchStatusTotalBase AS SW
					ON BSPB.BatchStatusID > SW.BatchStatusID
	GROUP BY BSPB.BatchStatusID
),
BatchStatusPercentage AS
(
	SELECT	BSPB.*, CONVERT(decimal(18,12), CASE WHEN BSPB.BatchStatusID > 0 THEN (ISNULL(BSPW.[Weight], 0)) * (BSPP.PercentagePoint) ELSE 0 END) AS StatusPercentage
	FROM	BatchStatusPercentageBase AS BSPB
			LEFT OUTER JOIN BatchStatusPercentageWeights AS BSPW
					ON BSPB.BatchStatusID = BSPW.BatchStatusID
			CROSS JOIN BatchStatusPercentagePoint AS BSPP
)
SELECT	* 
FROM	BatchStatusPercentage;

GO
