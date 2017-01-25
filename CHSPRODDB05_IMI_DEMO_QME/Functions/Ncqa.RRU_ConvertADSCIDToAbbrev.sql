SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the abbreviation associated with the specified ADSC.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertADSCIDToAbbrev]
(
	@value smallint
)
RETURNS varchar(4)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Ncqa.RRU_ADSC WITH(NOLOCK) WHERE (ADSCID = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertADSCIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertADSCIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertADSCIDToAbbrev] TO [Submitter]
GO
