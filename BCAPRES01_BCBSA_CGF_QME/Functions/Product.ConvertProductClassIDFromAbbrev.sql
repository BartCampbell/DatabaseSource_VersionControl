SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the ProductClassID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Product].[ConvertProductClassIDFromAbbrev]
(
	@value varchar(8)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 ProductClassID FROM Product.ProductClasses WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertProductClassIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertProductClassIDFromAbbrev] TO [Submitter]
GO
