SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/11/2012
-- Description:	Retrieves the file summary information needed for a data-driven subscription in SSRS.
-- =============================================
CREATE PROCEDURE [dbo].[RetrieveChartImageSubscriptionData]
(
	@MarkAsNotified bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;

    WITH Summary AS
    (
		SELECT	COUNT(*) AS CountRecords,
				CreatedDate,
				CONVERT(nvarchar(8), CreatedDate, 112) + '_' + 
									CASE WHEN LEN(CONVERT(nvarchar(2), DATEPART(hour, CreatedDate))) = 1 THEN '0' ELSE '' END + CONVERT(nvarchar(2), DATEPART(hour, CreatedDate)) +
									CASE WHEN LEN(CONVERT(nvarchar(2), DATEPART(minute, CreatedDate))) = 1 THEN '0' ELSE '' END + CONVERT(nvarchar(2), DATEPART(minute, CreatedDate)) +
									CASE WHEN LEN(CONVERT(nvarchar(2), DATEPART(second, CreatedDate))) = 1 THEN '0' ELSE '' END + CONVERT(nvarchar(2), DATEPART(second, CreatedDate)) AS CreatedDateSuffix,
				OriginalPath,
				[Path]
		FROM	dbo.ChartImageFileImport
		WHERE	(NotifyDate IS NULL) OR
				(NotifyDate >= DATEADD(minute, -1, GETDATE()))
		GROUP BY CreatedDate,
				OriginalPath,
				[Path]
    )
    SELECT * INTO #Summary FROM Summary;
    
    IF @MarkAsNotified = 1 
		BEGIN;
			DECLARE @NotifyDate datetime = GETDATE();
			
			UPDATE	CIFI
			SET		NotifyDate = @NotifyDate
			FROM	dbo.ChartImageFileImport AS CIFI
					INNER JOIN #Summary AS S
							ON CIFI.CreatedDate = S.CreatedDate AND
								CIFI.OriginalPath = S.OriginalPath AND
								CIFI.[Path] = S.[Path];
		END;
    
	SELECT	REPLACE(REPLACE(DB_NAME(), 'ChartNet_', ''), '_RDSM', '') + ' ChartNet Notification: ' + CONVERT(varchar(256), CountRecords) + ' chart image(s) imported' AS EmailSubject,
			'ChartNet successfully imported ' + CONVERT(varchar(256), CountRecords) + ' chart image(s).  Please see the attached list for detailed information.' AS EmailText, 
			'ImportSummary_' + CreatedDateSuffix AS SumFileName,
			SUBSTRING(OriginalPath, 1, LEN(OriginalPath) - 1) AS SumFilePath,			
			* 
	FROM	#Summary;
    
END

GO
