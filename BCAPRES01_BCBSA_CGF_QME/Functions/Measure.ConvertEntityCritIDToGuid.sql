SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the GUID associated with the specified EntityCritID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEntityCritIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (SELECT TOP 1 CONVERT(uniqueidentifier, EntityCritGuid, 0) FROM Measure.EntityCriteria WITH(NOLOCK) WHERE (EntityCritID = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEntityCritIDToGuid] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityCritIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityCritIDToGuid] TO [Submitter]
GO
