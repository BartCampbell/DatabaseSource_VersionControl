SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/27/2011
-- Description:	Retrieves the age in months as of a specified date for individual based on date of birth.
-- =============================================
CREATE FUNCTION [Member].[GetAgeInMonths]
(
	@DOB datetime,
	@AsOfDate datetime
)
RETURNS smallint
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Result smallint;

	IF DATEPART(dy, CONVERT(datetime, '12/31/' + CONVERT(char(4), YEAR(@DOB)))) = 366 AND MONTH(@DOB) = 2 AND DAY(@DOB) = 29 AND --Born on Leap Day 2/29
		DATEPART(dy, CONVERT(datetime, '12/31/' + CONVERT(char(4), YEAR(@AsOfDate)))) = 365 --As of Non-Leap Year
		SET @DOB = DATEADD(dd, -1, @DOB); --Treat DOB as 2/28

	IF @AsOfDate >= @DOB 
	SELECT	@Result =	CAST(DATEDIFF(month, @DOB, @AsOfDate) - 
										CASE WHEN ((DAY(@DOB) > DAY(@AsOfDate)) AND (MONTH(@DOB) = MONTH(@AsOfDate)))
											THEN 1 
											ELSE 0 END
							AS smallint);

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Member].[GetAgeInMonths] TO [Processor]
GO
