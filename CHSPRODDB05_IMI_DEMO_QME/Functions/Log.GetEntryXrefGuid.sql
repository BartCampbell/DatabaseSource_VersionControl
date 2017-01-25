SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/28/2012
-- Description:	Retrieves the first entry cross-reference record matching the object.
--				(FYI: In 90-95% of cases, the source proc will only have one Xref anyway)
-- =============================================
CREATE FUNCTION [Log].[GetEntryXrefGuid]
(
	@ProcSchema nvarchar(128),
	@ProcName nvarchar(128)
)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @Result uniqueidentifier;
	
	SELECT TOP 1
			@Result = LPEX.EntryXrefGuid
	FROM	[Log].ProcessEntryXrefs AS LPEX
			INNER JOIN [Log].SourceObjects AS LSO
					ON LPEX.SrcObjectGuid = LSO.SrcObjectGuid
	WHERE	(LSO.ObjectName = @ProcName) AND
			(LSO.ObjectSchema = @ProcSchema);

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Log].[GetEntryXrefGuid] TO [Processor]
GO
