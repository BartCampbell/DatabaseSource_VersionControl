SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2016
-- Description:	Returns the GUID associated with the specified FileObjectID.
-- =============================================
CREATE FUNCTION [Cloud].[ConvertFileObjectIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (SELECT TOP 1 CONVERT(uniqueidentifier, FileObjectGuid, 0) FROM Cloud.FileObjects WITH(NOLOCK) WHERE (FileObjectID = @value));
END
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileObjectIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileObjectIDToGuid] TO [Submitter]
GO
