SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[prRefreshAdministrativeData]
(
	@ImportAdminEvents bit = 1,
	@ImportMetricScoring bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ImportAdminEvents = 1
		BEGIN;
			PRINT 'Admin Events started.';

			BEGIN TRANSACTION TAdminEvent1;
			DELETE FROM dbo.AdministrativeEvent;
			EXEC dbo.prLoadAdministrativeEvent;
			COMMIT TRANSACTION TAdminEvent1;

			ALTER INDEX ALL ON dbo.AdministrativeEvent REBUILD;

			PRINT 'Admin Events completed.';
			PRINT '';
		END;

	IF @ImportMetricScoring = 1
		BEGIN;
			PRINT 'Metric Scoring started.';

			BEGIN TRANSACTION TMetric1;
			DELETE FROM dbo.MemberMeasureMetricScoring;
			EXEC dbo.prLoadMemberMeasureMetricScoring;
			COMMIT TRANSACTION TMetric1;

			ALTER INDEX ALL ON dbo.MemberMeasureMetricScoring REBUILD;
		
			PRINT 'Metric Scoring completed.';
			PRINT '';
		END;

	SELECT 'Refresh finished.' AS Result;

	EXEC dbo.prRescoreAllMeasures;

	SELECT 'Rescore finished.' AS Result;

END
GO
