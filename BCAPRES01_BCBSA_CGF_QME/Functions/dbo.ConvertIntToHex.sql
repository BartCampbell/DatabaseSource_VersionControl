SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/5/2012
-- Description:	Converts an integer into the hexidecimal representation.
-- =============================================
CREATE FUNCTION [dbo].[ConvertIntToHex] 
(
	@Value int,
	@Trim bit = 0
)
RETURNS varchar(8)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Result varchar(8);
	
	DECLARE @n varbinary(4);
	SET @n = CONVERT(varbinary(4), @Value);
	
	SET @Result = CONVERT(xml, N'').value('xs:hexBinary(sql:variable("@n"))', 'varchar(max)');
	
	IF @Trim = 1 
		IF PATINDEX('%[^0]%', @Result) > 0
			SET @Result = RIGHT(@Result, LEN(@Result) - PATINDEX('%[^0]%', @Result) + 1)
		ELSE
			SET @Result = '0';
	
	RETURN @Result;
END

GO
GRANT EXECUTE ON  [dbo].[ConvertIntToHex] TO [Processor]
GO
