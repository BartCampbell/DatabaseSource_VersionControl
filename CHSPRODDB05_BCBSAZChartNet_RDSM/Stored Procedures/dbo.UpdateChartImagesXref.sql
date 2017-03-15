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

	WITH LastChars AS (
		SELECT	FileID
				,CHARINDEX('-', Name) AS FirstHyphen
				,CHARINDEX('-', Name, CHARINDEX('-', Name)+1) AS SecondHyphen
				,CHARINDEX('_', Name) AS FirstDash
				,CHARINDEX('_', Name, CHARINDEX('_', Name)+1) AS SecondDash
				,CHARINDEX('.', Name) AS FirstDot
		FROM dbo.ChartImageFileImport
		--WHERE Xref IS NULL
	)

	,Xrefs AS (
			SELECT t.*
					,CASE	WHEN FirstHyphen < FirstDash AND FirstHyphen <> 0 AND SecondHyphen = 0	THEN SUBSTRING(Name, 1, FirstDash-1)									--ABC-123_%
							WHEN FirstHyphen < FirstDash AND FirstDash < SecondHyphen				THEN SUBSTRING(Name, 1, FirstDash-1)									--ABC-123_123456789-1
							WHEN FirstHyphen < SecondHyphen AND FirstDash = 0						THEN SUBSTRING(Name, 1, SecondHyphen-1)									--ABC-123-%
							WHEN FirstDash < SecondDash AND FirstHyphen = 0							THEN SUBSTRING(Name, 1, SecondDash-1)									--ABC_123_%
							WHEN FirstHyphen < SecondHyphen AND SecondHyphen < FirstDash			THEN SUBSTRING(Name, 1, SecondHyphen-1)									--ABC-123-1_%
							WHEN FirstHyphen = 0 AND FirstDash > 4									THEN SUBSTRING(Name, 1, 3) + '-' + SUBSTRING(Name, 4, FirstDash - 4)	--ABC123_%
							WHEN FirstDash = 0 AND FirstHyphen > 4									THEN SUBSTRING(Name, 1, 3) + '-' + SUBSTRING(Name, 4, FirstHyphen - 4)	--ABC123-%
							WHEN FirstHyphen <> 0 AND FirstDash = 0									THEN SUBSTRING(Name, 1, FirstDot-1)										--ABC-123.
								ELSE 'ERROR'
						END AS Xref
			FROM	LastChars AS t
					INNER JOIN dbo.ChartImageFileImport AS CIFI
							ON t.FileID = CIFI.FileID
	)
	
	UPDATE	CIFI
	SET		Xref = x.Xref
	FROM	dbo.ChartImageFileImport AS CIFI
			INNER JOIN Xrefs AS x
					ON CIFI.FileID = x.FileID
	WHERE	(CIFI.Xref IS NULL);

	UPDATE dbo.ChartImageFileImport
	SET Xref = 'ERROR'
	WHERE SUBSTRING(Xref, 1, 5) NOT LIKE '[A-Z][A-Z][A-Z]-[0-9]';

/**	
-------Legacy Code Pre 20170315---------
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
**/
	
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
				  WHERE XREF = 'ERROR'
				  AND ISNULL(ErrorEmailSent, 0) = 0
				  FOR XML PATH('tr'), TYPE   
		) AS NVARCHAR(MAX) ) + 
		N'</table>' ;  
  
	IF EXISTS (SELECT TOP 1 1 FROM dbo.ChartImageFileImport WHERE XREF = 'ERROR' AND ISNULL(ErrorEmailSent, 0) = 0)
	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'CHSMail',  
		@recipients = 'Michael.Wu@Centaurihs.com',  
		@subject = 'Import Chart Images: Naming Convention Issues: McLaren ',  
		@body = @tableHTML,  
		@body_format = 'HTML' ;  

	UPDATE dbo.ChartImageFileImport
	SET ErrorEmailSent = 1
	WHERE XREF = 'ERROR'
	AND ISNULL(ErrorEmailSent, 0) = 0

	/******************************************************/
END

GO
