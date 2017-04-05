SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Retrieves the age as of a specified date for individual based on date of birth.
-- =============================================
CREATE FUNCTION [Member].[GetAgeAsOf]
(
	@DOB smalldatetime,
	@AsOfDate smalldatetime
)
RETURNS tinyint
AS
BEGIN
	DECLARE @Result tinyint	;

	SELECT	@Result =	CAST(DATEDIFF(year, @DOB, @AsOfDate) - 
										CASE WHEN (MONTH(@DOB) > MONTH(@AsOfDate)) OR 
													((DAY(@DOB) > DAY(@AsOfDate)) AND (MONTH(@DOB) = MONTH(@AsOfDate)))
											THEN 1 
											ELSE 0 END
							AS tinyint);

	RETURN @Result;
END
GO
