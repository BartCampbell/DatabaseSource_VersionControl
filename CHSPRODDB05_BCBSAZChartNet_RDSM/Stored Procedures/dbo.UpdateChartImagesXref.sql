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
				MIN(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '_' THEN T.N ELSE 9999 END) AS FirstDash,
				MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '_' THEN T.N ELSE -1 END) AS LastDash,
				MAX(CASE WHEN SUBSTRING(CIFI.Name, T.N, 1) = '.' THEN T.N ELSE -1 END) AS LastDot
		FROM	dbo.ChartImageFileImport AS CIFI
				INNER JOIN #Tally AS T
						ON T.N BETWEEN 1 AND LEN(CIFI.Name)
		WHERE	(CIFI.Xref IS NULL) AND
				(
					(SUBSTRING(CIFI.Name, T.N, 1) = '_') OR
					(SUBSTRING(CIFI.Name, T.N, 1) = '.')
				)	
		GROUP BY FileID		
	),
	Xrefs AS
	(
		SELECT	t.*,
				SUBSTRING(CIFI.Name, 1, t.FirstDash-1) AS Xref
				--SUBSTRING(CIFI.Name, 1, t.LastDash-1) AS Xref
				--SUBSTRING(CIFI.Name, t.LastDash + 1, t.LastDot - t.LastDash - 1) AS Xref
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
	WHERE	(CIFI.Xref IS NULL);

	
	/******************************************************
		Naming Convention Issues

	******************************************************/
	DECLARE @tableHTML NVARCHAR(MAX) ;  
	SET @tableHTML =  
		N'<H1>ChartNet: Import Chart Images</H1>' + 
		N'<table border="1">' +  
		N'<tr><th>Naming Convention Issues</th>'  +
		CAST ( ( SELECT td = Name, ''
				  FROM dbo.ChartImageFileImport
				  WHERE XREF NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]-[0-9]%'
				  FOR XML PATH('tr'), TYPE   
		) AS NVARCHAR(MAX) ) + 
		N'</table>' ;  
  
	IF EXISTS (SELECT TOP 1 1 FROM dbo.ChartImageFileImport WHERE XREF NOT LIKE '[A-Za-z][A-Za-z][A-Za-z]-[0-9]%')
	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'CHSMail',  
		@recipients = 'Michael.Wu@Centaurihs.com',  
		@subject = 'Import Chart Images: Naming Convention Issues: BCBSAZ ',  
		@body = @tableHTML,  
		@body_format = 'HTML' ;  

	/******************************************************/
END

GO
