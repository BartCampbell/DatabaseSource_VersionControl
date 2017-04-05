SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/15/2012
-- Description:	Returns a text representation of the time elapsed between two dates.
-- =============================================
CREATE FUNCTION [dbo].[GetTimeElapse]
(
	@BeginDateTime datetime,
	@EndDateTime datetime
)
RETURNS varchar(64)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Result varchar(64);

	IF @BeginDateTime IS NOT NULL AND @EndDateTime IS NOT NULL	
		BEGIN
			DECLARE @BaseSeconds decimal(18,3);
			DECLARE @Days int;
			DECLARE @Hours int;
			DECLARE @Minutes int;
			DECLARE @Seconds int;

			SET @BaseSeconds = CONVERT(decimal(18, 3), DATEDIFF(ss, @BeginDateTime, @EndDateTime));
			
			SET @Days = (FLOOR(@BaseSeconds / 60 / 60 / 24));
			SET @Hours = (FLOOR(@BaseSeconds / 60 / 60)) - (@Days * 24) ;
			SET @Minutes = (FLOOR(@BaseSeconds / 60)) - ((@Days * 24 * 60) + (@Hours * 60));
			SET @Seconds = (ROUND(@BaseSeconds, 0)) - ((@Days * 24 * 60 * 60) + (@Hours * 60 * 60) + (@Minutes * 60));

			SET @Result = LTRIM(RTRIM(
								ISNULL(CONVERT(varchar(64), NULLIF(@Days, 0)) + ' day(s) ', '') + 
								ISNULL(CONVERT(varchar(64), NULLIF(@Hours, 0)) + ' hr(s) ', '') + 
								ISNULL(CONVERT(varchar(64), NULLIF(@Minutes, 0)) + ' min(s) ', '') +
								ISNULL(CONVERT(varchar(64), @Seconds) + ' sec(s) ', '')
							));
		END;
	
	RETURN @Result;
END
GO
GRANT EXECUTE ON  [dbo].[GetTimeElapse] TO [Processor]
GO
