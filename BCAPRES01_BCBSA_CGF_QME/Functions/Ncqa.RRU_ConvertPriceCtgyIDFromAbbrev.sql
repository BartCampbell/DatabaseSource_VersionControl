SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the PriceCtgyID associated with the specified abbreviation.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertPriceCtgyIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 PriceCtgyID FROM Ncqa.RRU_PriceCategories WITH(NOLOCK) WHERE (Abbrev = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyIDFromAbbrev] TO [Submitter]
GO
