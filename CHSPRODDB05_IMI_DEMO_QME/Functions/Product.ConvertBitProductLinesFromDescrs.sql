SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/26/2014
-- Description:	Returns the BitProductLines value associated with the specified description aggregate list.
-- =============================================
CREATE FUNCTION [Product].[ConvertBitProductLinesFromDescrs]
(
	@value varchar(256)
)
RETURNS bigint 
AS
BEGIN
	
	DECLARE @delimiter varchar(16);
	DECLARE @result bigint;
	
	SET @delimiter = ' :: ';
	
	WITH ProductLineDescrs AS
	(
		SELECT	SUBSTRING(@delimiter + @value + @delimiter, N + DATALENGTH(@delimiter), CHARINDEX(@delimiter, @delimiter + @value + @delimiter, N + DATALENGTH(@delimiter)) - N - DATALENGTH(@delimiter)) AS Descr
		FROM	dbo.Tally AS T WITH(NOLOCK)
		WHERE	N <= DATALENGTH(@delimiter + @value) AND
				(CONVERT(varbinary(1024), SUBSTRING(@delimiter + @value + @delimiter, N, DATALENGTH(@delimiter))) = CONVERT(varbinary(1024), @delimiter))
	)
	SELECT	@result = ISNULL(SUM(BitValue), 0)
	FROM	Product.ProductLines AS PPL WITH(NOLOCK)
			INNER JOIN ProductLineDescrs AS t
					ON PPL.Descr = t.Descr;

	RETURN @result;
END



GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesFromDescrs] TO [Processor]
GO
