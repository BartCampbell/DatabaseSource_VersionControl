SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2016
-- Description:	Returns the GUID associated with the specified FileFormatID.
-- =============================================
CREATE FUNCTION [Cloud].[ConvertFileFormatIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (SELECT TOP 1 CONVERT(uniqueidentifier, FileFormatGuid, 0) FROM Cloud.FileFormats WITH(NOLOCK) WHERE (FileFormatID = @value));
END
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileFormatIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConvertFileFormatIDToGuid] TO [Submitter]
GO
