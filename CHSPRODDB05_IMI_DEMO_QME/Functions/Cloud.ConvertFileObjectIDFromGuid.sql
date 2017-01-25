SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2016
-- Description:	Returns the FileObjectID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Cloud].[ConvertFileObjectIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 FileObjectID FROM Cloud.FileObjects WITH(NOLOCK) WHERE (FileObjectGuid = CONVERT(uniqueidentifier, @value, 0)));
END
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileObjectIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileObjectIDFromGuid] TO [Submitter]
GO
