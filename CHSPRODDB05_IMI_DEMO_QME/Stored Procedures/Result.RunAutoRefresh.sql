SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/30/2012
-- Description:	Refreshs medical record and hybrid ChartNet results fir the "auto" refresh data runs of the specified measure set.
-- =============================================
CREATE PROCEDURE [Result].[RunAutoRefresh]
(
	@MeasureSetID int
)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @DataRuns TABLE
	(
		DataRunID int NOT NULL,
		ID int IDENTITY(1, 1) NOT NULL
	);
	
	INSERT INTO @DataRuns
	        (DataRunID)
	SELECT	DataRunID
	FROM	Result.DataSetRunKey
	WHERE	(AllowAutoRefresh = 1) AND
			(MeasureSetID = @MeasureSetID);
	
	DECLARE @DataRunID int;
	DECLARE @ID int;
	DECLARE @MaxID int;
	DECLARE @MinID int;
		
	SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM @DataRuns;
	
	WHILE @ID BETWEEN @MinID AND @MaxID	
		BEGIN;
			SELECT @DataRunID = DataRunID FROM @DataRuns WHERE ID = @ID;
			
			PRINT '********************************************************';
			PRINT 'Refreshing Data Run ' + CONVERT(varchar(32), @DataRunID) + '...'
			PRINT '********************************************************';
			PRINT '';
			
			EXEC ChartNet.RefreshAllData @DataRunID = @DataRunID;			
		
			SET @ID = @ID + 1
		END;
		
END

GO
GRANT VIEW DEFINITION ON  [Result].[RunAutoRefresh] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[RunAutoRefresh] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[RunAutoRefresh] TO [Processor]
GO
