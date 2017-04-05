SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[StringBuild] (@Value [nvarchar] (4000), @Delimiter [nvarchar] (16), @IncludeBlanks [bit])
RETURNS [nvarchar] (max)
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[IMI.MeasureEngine.Data.SqlClr.StringBuild]
GO
