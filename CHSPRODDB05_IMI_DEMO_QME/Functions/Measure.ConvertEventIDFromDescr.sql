SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2011
-- Description:	Returns the EventID associated with the specified description.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEventIDFromDescr]
(
	@value varchar(164)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 EventID FROM Measure.[Events] WITH(NOLOCK) WHERE (UniqueDescr = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEventIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEventIDFromDescr] TO [Submitter]
GO
