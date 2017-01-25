SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[MeasureYearHalfway](@YearOffset int)
                        RETURNS datetime
                        AS
                        BEGIN
                        DECLARE @Result DATETIME
                        SELECT @Result = dateadd(month,((ParamIntValue-1900+@YearOffset)*12)+5,30) + dateadd(ss,(23*3600)+(59*60)+59,0) FROM dbo.SystemParams WHERE ParamName = 'MeasureYear'
                        RETURN @Result
                        END
GO
GRANT EXECUTE ON  [dbo].[MeasureYearHalfway] TO [Support]
GO
