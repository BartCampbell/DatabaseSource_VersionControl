SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/24/2011
-- Description:	Returns the ProductLineID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Product].[ConvertProductLineIDFromAbbrev]
(
	@value varchar(8)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 ProductLineID FROM Product.ProductLines WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertProductLineIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertProductLineIDFromAbbrev] TO [Submitter]
GO
