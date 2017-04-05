SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[IDSS_DataElements_TLM] AS 
WITH TLM AS
(
SELECT	IdssElementAbbrev,
		IdssElementDescr,
		IdssElementID,
		IdssMeasure,
		IdssMeasureDescr,
		MeasureSetID,
		CASE WHEN LEN(IdssElementAbbrev) = 8 THEN UPPER(SUBSTRING(IdssElementAbbrev, 7, 2)) END AS ProductLine,
		CASE WHEN LEN(IdssElementAbbrev) = 8 THEN UPPER(SUBSTRING(IdssElementAbbrev, 4, 3)) END AS ProductType
FROM	Ncqa.IDSS_DataElements AS DE
WHERE	IdssMeasure = 'TLM'
),
ProductLineConversion AS
(
	SELECT 'CO' AS ProductLine, ProductLineID FROM Product.ProductLines WHERE ProductLineID = 1
	UNION
	SELECT 'MI' AS ProductLine, ProductLineID FROM Product.ProductLines WHERE ProductLineID = 2
	UNION
	SELECT 'MA' AS ProductLine, ProductLineID FROM Product.ProductLines WHERE ProductLineID = 3
	UNION
	SELECT 'MK' AS ProductLine, ProductLineID FROM Product.ProductLines WHERE ProductLineID = 6
	UNION
	SELECT 'OT' AS ProductLine, ProductLineID FROM Product.ProductLines WHERE ProductLineID IN (4, 5, 7)
),
ProductTypeConversion AS
(
	SELECT	Abbrev AS ProductType, ProductTypeID
	FROM	Product.ProductTypes
),
DataElementsTLM AS
(
	SELECT	T.IdssElementAbbrev,
			T.IdssElementDescr,
			T.IdssElementID,
			T.IdssMeasure,
			T.IdssMeasureDescr,
			T.MeasureSetID,
			T.ProductLine,
			PL.ProductLineID,
			T.ProductType,
			PT.ProductTypeID
	FROM	TLM AS T
			LEFT OUTER JOIN ProductLineConversion AS PL
					ON T.ProductLine = PL.ProductLine
			LEFT OUTER JOIN ProductTypeConversion AS PT
					ON T.ProductType = PT.ProductType
)
SELECT	IdssElementID,
		MeasureSetID,
		ProductLineID,
		ProductTypeID
FROM	DataElementsTLM;

GO
