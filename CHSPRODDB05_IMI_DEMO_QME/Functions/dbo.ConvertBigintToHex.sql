SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/5/2012
-- Description:	Converts an integer (as bigint) into the hexidecimal representation.
-- =============================================
CREATE FUNCTION [dbo].[ConvertBigintToHex] 
(
	@Value bigint,
	@Trim bit = 0
)
RETURNS varchar(16)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Result varchar(16);
	
	DECLARE @n varbinary(8);
	SET @n = CONVERT(varbinary(8), @Value);
	
	SET @Result = CONVERT(xml, N'').value('xs:hexBinary(sql:variable("@n"))', 'varchar(max)');
	
	IF @Trim = 1 
		IF PATINDEX('%[^0]%', @Result) > 0
			SET @Result = RIGHT(@Result, LEN(@Result) - PATINDEX('%[^0]%', @Result) + 1)
		ELSE
			SET @Result = '0';
	
	RETURN @Result;
END

GO
GRANT EXECUTE ON  [dbo].[ConvertBigintToHex] TO [Processor]
GO
