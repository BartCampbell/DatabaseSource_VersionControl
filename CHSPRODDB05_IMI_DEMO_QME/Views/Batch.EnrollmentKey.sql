SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Batch].[EnrollmentKey] AS
WITH Populations AS
(
	SELECT DISTINCT
			BB.BatchID,
			BB.DataRunID,
			BB.DataSetID,
			MEP.PopulationGuid,
			MEP.PopulationID,
			MEP.PopulationNum 
	FROM	Batch.DataOwners AS BDO
			INNER JOIN Member.EnrollmentPopulations AS MEP
					ON BDO.OwnerID = MEP.OwnerID
			INNER JOIN Batch.DataSets AS BDS
					ON MEP.OwnerID = BDS.OwnerID AND
						(
							(MEP.DataSetID IS NULL) OR
							(MEP.DataSetID = BDS.DataSetID)
						)
			INNER JOIN Batch.[Batches] AS BB
					ON BDS.DataSetID = BB.DataSetID
)
SELECT DISTINCT
		t.BatchID AS BatchID,
		t.DataRunID AS DataRunID,
		t.DataSetID AS DataSetID,
		MEG.EnrollGroupGuid,
		MEG.EnrollGroupID,
		PP.PayerGuid,
		PP.PayerID,
		t.PopulationGuid,
		t.PopulationID,
		t.PopulationNum,
		PPC.ProductClassGuid,
		PPT.ProductClassID,
		PPT.ProductTypeGuid,
		PP.ProductTypeID
FROM	Member.EnrollmentGroups AS MEG
		INNER JOIN Populations AS t
				ON MEG.PopulationID = t.PopulationID
		INNER JOIN Product.Payers AS PP
				ON MEG.PayerID = PP.PayerID
		INNER JOIN Product.ProductTypes AS PPT
				ON PP.ProductTypeID = PPT.ProductTypeID
		INNER JOIN Product.ProductClasses AS PPC
				ON PPT.ProductClassID = PPC.ProductClassID
GO
