SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/5/2016
-- Description:	Retrieves a list of file fields that do not have matching columns in the database as configured.  
-- =============================================
CREATE PROCEDURE [Cloud].[IdentifyInvalidFileFields]
(
	@FileFormatID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	WITH TableObjects AS
	(
		SELECT	CFO.OutSourceName AS TABLE_NAME,
				CFO.OutSourceSchema AS TABLE_SCHEMA,
				CFF.SourceColumn AS COLUMN_NAME, 
				CFO.FileFormatID,
				CFO.FileObjectID,
				CFO.ObjectName
		FROM	Cloud.FileObjects AS CFO
				INNER JOIN Cloud.FileFields AS CFF
						ON CFF.FileObjectID = CFO.FileObjectID
		WHERE	CFF.IsShown = 1 AND
				CFO.IsEnabled = 1
		UNION 
		SELECT	CFO.InSourceName AS TABLE_NAME,
				CFO.InSourceSchema AS TABLE_SCHEMA,
				CFF.SourceColumn AS COLUMN_NAME, 
				CFO.FileFormatID,
				CFO.FileObjectID,
				CFO.ObjectName
		FROM	Cloud.FileObjects AS CFO
				INNER JOIN Cloud.FileFields AS CFF
						ON CFF.FileObjectID = CFO.FileObjectID
		WHERE	CFO.InSourceName IS NOT NULL AND
				CFF.IsShown = 1 AND
				CFO.IsEnabled = 1
	)
	SELECT	O.*
	FROM	TableObjects AS O
			LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS AS C
					ON C.COLUMN_NAME = O.COLUMN_NAME AND
						C.TABLE_NAME = O.TABLE_NAME AND 
						C.TABLE_SCHEMA = O.TABLE_SCHEMA
	WHERE	((@FileFormatID IS NULL) OR (O.FileFormatID = @FileFormatID)) AND
			(C.COLUMN_NAME IS NULL)
	ORDER BY O.FileFormatID,
			O.FileObjectID, 
			C.COLUMN_NAME;
END
GO
GRANT EXECUTE ON  [Cloud].[IdentifyInvalidFileFields] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[IdentifyInvalidFileFields] TO [Submitter]
GO
