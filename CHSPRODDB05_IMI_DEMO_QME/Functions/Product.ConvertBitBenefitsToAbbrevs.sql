SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/23/2013
-- Description:	Returns the abbreviation aggregate list associated with the specified BitBenefits value.
-- =============================================
CREATE FUNCTION [Product].[ConvertBitBenefitsToAbbrevs]
(
	@value bigint
)
RETURNS varchar(512)
AS
BEGIN
	DECLARE @delimiter varchar(16);
	DECLARE @result varchar(512);
	
	SET @delimiter = ' :: ';
	
	SELECT	@result = ISNULL(@result + @delimiter, '') + Abbrev
	FROM	Product.Benefits AS PB WITH(NOLOCK)
	WHERE	(BitValue & @value > 0)
	ORDER BY Abbrev;
	
	IF @result IS NULL
		SET @result = '';

	RETURN @result;
END


GO
GRANT EXECUTE ON  [Product].[ConvertBitBenefitsToAbbrevs] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertBitBenefitsToAbbrevs] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBitBenefitsToAbbrevs] TO [Submitter]
GO
