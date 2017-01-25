SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the PayerID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Product].[ConvertPayerIDFromAbbrev]
(
	@value varchar(8)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 PayerID FROM Product.Payers WITH(NOLOCK) WHERE (Abbrev = @value));
END


GO
GRANT EXECUTE ON  [Product].[ConvertPayerIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertPayerIDFromAbbrev] TO [Submitter]
GO
