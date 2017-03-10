SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PrepareFaxLogSubmissions]
(
	@ReportName nvarchar(256)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Output TABLE 
	(
		FaxLogSubID int NOT NULL, 
		FileExtension nvarchar(16) NOT NULL,
		[FileName] nvarchar(256) NOT NULL,
		FilePath nvarchar(1024) NOT NULL,
		PRIMARY KEY (FaxLogSubID ASC)
	);

    UPDATE	FLS
	SET		IsPrepared = 1,
			PreparedDate = GETDATE()
	OUTPUT	INSERTED.FaxLogSubID, INSERTED.FileExtension, INSERTED.[FileName], INSERTED.FilePath
	INTO	@Output (FaxLogSubID, FileExtension, [FileName], FilePath)
	FROM	dbo.FaxLogSubmissions AS FLS WITH(TABLOCKX)
			INNER JOIN dbo.FaxLogDocumentFiles AS FLDF
					ON FLDF.FaxLogDocFileID = FLS.FaxLogDocFileID
	WHERE	(FLS.IsPrepared = 0) AND
			(FLDF.SourceType = 'R') AND
			(FLDF.SourceName = @ReportName);

	SELECT * FROM @Output;

END
GO
GRANT EXECUTE ON  [dbo].[PrepareFaxLogSubmissions] TO [Reporting]
GO
