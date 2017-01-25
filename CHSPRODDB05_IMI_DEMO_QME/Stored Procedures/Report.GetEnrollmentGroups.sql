SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/5/2016
-- Description:	Retrieves a list of enrollment groups associated with the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetEnrollmentGroups]
(
	@AllowAll bit = 1,
	@DataRunID int,
	@PopulationID int,
	@ProductLineID int
)
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY;
		WITH GroupsInResults AS
		(
			SELECT DISTINCT EnrollGroupID FROM Result.MeasureSummary WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID AND ProductLineID = @ProductLineID
			UNION
			SELECT DISTINCT EnrollGroupID FROM Result.MemberMonthSummary WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID AND ProductLineID = @ProductLineID
		),
		Results AS 
		(
			SELECT	'(All Enrollment Groups)' AS Descr, CAST(NULL AS int) AS ID
			UNION ALL
			SELECT DISTINCT
					MNG.Abbrev + ' - ' + MNG.Descr AS Descr,
					MNG.EnrollGroupID AS ID
			FROM	Member.EnrollmentGroups AS MNG
					INNER JOIN GroupsInResults AS t
							ON t.EnrollGroupID = MNG.EnrollGroupID
		)
		SELECT	Descr, ID
		FROM	Results
		WHERE	((@AllowAll = 1) OR ((@AllowAll = 0) AND (ID IS NOT NULL)))
		ORDER BY Descr;
	
		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END
GO
GRANT EXECUTE ON  [Report].[GetEnrollmentGroups] TO [Reports]
GO
