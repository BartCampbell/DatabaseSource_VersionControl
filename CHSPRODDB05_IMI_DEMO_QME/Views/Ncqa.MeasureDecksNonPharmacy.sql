SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[MeasureDecksNonPharmacy] AS
WITH PharmacyMeasures AS 
(
	SELECT DISTINCT Measure FROM Ncqa.PharmacyMeasures
),
MeasureDecks AS
(
	SELECT	NMD.*, CASE WHEN PM.Measure IS NOT NULL THEN 1 ELSE 0 END AS HasPharmacy
	FROM	Ncqa.MeasureDecks AS NMD
			LEFT OUTER JOIN PharmacyMeasures AS PM
					ON NMD.Measure = PM.Measure
)
SELECT TOP 100 PERCENT
		*
FROM	MeasureDecks
WHERE	HasPharmacy = 0 AND
		NcqaDeck IS NOT NULL
ORDER BY Measure;
GO
