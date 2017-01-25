SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Cloud].[FileFieldInfo] AS
WITH Fields AS
(
	SELECT	NFF.CreatedBy,
			NFF.CreatedDate,
			NFF.CreatedSpId,
			NFF.FieldName,
			NFF.FileFieldGuid,
			NFF.FileFieldID,
			NF.Descr AS FileFormatDescr, 
			NF.FileFormatGuid,
			NF.FileFormatID,
			NFFT.Descr AS FileFormatTypeDescr,
			NF.FileFormatTypeID,
			NFO.FileObjectGuid,
			NFO.FileObjectID,
			NFF.FileTranslatorID,
			NFO.InSourceName,
			NFO.InSourceSchema,
			NFF.IsShown,
			NFO.ObjectName,
			NFF.SourceColumn,
			NFO.OutSourceName,
			NFO.OutSourceSchema
	FROM	Cloud.FileObjects AS NFO
			INNER JOIN Cloud.FileFields AS NFF
					ON NFO.FileObjectID = NFF.FileObjectID
			INNER JOIN Cloud.FileFormats AS NF
					ON NFO.FileFormatID = NF.FileFormatID 
			INNER JOIN Cloud.FileFormatTypes AS NFFT
					ON NF.FileFormatTypeID = NFFT.FileFormatTypeID
)	
SELECT	*
FROM	Fields	
--ORDER BY FileFormatID, FileObjectID, FileFieldID 


GO
