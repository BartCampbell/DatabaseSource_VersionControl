SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/10/2012
-- Description:	Populates the "xref" field of the ChartImageFileImport table based on PacServ's info.
-- =============================================
CREATE PROCEDURE [dbo].[UpdateChartImagesXref] 
AS
BEGIN
	SET NOCOUNT ON;
					
	IF OBJECT_ID('tempdb..#Tally') IS NOT NULL
		DROP TABLE #Tally;  

	WITH TallyPartA AS
	(
		SELECT	1 AS N
		UNION ALL
		SELECT	1 AS N
		UNION ALL
		SELECT	1 AS N
	),
	TallyPartB AS 
	(
		
		SELECT	1 AS N 
		FROM	TallyPartA AS A1, TallyPartA AS A2, TallyPartA AS A3
	),
	TallySource AS
	(
		SELECT	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
		FROM	TallyPartB AS B1, TallyPartB AS B2, TallyPartB AS B3
	)
	SELECT	* 
	INTO	#Tally
	FROM	TallySource
	WHERE	N <= 4096;

	CREATE UNIQUE CLUSTERED INDEX IX_#Tally ON #Tally (N);

	WITH LastChars AS
	(
		SELECT	FileID,
				MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) IN (' ', '_') THEN T.N ELSE -1 END) AS LastBreak,
				MIN(CASE WHEN CIFI.Name LIKE '[A-Za-z][A-Za-z0-9][A-Za-z0-9]-%' AND N > 4 AND SUBSTRING(CIFI.Name, T.N, 1) NOT LIKE '[0-9]' THEN T.N ELSE -1 END) AS LastOther,
				MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '.' THEN T.N ELSE -1 END) AS LastDot
		FROM	dbo.ChartImageFileImport AS CIFI
				INNER JOIN #Tally AS T
						ON T.N BETWEEN 1 AND LEN(CIFI.Name)
		WHERE	(CIFI.Xref IS NULL) AND
				(
					(SUBSTRING(CIFI.Name, T.N, 1) IN (' ', '_')) OR
					(CIFI.Name LIKE '[A-Za-z][A-Za-z0-9][A-Za-z0-9]-%' AND N > 4 AND SUBSTRING(CIFI.Name, T.N, 1) NOT LIKE '[0-9]') OR                
					(SUBSTRING(CIFI.Name, T.N, 1) = '.')
				)	
		GROUP BY FileID		
	),
	Xrefs AS
	(
		SELECT	t.*,
				SUBSTRING(CIFI.Name, 1, LastOther - 1) AS Xref
		FROM	LastChars AS t
				INNER JOIN dbo.ChartImageFileImport AS CIFI
						ON t.FileID = CIFI.FileID
		WHERE	(t.LastOther > 0)
	)
	UPDATE	CIFI
	SET		Xref = x.Xref
	FROM	dbo.ChartImageFileImport AS CIFI
			INNER JOIN Xrefs AS x
					ON CIFI.FileID = x.FileID
	WHERE	(CIFI.Xref IS NULL);

END
GO
