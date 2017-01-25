SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Result].[MeasureDetail_Classic] AS
SELECT	RMD.Age,
        RMD.AgeMonths,
        RMD.AgeBandID,
        RMD.AgeBandSegID,
        RMD.BatchID,
        RMD.BeginDate,
        RMD.BitProductLines,
        RMD.ClinCondID,
        RMD.DataRunID,
        RMD.DataSetID,
        RMD.[Days],
        RMD.DSEntityID,
        RMD.DSMemberID,
        RMD.DSProviderID,
        RMD.EndDate,
        RMD.EnrollGroupID,
        RMD.EntityID,
        RMD.ExclusionTypeID,
        RMD.Gender,
        RMD.IsDenominator,
        RMD.IsExclusion,
        RMD.IsIndicator,
        RMD.IsNumerator,
        RMD.IsNumeratorAdmin,
        RMD.IsNumeratorMedRcd,
		RMD.IsSupplementalDenominator,
        RMD.IsSupplementalExclusion,
        RMD.IsSupplementalIndicator,
        RMD.IsSupplementalNumerator,
        RMD.KeyDate,
        RMD.MeasureID,
        RMD.MeasureXrefID,
        RMD.MetricID,
        RMD.MetricXrefID,
        RMD.PayerID,
        RMD.PopulationID,
        PPL.ProductLineID,
        RMD.Qty,
		RMD.Qty2,
		RMD.Qty3,
		RMD.Qty4,
        RMD.ResultRowGuid,
        RMD.ResultRowID,
        RMD.ResultTypeID,
        RMD.SourceDenominator,
        RMD.SourceExclusion,
        RMD.SourceIndicator,
        RMD.SourceNumerator,
        RMD.SysSampleRefID,
        RMD.[Weight]
FROM	Result.MeasureDetail AS RMD
		INNER JOIN Product.ProductLines AS PPL
				ON (RMD.BitProductLines & PPL.BitValue > 0) OR (RMD.BitProductLines = 0 AND PPL.BitValue = 0)


GO
