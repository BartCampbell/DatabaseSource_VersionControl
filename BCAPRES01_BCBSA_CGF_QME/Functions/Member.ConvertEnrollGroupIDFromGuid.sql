SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/28/2011
-- Description:	Returns the EnrollGroupID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Member].[ConvertEnrollGroupIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (CASE WHEN @value = CONVERT(varchar(36), CONVERT(uniqueidentifier, CONVERT(binary(16), 0))) 
				THEN 0
				ELSE (SELECT TOP 1 EnrollGroupID FROM Member.EnrollmentGroups WITH(NOLOCK) WHERE (EnrollGroupGuid = CONVERT(uniqueidentifier, @value, 0)))
				END);
END

GO
GRANT EXECUTE ON  [Member].[ConvertEnrollGroupIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertEnrollGroupIDFromGuid] TO [Submitter]
GO
