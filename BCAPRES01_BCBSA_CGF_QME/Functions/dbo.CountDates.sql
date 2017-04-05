SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[CountDates] (@Value [datetime], @DaysApart [tinyint], @IsConsecutive [bit])
RETURNS [bigint]
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[CountDates]
GO
