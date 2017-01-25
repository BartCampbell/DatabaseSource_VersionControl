SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[CountDates] (@Value [datetime], @DaysApart [tinyint])
RETURNS [bigint]
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[CountDates]
GO
GRANT EXECUTE ON  [dbo].[CountDates] TO [Processor]
GO
