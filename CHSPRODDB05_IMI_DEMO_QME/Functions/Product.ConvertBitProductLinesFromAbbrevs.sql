SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/16/2013
-- Description:	Returns the BitProductLines value associated with the specified abbreviation aggregate list.
-- =============================================
CREATE FUNCTION [Product].[ConvertBitProductLinesFromAbbrevs]
(
	@value varchar(256)
)
RETURNS bigint 
AS
BEGIN
	
	DECLARE @delimiter varchar(16);
	DECLARE @result bigint;
	
	SET @delimiter = ' :: ';
	
	WITH ProductLineAbbrevs AS
	(
		SELECT	SUBSTRING(@delimiter + @value + @delimiter, N + DATALENGTH(@delimiter), CHARINDEX(@delimiter, @delimiter + @value + @delimiter, N + DATALENGTH(@delimiter)) - N - DATALENGTH(@delimiter)) AS Abbrev
		FROM	dbo.Tally AS T WITH(NOLOCK)
		WHERE	N <= DATALENGTH(@delimiter + @value) AND
				(CONVERT(varbinary(1024), SUBSTRING(@delimiter + @value + @delimiter, N, DATALENGTH(@delimiter))) = CONVERT(varbinary(1024), @delimiter))
	)
	SELECT	@result = ISNULL(SUM(BitValue), 0)
	FROM	Product.ProductLines AS PPL WITH(NOLOCK)
			INNER JOIN ProductLineAbbrevs AS t
					ON PPL.Abbrev = t.Abbrev;

	RETURN @result;
END


GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesFromAbbrevs] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesFromAbbrevs] TO [Submitter]
GO
