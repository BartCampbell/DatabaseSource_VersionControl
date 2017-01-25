SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE    PROC [CGF_REP].[MeasureDescAll]
AS

DECLARE @output TABLE ([ID] int IDENTITY(1,1), FieldValue varchar(100), DisplayValue varchar(100))

INSERT INTO @output 
(FieldValue, DisplayValue)
SELECT 
	FieldValue = NULL,
	DisplayValue = 'All Measures'

INSERT INTO @output 
(FieldValue, DisplayValue)
SELECT 
	FieldValue = SUBSTRING(MeasureDesc,5,100),
	DisplayValue = SUBSTRING(MeasureDesc,1,100)

FROM CGF.MetricDescList

--	Return 
SELECT * FROM @output






GO
