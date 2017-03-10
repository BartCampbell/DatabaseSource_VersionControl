SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/10/2012
-- Description:	Populates the "xref" field of the ChartImageFileImport table based on PacServ's info.
--exec [dbo].[UpdateChartImagesXref] 
-- =============================================
CREATE PROCEDURE [dbo].[UpdateChartImagesXref] 
AS
BEGIN
	SET NOCOUNT ON;
	
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
		--SELECT	FileID,
		--		MIN(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '_' THEN T.N END) AS LastDash
		--		--MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '_' THEN T.N ELSE -1 END) AS LastDash
		--		--MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '.' THEN T.N ELSE -1 END) AS LastDot
		----select *
		--FROM	dbo.ChartImageFileImport AS CIFI
		--		INNER JOIN Tally_Test AS T
		--				ON T.N BETWEEN 1 AND LEN(CIFI.Name)
		--WHERE	(CIFI.Xref IS NULL) AND
		--		(
		--			(SUBSTRING(CIFI.Name, T.N, 1) = '_') OR
		--			(SUBSTRING(CIFI.Name, T.N, 1) = '.')
		--		)	
		--GROUP BY FileID
				
		SELECT	FileID,
				MIN(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '_' THEN T.N ELSE 9999 END) AS FirstDash,
				MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '_' THEN T.N ELSE -1 END) AS LastDash,
				MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '.' THEN T.N ELSE -1 END) AS LastDot
		FROM	dbo.ChartImageFileImport AS CIFI
				INNER JOIN #Tally AS T
						ON T.N BETWEEN 1 AND LEN(CIFI.Name)
		WHERE	--(CIFI.Xref IS NULL) AND
				(
					(SUBSTRING(CIFI.Name, T.N, 1) = '_') OR
					(SUBSTRING(CIFI.Name, T.N, 1) = '.')
				)	
		GROUP BY FileID	
	),

	Xrefs AS
	(
		--SELECT	t.*,
		--		SUBSTRING(CIFI.Name, 1, t.LastDot - 1) AS Xref
		----select *
		--FROM	LastChars AS t
		--		INNER JOIN dbo.ChartImageFileImport AS CIFI
		--				ON t.FileID = CIFI.FileID
		--WHERE LEN(SUBSTRING(CIFI.Name, 1, t.LastDot - 1)) <= 64

		SELECT	t.*,
				SUBSTRING(CIFI.Name, 1, t.LastDot-1) AS Xref
				,SUBSTRING(CIFI.Name, 1, t.LastDash-1) AS Xref1
				,SUBSTRING(CIFI.Name, t.LastDash + 1, t.LastDot - t.LastDash - 1) AS Xref2
		FROM	LastChars AS t
				INNER JOIN dbo.ChartImageFileImport AS CIFI
						ON t.FileID = CIFI.FileID
		WHERE LEN(SUBSTRING(CIFI.Name, t.LastDash + 1, t.LastDot - t.LastDash - 1)) <= 64
	)

	UPDATE	CIFI
	SET		Xref = x.Xref
	FROM	dbo.ChartImageFileImport AS CIFI
			INNER JOIN Xrefs AS x
					ON CIFI.FileID = x.FileID
	--WHERE	(CIFI.Xref IS NULL);
END


GO
