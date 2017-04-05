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
	@DOB smalldatetime,
	@AsOfDate smalldatetime
)
RETURNS smallint
AS
BEGIN
	DECLARE @Result smallint	;

	SELECT	@Result =	CAST(DATEDIFF(month, @DOB, @AsOfDate) - 
										CASE WHEN ((DAY(@DOB) > DAY(@AsOfDate)) AND (MONTH(@DOB) = MONTH(@AsOfDate)))
											THEN 1 
											ELSE 0 END
							AS smallint);

	RETURN @Result;
END
GO
