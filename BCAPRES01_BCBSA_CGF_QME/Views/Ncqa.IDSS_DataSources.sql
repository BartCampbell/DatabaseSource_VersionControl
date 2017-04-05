SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[IDSS_DataSources] AS
WITH XDMSets AS
(
	SELECT	SUM(RMD.CountMembers) AS CountMembers,
			RMD.DataRunID, RMD.DataSetID, RMD.MeasureID, RMD.PopulationID,
			RMD.ProductLineID, RMD.ResultTypeID
	FROM	Result.MeasureSummary AS RMD
			INNER JOIN Measure.Metrics AS MX
					ON MX.MetricID = RMD.MetricID
	WHERE	MX.Abbrev LIKE 'LDM3_' OR 
			MX.Abbrev LIKE'RDM0_'
	GROUP BY RMD.DataRunID, RMD.DataSetID, RMD.MeasureID, RMD.PopulationID,
			RMD.ProductLineID, RMD.ResultTypeID
),
XDMMetrics AS
(
	SELECT	XS.CountMembers,
			XS.DataRunID, XS.DataSetID, XS.MeasureID, 
			MX.MetricID, XS.PopulationID,
			XS.ProductLineID, XS.ResultTypeID
	FROM	XDMSets AS XS
			INNER JOIN Measure.Metrics AS MX
					ON XS.MeasureID = MX.MeasureID
)
SELECT	SUM(ISNULL(RMS.CountMembers, 0)) AS CountMembers,
		MIN(XDM.CountMembers) AS CountMembers2,
		XDM.DataRunID, XDM.DataSetID, XDM.MeasureID, 
		MX.Abbrev AS Metric,
		XDM.MetricID, 
		CASE 
				WHEN SUM(XDM.CountMembers) > 0 
				THEN CASE 
						 WHEN ISNULL(CAST(SUM(RMS.CountMembers) AS decimal(24,12)), 0) / CAST(MIN(XDM.CountMembers) AS decimal(24,12)) > 1.0000 
						 THEN 1 
						 WHEN ISNULL(CAST(SUM(RMS.CountMembers) AS decimal(24,12)), 0) / CAST(MIN(XDM.CountMembers) AS decimal(24,12)) < 0 
						 THEN 0
						 ELSE ISNULL(CAST(SUM(RMS.CountMembers) AS decimal(24,12)), 0) / CAST(MIN(XDM.CountMembers) AS decimal(24,12))
						 END
				ELSE CAST(0 AS decimal(24,12)) 
				END AS [Percent],
		XDM.PopulationID,
		XDM.ProductLineID, XDM.ResultTypeID
FROM	XDMMetrics AS XDM
		INNER JOIN Measure.Measures AS MM
				ON XDM.MeasureID = MM.measureID
		INNER JOIN Measure.Metrics AS MX
				ON MM.MeasureID = MX.MeasureID AND
					XDM.MeasureID = MX.MeasureID AND
					XDM.MetricID = MX.MetricID
		LEFT OUTER JOIN Result.MeasureSummary AS RMS
				ON XDM.DataRunID = RMS.DataRunID AND
					XDM.DataSetID = RMS.DataSetID AND
					XDM.MeasureID = RMS.MeasureID AND
					XDM.MetricID = RMS.MetricID AND
					XDM.PopulationID = RMS.PopulationID AND
					XDM.ProductLineID = RMS.ProductLineID AND
					XDM.ResultTypeID = RMS.ResultTypeID
GROUP BY XDM.DataRunID, 
		XDM.DataSetID, 
		XDM.MeasureID, 
		XDM.MetricID, 
		XDM.PopulationID,
		XDM.ProductLineID,
		XDM.ResultTypeID,
		MM.Abbrev,
		MX.Abbrev
--ORDER BY DataRunID, Metric



GO
