SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[MeasureYearEndDateYearOffset](@YearOffset int)
                    RETURNS datetime
                    AS
                    BEGIN
                    DECLARE @Result DATETIME
                    SELECT @Result = dateadd(month,((ParamIntValue-1900+@YearOffset)*12)+11,30) + dateadd(ss,(11*3600)+(59*60)+59,0) FROM dbo.SystemParams  WHERE ParamName = 'MeasureYear' 
                    RETURN @Result
                    END
                    
GO
GRANT EXECUTE ON  [dbo].[MeasureYearEndDateYearOffset] TO [Support]
GO
