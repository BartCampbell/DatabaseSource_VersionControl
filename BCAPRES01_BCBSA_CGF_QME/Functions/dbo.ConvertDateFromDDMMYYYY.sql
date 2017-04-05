SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/26/2016
-- Description:	Returns the date value converted from the supplied FromDDMMYYYY char value.
-- =============================================
CREATE FUNCTION [dbo].[ConvertDateFromDDMMYYYY]
(
	@value varchar(8)
)
RETURNS datetime
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Result datetime;
	
	IF ISNUMERIC(@value) = 1 AND LEN(@value) = 8
		BEGIN
			DECLARE @Day int;
			DECLARE @Month int;
			DECLARE @Year int;

			SET @Day = CAST(SUBSTRING(@value, 1, 2) AS int);
			SET @Month = CAST(SUBSTRING(@value, 3, 2) AS int);
			SET @Year = CAST(SUBSTRING(@value, 5, 4) AS int);

			IF (@Month BETWEEN 1 AND 12) AND (@Day BETWEEN 1 AND 31) AND (@Year BETWEEN 1753 AND 9999)
				SET @Result = DATEADD(dd, @Day - DAY(0), DATEADD(mm, @Month - MONTH(0), DATEADD(yy, @Year - YEAR(0), 0)));

			IF (@Result IS NOT NULL) AND (RIGHT(CONVERT(char(8), @Result, 112), 2) + SUBSTRING(CONVERT(char(8), @Result, 112), 5, 2) + LEFT(CONVERT(char(8), @Result, 112), 4) <> @value)
				SET @Result = NULL;
		END
		
	RETURN @Result;
END

GO
