SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2011
-- Description:	Returns the abbreviation associated with the specified EventID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEventIDToDescr]
(
	@value int
)
RETURNS varchar(164)
AS
BEGIN
	RETURN (SELECT TOP 1 UniqueDescr FROM Measure.[Events] WITH(NOLOCK) WHERE (EventID = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEventIDToDescr] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertEventIDToDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEventIDToDescr] TO [Submitter]
GO
