SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/26/2014
-- Description:	Returns the description aggregate list associated with the specified BitProductLines value.
-- =============================================
CREATE FUNCTION [Product].[ConvertBitProductLinesToDescrs]
(
	@value bigint
)
RETURNS varchar(256)
AS
BEGIN
	DECLARE @delimiter varchar(16);
	DECLARE @result varchar(256);
	
	SET @delimiter = ' :: ';
	
	SELECT	@result = ISNULL(@result + @delimiter, '') + Descr
	FROM	Product.ProductLines AS PPL WITH(NOLOCK)
	WHERE	(BitValue & @value > 0)
	ORDER BY Descr;
	
	IF @result IS NULL
		SET @result = '';

	RETURN @result;
END

GO
GRANT EXECUTE ON  [Product].[ConvertBitProductLinesToDescrs] TO [Processor]
GO
