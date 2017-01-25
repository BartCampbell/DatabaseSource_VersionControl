SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[MeasureDecks] AS
SELECT TOP 100 PERCENT
		COUNT(DISTINCT CASE WHEN t.HedisMeasureID LIKE '%Sample%' THEN t.HedisMeasureID END) AS CountSample,
		COUNT(DISTINCT CASE WHEN t.HedisMeasureID NOT LIKE '%Sample%' THEN t.HedisMeasureID END) AS CountTest,
		MMX.Abbrev AS Measure, LEFT(t.HedisMeasureID, 3) AS NcqaDeck
FROM	dbo.Provider AS t
		FULL OUTER JOIN Measure.MeasureXrefs AS MMX
				ON LEFT(t.HedisMeasureID, 3) = MMX.Abbrev
WHERE	(MMX.Abbrev IS NOT NULL) OR (t.HedisMeasureID IS NOT NULL)
GROUP BY MMX.Abbrev, LEFT(t.HedisMeasureID, 3)           
ORDER BY 3;
GO
