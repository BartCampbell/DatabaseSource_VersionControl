SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the EntityCritID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEntityCritIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 EntityCritID FROM Measure.EntityCriteria WITH(NOLOCK) WHERE (EntityCritGuid = CONVERT(uniqueidentifier, @value, 0)));
END


GO
GRANT EXECUTE ON  [Measure].[ConvertEntityCritIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityCritIDFromGuid] TO [Submitter]
GO
