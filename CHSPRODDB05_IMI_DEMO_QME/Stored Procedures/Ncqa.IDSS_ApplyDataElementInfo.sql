SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/25/2012
-- Description:	Applies IDSS data element information from a previous MeasureSet to a new MeasureSet.
-- =============================================
CREATE PROCEDURE [Ncqa].[IDSS_ApplyDataElementInfo]
(
	@FromMeasureSetID int,
	@ToMeasureSetID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CountElements int;
	DECLARE @CountRecords int;
	
	SELECT @CountElements  = COUNT(*) FROM Ncqa.IDSS_DataElements WHERE MeasureSetID = @ToMeasureSetID;

	--1) Update RDM element descriptions on "new", used for element extrapolation in Ncqa.IDSS_DataElements_RDM...
	UPDATE	DE
	SET		IdssElementDescr = t.IdssElementDescr
	FROM	Ncqa.IDSS_DataElements AS DE
			INNER JOIN Ncqa.IDSS_DataElements AS t
					ON DE.IdssElementAbbrev = t.IdssElementAbbrev AND
						DE.IdssMeasure = t.IdssMeasure AND
						DE.MeasureSetID = @ToMeasureSetID AND
						t.MeasureSetID = @FromMeasureSetID
	WHERE	DE.IdssMeasure = 'RDM';

	--2) Copy IDSS configuration data to "new"...
    UPDATE	DE
    SET		AggregateID = t.AggregateID,
			ExclusionTypeID = t.ExclusionTypeID,
			FromAgeMonths = t.FromAgeMonths,
			FromAgeYears = t.FromAgeYears,
			Gender = t.Gender,
			IdssColumnID = t.IdssColumnID,
			IsAuxiliary = t.IsAuxiliary,
			IsBaseSample = t.IsBaseSample,
			IsInSample = t.IsInSample,
			IsUnknownAge = t.IsUnknownAge,
			MeasureAbbrev = t.MeasureAbbrev,
			MetricAbbrev = t.MetricAbbrev,
			PayerID = t.PayerID,
			ResultTypeID = t.ResultTypeID,
			ToAgeMonths = t.ToAgeMonths,
			ToAgeYears = t.ToAgeYears
    FROM	Ncqa.IDSS_DataElements AS DE
			INNER JOIN Ncqa.IDSS_DataElements AS t
					ON DE.IdssElementAbbrev = t.IdssElementAbbrev AND
						DE.IdssElementDescr = t.IdssElementDescr AND
						DE.IdssMeasure = t.IdssMeasure AND
						DE.IdssMeasureDescr = t.IdssMeasureDescr AND
						DE.BitProductLines & t.BitProductLines > 0 AND
						DE.MeasureSetID = @ToMeasureSetID AND
						t.MeasureSetID = @FromMeasureSetID
	WHERE	DE.AggregateID IS NULL AND
			DE.ExclusionTypeID IS NULL AND
			DE.FromAgeTotMonths IS NULL AND
			DE.Gender IS NULL AND
			DE.IdssColumnID IS NULL AND
			DE.MeasureAbbrev IS NULL AND
			DE.MeasureID IS NULL AND
			DE.MetricID IS NULL AND
			DE.ResultTypeID IS NULL AND
			DE.ToAgeTotMonths IS NULL;
			
	SET @CountRecords = @@ROWCOUNT;
	
	PRINT 'Applied IDSS configuration data for ' + CONVERT(varchar(256), @CountRecords) + ' data element(s) out of ' + CONVERT(varchar(256), ISNULL(@CountElements, 0)) + '.';
    
END

GO
GRANT VIEW DEFINITION ON  [Ncqa].[IDSS_ApplyDataElementInfo] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[IDSS_ApplyDataElementInfo] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[IDSS_ApplyDataElementInfo] TO [Processor]
GO
