SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[IDSS_DataElements_RDM] AS
WITH Race AS
(
	SELECT	MX.*, MM.MeasureSetID, RIGHT(MX.Abbrev, 2) AS RaceAbbrev, RIGHT(MX.Abbrev, 2) AS RaceID
	FROM	Measure.Metrics AS MX
			INNER JOIN Measure.Measures AS MM
					ON MX.MeasureID = MM.MeasureID
	WHERE	MX.Abbrev LIKE 'RDM0%'
),
Ethnicity AS
(
	SELECT	MX.*, MM.MeasureSetID, RIGHT(MX.Abbrev, 2) AS EthnAbbrev, RIGHT(MX.Abbrev, 2) AS EthnicityID
	FROM	Measure.Metrics AS MX
			INNER JOIN Measure.Measures AS MM
					ON MX.MeasureID = MM.MeasureID
	WHERE	MX.Abbrev LIKE 'RDM1%'
),
DataSource AS
(
	SELECT	MX.*, MM.MeasureSetID, RIGHT(MX.Abbrev, 2) AS SourceAbbrev
	FROM	Measure.Metrics AS MX
			INNER JOIN Measure.Measures AS MM
					ON MX.MeasureID = MM.MeasureID
	WHERE	MX.Abbrev LIKE 'RDM2%'
),
DataElementsRDM AS
(
	SELECT	e.Descr AS Ethnicity,
			e.EthnicityID, 
			e.MetricID AS EthnMetricID,
			k.IdssElementAbbrev, 
			k.IdssElementDescr,
			k.IdssElementID,
			k.IdssMeasure, 
			k.IdssMeasureDescr, 
			k.MeasureSetID,
			r.Descr AS Race, 
			r.RaceID, 
			r.MetricID AS RaceMetricID
	FROM	Ncqa.IDSS_DataElements AS k
			LEFT OUTER JOIN Race AS r
					ON (CASE WHEN CHARINDEX(r.Descr, k.IdssElementDescr) = 1 THEN 1 ELSE 0 END = 1) AND 
						k.MeasureSetID = r.MeasureSetID
			LEFT OUTER JOIN Ethnicity AS e
					ON (CASE WHEN CHARINDEX(e.Descr, k.IdssElementDescr) > 0 THEN 1 ELSE 0 END = 1) AND 
						k.MeasureSetID = e.MeasureSetID AND
						(
							((e.Descr = 'Hispanic or Latino') AND (k.IdssElementDescr NOT LIKE '%Not Hispanic or Latino%')) OR
							(e.Descr <> 'Hispanic or Latino')
						)
	WHERE	--((k.IdssColumnID = '') OR (k.IdssColumnID IS NULL)) AND
			(k.IdssMeasure = 'RDM') AND
			(e.Descr IS NOT NULL) AND
			(r.Descr IS NOT NULL)
)
SELECT	EthnMetricID,
		IdssElementID,
		MeasureSetID,
		RaceMetricID
FROM	DataElementsRDM
GO
