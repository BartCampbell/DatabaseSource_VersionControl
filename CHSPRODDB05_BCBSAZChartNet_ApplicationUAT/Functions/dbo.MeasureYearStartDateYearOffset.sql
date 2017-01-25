SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[MeasureYearStartDateYearOffset](@YearOffset int)
                    RETURNS datetime
                    AS
                    BEGIN
                    DECLARE @Result DATETIME
                    SELECT @Result = dateadd(month,((ParamIntValue-1900+@YearOffset)*12)+0,0) FROM dbo.SystemParams WHERE ParamName = 'MeasureYear'
                    RETURN @Result
                    END
                    
GO
GRANT EXECUTE ON  [dbo].[MeasureYearStartDateYearOffset] TO [Support]
GO
