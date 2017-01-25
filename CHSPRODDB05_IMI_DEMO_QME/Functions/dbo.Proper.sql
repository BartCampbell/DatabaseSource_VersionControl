SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Proper] (@InputText nvarchar(max))
RETURNS nvarchar(max) WITH SCHEMABINDING AS
BEGIN

	DECLARE @i int
	DECLARE @c nvarchar(1)

	SET @i = 0

	WHILE @i < LEN(@InputText)
	BEGIN
		SET @i = @i + 1

		IF (@i = 1) OR (ASCII(SUBSTRING(@InputText, @i - 1, 1)) BETWEEN 32 AND 47) OR (ASCII(SUBSTRING(@InputText, @i - 1, 1)) BETWEEN 91 AND 96) OR (ASCII(SUBSTRING(@InputText, @i - 1, 1)) BETWEEN 123 AND 126) OR (UPPER(SUBSTRING(@InputText, @i - 2, 2)) = 'MC') OR (UPPER(SUBSTRING(@InputText, @i - 3, 3)) = 'MAC')
		SET @c = UPPER(SUBSTRING(@InputText, @i, 1))
		ELSE
		SET @c = LOWER(SUBSTRING(@InputText, @i, 1))

		SET @InputText = STUFF(@InputText, @i, 1, @c)		
	END

	RETURN @InputText
END
GO
GRANT EXECUTE ON  [dbo].[Proper] TO [Processor]
GO
