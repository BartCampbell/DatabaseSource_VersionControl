SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/29/2015
-- Description:	Refreshes the population associated with the enrollment groups in all results tables.
-- =============================================
CREATE PROCEDURE [Result].[RefreshPopulationAssignment]
(
	@DataRunID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CountRecords bigint;

    UPDATE	RMD
	SET		PopulationID = MNG.PopulationID
	FROM	Result.MeasureDetail AS RMD
			INNER JOIN Member.EnrollmentGroups AS MNG
					ON MNG.EnrollGroupID = RMD.EnrollGroupID
	WHERE	(RMD.PopulationID <> MNG.PopulationID) AND
			((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID));

	SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

	UPDATE	RMMD
	SET		PopulationID = MNG.PopulationID
	FROM	Result.MemberMonthDetail AS RMMD
			INNER JOIN Member.EnrollmentGroups AS MNG
					ON MNG.EnrollGroupID = RMMD.EnrollGroupID
	WHERE	(RMMD.PopulationID <> MNG.PopulationID) AND
			((@DataRunID IS NULL) OR (RMMD.DataRunID = @DataRunID));

	SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

END

GO
GRANT VIEW DEFINITION ON  [Result].[RefreshPopulationAssignment] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[RefreshPopulationAssignment] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[RefreshPopulationAssignment] TO [Processor]
GO
