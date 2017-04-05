SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2011
-- Description:	Returns the EntityID associated with the specified description.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEntityIDFromDescr]
(
	@value varchar(164)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 EntityID FROM Measure.Entities WITH(NOLOCK) WHERE (UniqueDescr = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDFromDescr] TO [Submitter]
GO
