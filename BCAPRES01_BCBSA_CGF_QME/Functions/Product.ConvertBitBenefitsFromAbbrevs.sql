SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/23/2013
-- Description:	Returns the BitBenefits value associated with the specified abbreviation aggregate list.
-- =============================================
CREATE FUNCTION [Product].[ConvertBitBenefitsFromAbbrevs]
(
	@value varchar(512)
)
RETURNS bigint 
AS
BEGIN
	
	DECLARE @delimiter varchar(16);
	DECLARE @result bigint;
	
	SET @delimiter = ' :: ';
	
	WITH BenefitAbbrevs AS
	(
		SELECT	SUBSTRING(@delimiter + @value + @delimiter, N + DATALENGTH(@delimiter), CHARINDEX(@delimiter, @delimiter + @value + @delimiter, N + DATALENGTH(@delimiter)) - N - DATALENGTH(@delimiter)) AS Abbrev
		FROM	dbo.Tally AS T WITH(NOLOCK)
		WHERE	N <= DATALENGTH(@delimiter + @value) AND
				(CONVERT(varbinary(2048), SUBSTRING(@delimiter + @value + @delimiter, N, DATALENGTH(@delimiter))) = CONVERT(varbinary(2048), @delimiter))
	)
	SELECT	@result = ISNULL(SUM(BitValue), 0)
	FROM	Product.Benefits AS PB WITH(NOLOCK)
			INNER JOIN BenefitAbbrevs AS t
					ON PB.Abbrev = t.Abbrev;

	RETURN @result;
END



GO
GRANT EXECUTE ON  [Product].[ConvertBitBenefitsFromAbbrevs] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBitBenefitsFromAbbrevs] TO [Submitter]
GO
