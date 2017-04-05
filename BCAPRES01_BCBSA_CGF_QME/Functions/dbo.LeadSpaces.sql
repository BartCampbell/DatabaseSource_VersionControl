SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/10/2011
-- Description:	Retrieves a text representation of a value of a specified length, formatted with leading spaces.
-- =============================================
CREATE FUNCTION [dbo].[LeadSpaces]
(
	@value sql_variant,
	@length tinyint
)
RETURNS nvarchar(128)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Result nvarchar(128)

	SET @Result = CAST(@value AS nvarchar(128))

	IF @length <> LEN(@Result)	
		IF @length < LEN(@Result)
			SET @Result = RIGHT(@Result, @length)
		ELSE
			SET @Result = REPLICATE(' ', @length - LEN(@Result)) + @Result

	RETURN @Result
END


GO
GRANT EXECUTE ON  [dbo].[LeadSpaces] TO [Processor]
GO
