SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2013
-- Description:	Returns the default product line for each measure of the specified data run.
-- =============================================
CREATE FUNCTION [Result].[GetDefaultMeasureProductLines]
(	
	@DataRunID int = NULL,
	@OverrideProductLineID int = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH Results AS
	(
		SELECT DISTINCT
				t.AgeBandSegID,
				t.DataRunID,
				t.DataSetID,
				t.MeasureID,
				t.MetricID,
				t.MeasureXrefID,
				t.PopulationID,
				t.ProductLineID
		FROM	Result.MeasureSummary AS t WITH(NOLOCK)
		UNION 
		SELECT DISTINCT
				t.AgeBandSegID,
				t.DataRunID,
				t.DataSetID,
				t.MeasureID,
				t.MetricID,
				t.MeasureXrefID,
				t.PopulationID,
				t.ProductLineID
		FROM	Result.MeasureDetail AS t WITH(NOLOCK)
		WHERE	DataRunID NOT IN (SELECT DISTINCT DataRunID FROM Result.MeasureSummary)
	)
	SELECT	RMD.DataRunID,
			RMD.DataSetID,
			RMD.MeasureID,
			RMD.MeasureXrefID,
			RMD.PopulationID,
			ISNULL(@OverrideProductLineID, MIN(RMD.ProductLineID)) AS ProductLineID
	FROM	Results AS RMD WITH(NOLOCK)
			INNER JOIN Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
					ON ((RMD.AgeBandSegID = RDSMK.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
						RMD.DataRunID = RDSMK.DataRunID AND
						RMD.DataSetID = RDSMK.DataSetID AND
						RMD.MeasureID = RDSMK.MeasureID AND
						RMD.MetricID = RDSMK.MetricID AND
						RMD.PopulationID = RDSMK.PopulationID AND
						RMD.ProductLineID = RDSMK.ProductLineID
	WHERE	((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
	GROUP BY RMD.DataRunID,
			RMD.DataSetID,
			RMD.MeasureID,
			RMD.MeasureXrefID,
			RMD.PopulationID
	--OPTION (OPTIMIZE FOR (@DataRunID = NULL))
)
GO
