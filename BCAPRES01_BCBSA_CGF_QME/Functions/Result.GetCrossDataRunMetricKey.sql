SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/20/2012
-- Description:	Retrieves a cross-data-run measure/metric/age-band key.
-- =============================================
CREATE FUNCTION [Result].[GetCrossDataRunMetricKey]
(	
	@FromDataRunID int,
	@ToDataRunID int
)
RETURNS TABLE 
AS
RETURN 
(
	WITH FromDataSetMetricKey AS
	(
		SELECT * FROM Result.DataSetMetricKey WITH(NOLOCK) WHERE DataRunID = @FromDataRunID
	),
	ToDataSetMetricKey AS
	(
		SELECT * FROM Result.DataSetMetricKey WITH(NOLOCK) WHERE DataRunID = @ToDataRunID
	)
	SELECT DISTINCT
			ISNULL(t1.AgeBandSegDescr, t2.AgeBandSegDescr) AS AgeBandSegDescr,
			ISNULL(t1.AgeBandSegID, t2.AgeBandSegID) AS AgeBandSegID,
			ISNULL(t1.BenefitDescr, t2.BenefitDescr) AS BenefitDescr,
			ISNULL(t1.BenefitID, t2.BenefitID) AS BenefitID,
			t1.DataRunID AS FromDataRunID,
			t1.DataSetID AS FromDataSetID,
			t1.MeasureGuid AS FromMeasureGuid,
			t1.MeasureID AS FromMeasureID,
			t1.MetricGuid AS FromMetricGuid,
			t1.MetricID AS FromMetricID,
			ISNULL(t1.Gender, t2.Gender) AS Gender,
			ISNULL(t1.IsHybrid, t2.IsHybrid) AS IsHybrid,
			ISNULL(t1.MeasClassDescr, t2.MeasClassDescr) AS MeasClassDescr,
			ISNULL(t1.MeasClassID, t2.MeasClassID) AS MeasClassID,
			ISNULL(t1.MeasureAbbrev, t2.MeasureAbbrev) AS MeasureAbbrev,
			ISNULL(t1.MeasureDescr, t2.MeasureDescr) AS MeasureDescr,
			ISNULL(t1.MetricAbbrev, t2.MetricAbbrev) AS MetricAbbrev,
			ISNULL(t1.MetricDescr, t2.MetricDescr) AS MetricDescr,
			ISNULL(t1.PopulationID, t2.PopulationID) AS PopulationID,
			ISNULL(t1.ProductLineID, t2.ProductLineID) AS ProductLineID,
			ISNULL(t1.SubMeasClassDescr, t2.SubMeasClassDescr) AS SubMeasClassDescr,
			ISNULL(t1.SubMeasClassID, t2.SubMeasClassID) AS SubMeasClassID,
			t2.DataRunID AS ToDataRunID,
			t2.DataSetID AS ToDataSetID,
			t2.MeasureGuid AS ToMeasureGuid,
			t2.MeasureID AS ToMeasureID,
			t2.MetricGuid AS ToMetricGuid,
			t2.MetricID AS ToMetricID,
			ISNULL(t1.TopMeasClassDescr, t2.TopMeasClassDescr) AS TopMeasClassDescr,
			ISNULL(t1.TopMeasClassID, t2.TopMeasClassID) AS TopMeasClassID
	FROM	FromDataSetMetricKey AS t1
			FULL OUTER JOIN ToDataSetMetricKey AS t2
					ON (	
							(t1.AgeBandSegID = t2.AgeBandSegID) OR 
							(t1.AgeBandSegID IS NULL AND t2.AgeBandSegID IS NULL)
						) AND
						--t1.DataRunID <> t2.DataRunID AND
						--t1.DataSetID <> t2.DataSetID AND
						t1.MeasureAbbrev = t2.MeasureAbbrev AND
						t1.MetricAbbrev = t2.MetricAbbrev AND
						t1.PopulationID = t2.PopulationID AND
						t1.ProductLineID = t2.ProductLineID
)
GO
