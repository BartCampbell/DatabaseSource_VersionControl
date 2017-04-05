SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the EntityID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEntityIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 EntityID FROM Measure.Entities WITH(NOLOCK) WHERE (EntityGuid = CONVERT(uniqueidentifier, @value, 0)));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDFromGuid] TO [Submitter]
GO
