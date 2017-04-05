SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[ToTitle] (@text [nvarchar] (max))
RETURNS [nvarchar] (max)
WITH EXECUTE AS CALLER
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[IMI.MeasureEngine.Data.SqlClr.StringFunctions].[ToTitle]
GO
