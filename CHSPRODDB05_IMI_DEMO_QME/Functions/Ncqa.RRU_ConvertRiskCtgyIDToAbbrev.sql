SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the abbreviation associated with the specified risk category.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertRiskCtgyIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Ncqa.RRU_RiskCategories WITH(NOLOCK) WHERE (RiskCtgyID = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRiskCtgyIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRiskCtgyIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRiskCtgyIDToAbbrev] TO [Submitter]
GO
