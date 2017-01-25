SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the abbreviation associated with the specified PayerID.
-- =============================================
CREATE FUNCTION [Product].[ConvertPayerIDToAbbrev]
(
	@value smallint
)
RETURNS varchar(8)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Product.Payers WITH(NOLOCK) WHERE (PayerID = @value));
END


GO
GRANT EXECUTE ON  [Product].[ConvertPayerIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertPayerIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertPayerIDToAbbrev] TO [Submitter]
GO
