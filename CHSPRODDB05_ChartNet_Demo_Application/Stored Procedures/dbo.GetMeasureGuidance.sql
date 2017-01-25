SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetMeasureGuidance]
(
	@PursuitEventID int
)
AS
BEGIN
	
	DECLARE @SqlCmd nvarchar(max);
	DECLARE @SqlParams nvarchar(max);

	SELECT	@SqlCmd = 'SELECT [Title], [Value] FROM ' + QUOTENAME(MG.TvfSchema) + '.' + QUOTENAME(MG.TvfName) + '(@PursuitEventID) ORDER BY SortOrder;',
			@SqlParams = '@PursuitEventID int'
	FROM	dbo.PursuitEvent AS RV
			INNER JOIN dbo.MeasureGuidance AS MG
					ON RV.MeasureID = MG.MeasureID
	WHERE	RV.PursuitEventID = @PursuitEventID;

	EXEC sys.sp_executesql @SqlCmd, @SqlParams, @PursuitEventID = @PursuitEventID;

END
GO
