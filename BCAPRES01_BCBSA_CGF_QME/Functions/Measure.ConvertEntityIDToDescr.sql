SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2011
-- Description:	Returns the abbreviation associated with the specified EntityID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEntityIDToDescr]
(
	@value int
)
RETURNS varchar(164)
AS
BEGIN
	RETURN (SELECT TOP 1 UniqueDescr FROM Measure.Entities WITH(NOLOCK) WHERE (EntityID = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDToDescr] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDToDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDToDescr] TO [Submitter]
GO
