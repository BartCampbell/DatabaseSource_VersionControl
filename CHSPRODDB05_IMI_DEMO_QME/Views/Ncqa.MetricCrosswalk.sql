SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[MetricCrosswalk]
AS
SELECT  MX.AgeBandID, 
		NXK.BitProductLines,
		NXK.FromAgeMonths, 
		NXK.FromAgeMonths + NXK.FromAgeYears * 12 AS FromAgeTotMonths, 
		NXK.FromAgeYears, 
		NXK.Gender,
		MM.Abbrev AS MeasureAbbrev,
		MM.MeasureGuid, 
		MM.MeasureID, 
		MM.MeasureSetID, 
		MMX.MeasureXrefGuid,
		NXK.Abbrev AS MetricAbbrev, 
		MX.MetricGuid, 
		MX.MetricID, 
		NXK.InitAbbrev AS MetricInitAbbrev, 
		MMXX.MetricXrefGuid,
		NXK.ToAgeMonths, 
		NXK.ToAgeMonths + NXK.ToAgeYears * 12 AS ToAgeTotMonths, 
		NXK.ToAgeYears
FROM	Ncqa.MeasureKey AS NMK 
		INNER JOIN Measure.Measures AS MM 
				ON NMK.Abbrev = MM.Abbrev
		LEFT OUTER JOIN Measure.MeasureXrefs AS MMX
				ON MM.MeasureXrefID = MMX.MeasureXrefID 
		INNER JOIN Ncqa.MetricKey AS NXK 
				ON NMK.Abbrev = NXK.MeasureAbbrev AND
					MM.MeasureSetID = NXK.MeasureSetID
		INNER JOIN Measure.Metrics AS MX 
				ON MM.MeasureID = MX.MeasureID AND 
					NXK.Abbrev = MX.Abbrev
		LEFT OUTER JOIN Measure.MetricXrefs AS MMXX
				ON MX.MetricXrefID = MMXX.MetricXrefID;
GO
