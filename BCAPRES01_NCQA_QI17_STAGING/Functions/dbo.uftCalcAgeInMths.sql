SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[uftCalcAgeInMths]
(
	@BegDt	VARCHAR( 8 ),		
	@EndDt	VARCHAR( 8 ) 		
)
RETURNS INT
AS
BEGIN

	-- Return the result of the function
	RETURN DATEDIFF(mm,@BegDt, @EndDt) - 
        CASE WHEN MONTH(@BegDt) = MONTH(@EndDt) 
				AND DAY(@BegDt) > DAY(@EndDt) 
        THEN 1 
        ELSE 0 
        END  

END
GO
