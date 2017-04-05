SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[MetricCrosswalk] AS
SELECT	MX.AgeBandID,
		NXK.FromAgeMonths,
		NXK.FromAgeMonths + (NXK.FromAgeYears * 12) AS FromAgeTotMonths,
		NXK.FromAgeYears,
		MM.Abbrev AS MeasureAbbrev,
		MM.MeasureGuid, 
		MM.MeasureID, 
		MM.MeasureSetID,
		NXK.Abbrev AS MetricAbbrev, 
		MX.MetricGuid, 
		MX.MetricID,
		NXK.InitAbbrev AS MetricInitAbbrev, 
		NXK.ToAgeMonths,
		NXK.ToAgeMonths + (NXK.ToAgeYears * 12) AS ToAgeTotMonths,
		NXK.ToAgeYears 
FROM	Ncqa.MeasureKey AS NMK
		INNER JOIN Measure.Measures AS MM
				ON NMK.Abbrev = MM.Abbrev 
		INNER JOIN Ncqa.MetricKey AS NXK
				ON NMK.Abbrev = NXK.MeasureAbbrev 
		INNER JOIN Measure.Metrics AS MX
				ON MM.MeasureID = MX.MeasureID AND
					NXK.Abbrev = MX.Abbrev 
GO
