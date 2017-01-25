SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CreateFaxLogSubmission]
(
	@FaxLogID int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT TOP 1 1 FROM dbo.FaxLog WHERE FaxLogID = @FaxLogID)
		BEGIN;
			INSERT INTO dbo.FaxLogSubmissions
					(CreatedDate,
					 CreatedUser,
					 FaxLogDocID,
					 FaxLogDocFileID,
					 FaxLogID,
					 FaxLogSubGuid,
					 FileExtension,
					 [FileName],
					 FilePath,
					 IsPrepared,
					 IsReady,
					 PreparedDate,
					 ReadyDate
					)
			SELECT	FL.LastChangedDate AS CreatedDate,
					FL.LastChangedUser AS CreatedUser,
					FL.FaxLogDocID,
					FLDF.FaxLogDocFileID,
					FL.FaxLogID,
					NEWID() AS FaxLogSubGuid,
					FLDF.FileExtension,
					CASE FLDF.SourceType WHEN 'R' THEN REPLACE(CONVERT(varchar(36), NEWID()), '-', '') WHEN 'F' THEN FLDF.SourceName END AS [FileName],
					FLDF.SoucePath,
					CASE FLDF.SourceType WHEN 'F' THEN 1 ELSE 0 END AS IsPrepared,
					CASE FLDF.SourceType WHEN 'F' THEN 1 ELSE 0 END AS IsReady,
					CASE FLDF.SourceType WHEN 'F' THEN GETDATE() ELSE NULL END AS PreparedDate,
					CASE FLDF.SourceType WHEN 'F' THEN GETDATE() ELSE NULL END AS ReadyDate
			FROM	dbo.FaxLog AS FL
					INNER JOIN dbo.FaxLogDocumentFiles AS FLDF
							ON FLDF.FaxLogDocID = FL.FaxLogDocID
			WHERE	(FL.FaxLogID = @FaxLogID)
			ORDER BY FLDF.SortOrder;

			PRINT 'Fax Submission generated.'

			EXEC dbo.TrySendFaxLogSubmission @FaxLogID = @FaxLogID;
		END
	ELSE
		RAISERROR('Fax Submission cannot be generated.  FaxLogID was not specified.', 16, 1);
	
END
GO
