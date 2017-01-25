SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/16/2013
-- Description:	Returns the abbreviation aggregate list associated with the specified BitProductLines value.
-- =============================================
CREATE FUNCTION [Product].[ConvertBitProductLinesToAbbrevs]
(
	@value bigint
)
RETURNS varchar(256)
AS
BEGIN
	DECLARE @delimiter varchar(16);
	DECLARE @result varchar(256);
	
	SET @delimiter = ' :: ';
	
	SELECT	@result = ISNULL(@result + @delimiter, '') + Abbrev
	FROM	Product.ProductLines AS PPL WITH(NOLOCK)
	WHERE	(BitValue & @value > 0)
	ORDER BY Abbrev;
	
	IF @result IS NULL
		SET @result = '';

	RETURN @result;
END

GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesToAbbrevs] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesToAbbrevs] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesToAbbrevs] TO [Submitter]
GO
