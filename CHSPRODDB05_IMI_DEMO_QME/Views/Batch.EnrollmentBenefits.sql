SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Batch].[EnrollmentBenefits] AS
SELECT	BatchID,
        BenefitID,
        DataRunID,
        DataSetID,
        EnrollItemID
FROM	Proxy.EnrollmentBenefits AS PNB
UNION
SELECT DISTINCT
		PNB.BatchID,
        PBR.BenefitID,
        PNB.DataRunID,
        PNB.DataSetID,
        PNB.EnrollItemID
FROM	Proxy.EnrollmentBenefits AS PNB
		INNER JOIN Product.BenefitRelationships AS PBR
				ON PNB.BenefitID = PBR.ChildID
GO
