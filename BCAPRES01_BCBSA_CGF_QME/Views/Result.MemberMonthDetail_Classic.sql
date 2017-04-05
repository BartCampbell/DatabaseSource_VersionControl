SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Result].[MemberMonthDetail_Classic] AS
SELECT	RMMD.Age,
        RMMD.AgeMonths,
        RMMD.BatchID,
        PB.BenefitID,
        RMMD.BitBenefits,
        RMMD.BitProductLines,
        RMMD.CountMonths,
        RMMD.DataRunID,
        RMMD.DataSetID,
        RMMD.DSMemberID,
        RMMD.EnrollGroupID,
        RMMD.Gender,
        RMMD.PayerID,
        RMMD.PopulationID,
        PPL.ProductLineID,
        RMMD.ResultRowGuid,
        RMMD.ResultRowID
FROM	Result.MemberMonthDetail AS RMMD
		INNER JOIN Product.Benefits AS PB
				ON (RMMD.BitBenefits & PB.BitValue > 0) OR (RMMD.BitBenefits = 0 AND PB.BitValue = 0)
		INNER JOIN Product.ProductLines AS PPL
				ON (RMMD.BitProductLines & PPL.BitValue > 0) OR (RMMD.BitProductLines = 0 AND PPL.BitValue = 0)
GO
