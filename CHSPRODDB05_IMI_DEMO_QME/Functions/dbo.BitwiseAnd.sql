SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[BitwiseAnd] (@Value [bigint])
RETURNS [bigint]
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[IMI.MeasureEngine.Data.SqlClr.BitwiseAnd]
GO
GRANT EXECUTE ON  [dbo].[BitwiseAnd] TO [Processor]
GO
