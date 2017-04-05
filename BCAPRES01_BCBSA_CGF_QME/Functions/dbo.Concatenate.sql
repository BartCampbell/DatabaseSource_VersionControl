SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[Concatenate] (@Value [nvarchar] (4000), @Delimiter [nvarchar] (16))
RETURNS [nvarchar] (max)
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[Concatenate]
GO
