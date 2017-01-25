SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/3/2015
-- Description: Populates the metric key with values from a previous measure set.  
-- =============================================
CREATE PROCEDURE [Ncqa].[PopulateMetricKey]
(
	@FromMeasureSetID int,
	@ToMeasureSetID int
)
AS
BEGIN
	SET NOCOUNT ON;

    WITH PsuedoKey AS
	(
		SELECT	t.Abbrev,
				t.Descr,
				t.FromAgeMonths,
				t.FromAgeYears,
				t.HasAge,
				t.InitAbbrev,
				t.IsValid,
				t.MeasureAbbrev,
				@ToMeasureSetID AS MeasureSetID,
				t.ToAgeMonths,
				t.ToAgeYears
		FROM	Ncqa.MetricKey AS t
		WHERE	(t.MeasureSetID = @FromMeasureSetID)
	)
	INSERT INTO Ncqa.MetricKey
			(Abbrev,
			Descr,
			FromAgeMonths,
			FromAgeYears,
			HasAge,
			InitAbbrev,
			IsValid,
			MeasureAbbrev,
			MeasureSetID,
			ToAgeMonths,
			ToAgeYears)
	SELECT	t.Abbrev,
			t.Descr,
			t.FromAgeMonths,
			t.FromAgeYears,
			t.HasAge,
			t.InitAbbrev,
			t.IsValid,
			t.MeasureAbbrev,
			t.MeasureSetID,
			t.ToAgeMonths,
			t.ToAgeYears
	FROM	PsuedoKey AS t
			LEFT OUTER JOIN Ncqa.MetricKey AS NMK
					ON NMK.InitAbbrev = t.InitAbbrev AND
						NMK.MeasureSetID = t.MeasureSetID;

END

GO
GRANT EXECUTE ON  [Ncqa].[PopulateMetricKey] TO [Processor]
GO
