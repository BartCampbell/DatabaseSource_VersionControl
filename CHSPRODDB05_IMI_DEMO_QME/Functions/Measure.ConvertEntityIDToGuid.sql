SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the GUID associated with the specified EntityID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertEntityIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (SELECT TOP 1 CONVERT(uniqueidentifier, EntityGuid, 0) FROM Measure.Entities WITH(NOLOCK) WHERE (EntityID = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDToGuid] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertEntityIDToGuid] TO [Submitter]
GO
