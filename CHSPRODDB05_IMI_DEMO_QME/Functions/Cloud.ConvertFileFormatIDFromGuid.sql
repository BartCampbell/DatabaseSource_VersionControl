SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2016
-- Description:	Returns the FileFormatID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Cloud].[ConvertFileFormatIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 FileFormatID FROM Cloud.FileFormats WITH(NOLOCK) WHERE (FileFormatGuid = CONVERT(uniqueidentifier, @value, 0)));
END
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileFormatIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileFormatIDFromGuid] TO [Submitter]
GO
