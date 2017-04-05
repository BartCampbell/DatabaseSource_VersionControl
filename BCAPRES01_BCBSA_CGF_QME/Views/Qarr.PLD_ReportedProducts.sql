SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
1  = MA
2  = HIV SNP
4  = CPPO
5  = CHMO
6  = QHMO
7  = QPOS
8  = QPPO
9  = QEPO
10 = CEPO
*/
CREATE VIEW [Qarr].[PLD_ReportedProducts] AS
WITH QarrProducts(ReportedProductID, ReportedProduct) AS
(
	SELECT 1, 'MA'
	UNION 
	SELECT 2, 'HIV SNP'
	UNION 
	SELECT 4, 'CPPO'
	UNION 
	SELECT 5, 'CHMO'
	UNION
	SELECT 6, 'QHMO'
	UNION 
	SELECT 7, 'QPOS'
	UNION 
	SELECT 8, 'QPPO'
	UNION 
	SELECT 9, 'QEPO'
	UNION 
	SELECT 10, 'CEPO'
),
ProductConversion AS
(
	SELECT	MNG.EnrollGroupID,
			MNG.PopulationID,
			MNPPL.ProductLineID,
			CASE WHEN MNPPL.ProductLineID = 2 
				 THEN 'MA'
				 WHEN MNPPL.ProductLineID IN (1, 6)
				 THEN REPLACE(PPL.Abbrev, 'M', 'Q') + PPT.Abbrev 
				 END AS ReportedProduct
	FROM	Member.EnrollmentPopulations AS MNP
			INNER JOIN Member.EnrollmentPopulationProductLines AS MNPPL
					ON MNPPL.PopulationID = MNP.PopulationID
			INNER JOIN Member.EnrollmentGroups AS MNG
					ON MNG.PopulationID = MNP.PopulationID
			INNER JOIN Product.Payers AS PP
					ON PP.PayerID = MNG.PayerID
			INNER JOIN Product.PayerProductLines AS PPPL
					ON PPPL.ProductLineID = MNPPL.ProductLineID AND
						PPPL.ProductLineID = PP.ProductLineID
			INNER JOIN Product.ProductTypes AS PPT
					ON PPT.ProductTypeID = PP.ProductTypeID
			INNER JOIN Product.ProductLines AS PPL
					ON PPL.ProductLineID = PPPL.ProductLineID
	WHERE MNG.PopulationID >= 45
)
SELECT	PLC.EnrollGroupID,
        PLC.PopulationID,
        PLC.ProductLineID,
        PLC.ReportedProduct,
		CONVERT(varchar(2), QP.ReportedProductID) AS ReportedProductID
FROM	ProductConversion AS PLC
		LEFT OUTER JOIN QarrProducts AS QP
				ON QP.ReportedProduct = PLC.ReportedProduct
GO
