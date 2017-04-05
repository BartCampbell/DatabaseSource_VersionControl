SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[BitwiseOr] (@Value [bigint])
RETURNS [bigint]
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[IMI.MeasureEngine.Data.SqlClr.BitwiseOr]
GO
