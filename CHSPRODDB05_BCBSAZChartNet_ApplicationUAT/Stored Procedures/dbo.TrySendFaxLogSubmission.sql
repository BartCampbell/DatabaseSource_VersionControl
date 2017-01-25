SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TrySendFaxLogSubmission]
(
	@FaxLogID int
)
--WITH EXECUTE AS OWNER
AS
BEGIN

	SET NOCOUNT ON;

	IF (EXISTS(SELECT TOP 1 1 FROM dbo.FaxLogSubmissions WITH(SERIALIZABLE) WHERE FaxLogID = @FaxLogID AND IsReady = 1) AND
		NOT EXISTS(SELECT TOP 1 1 FROM dbo.FaxLogSubmissions WITH(SERIALIZABLE) WHERE FaxLogID = @FaxLogID AND IsReady = 0))
		BEGIN;
			BEGIN TRANSACTION TSendFaxLogSubmission;

			DECLARE @NewFaxGuid uniqueidentifier;
			DECLARE @NewFaxID int;

			SET @NewFaxGuid = NEWID();

			INSERT INTO FaxAutomation.Faxes
			        (CreatedDate,
			         CreatedUser,
			         FaxGuid,
			         FaxNumber,
					 RecipientName,
			         [Source],
			         SourceRef)
			SELECT	GETDATE() AS CreatedDate,
					DB_NAME() + '.' + MIN(FLS.CreatedUser) AS CreatedUser,
					@NewFaxGuid AS FaxGuid,
					MIN(FL.Fax) AS FaxNumber,
					MIN(LEFT(COALESCE(
										ISNULL(PS.CustomerProviderSiteID + ': ', '') + NULLIF(FL.Contact, ''), 
										ISNULL(PS.CustomerProviderSiteID + ': ', '') + NULLIF(PS.Contact, ''), 
										NULLIF(FL.Contact, ''), 
										NULLIF(PS.Contact, ''), 
										NULLIF(PS.ProviderSiteName, ''), 
										NULLIF(PS.CustomerProviderSiteID, ''), 
										CONVERT(varchar(50), PS.ProviderSiteID)
									), 50)) AS RecipientName,
					DB_NAME() AS [Source],
					CONVERT(nvarchar(256), FLS.FaxLogID)				
			FROM	dbo.FaxLogSubmissions AS FLS 
					INNER JOIN dbo.FaxLog AS FL 
							ON FL.FaxLogID = FLS.FaxLogID
					INNER JOIN dbo.ProviderSite AS PS 
							ON PS.ProviderSiteID = FL.ProviderSiteID
			WHERE	(FLS.FaxLogID = @FaxLogID)
			GROUP BY FLS.FaxLogID
			ORDER BY FLS.FaxLogID;

			SET @NewFaxID = SCOPE_IDENTITY();

			INSERT INTO FaxAutomation.FaxFiles
			        (CanDelete,
					 FaxFileGuid,
			         FaxID,
			         FileExtension,
			         [FileName],
			         FilePath,
			         FileSize,
			         MimeType,
			         SortOrder)
			SELECT	CASE FLDF.SourceType WHEN 'R' THEN 1 ELSE 0 END AS CanDelete,
					FLS.FaxLogSubGuid,
					@NewFaxID AS FaxID,
					FLS.FileExtension,
					FLS.[FileName],
					FLS.FilePath,
					0 AS FileSize,
					FLDF.MimeType,
					FLDF.SortOrder
			FROM	dbo.FaxLogSubmissions AS FLS
					INNER JOIN dbo.FaxLogDocument AS FLD 
							ON FLD.FaxLogDocID = FLS.FaxLogDocID
					INNER JOIN dbo.FaxLogDocumentFiles AS FLDF
							ON FLDF.FaxLogDocFileID = FLS.FaxLogDocFileID
			WHERE	(FLS.FaxLogID = @FaxLogID) AND
					(FLS.IsReady = 1)
			ORDER BY FLS.FaxLogSubID;

			DECLARE @SentStatus int;
			SELECT @SentStatus = MIN(FaxLogStatusID) FROM dbo.FaxLogStatus WITH(NOLOCK) WHERE IsSent = 1 AND FaxProc IS NULL;

			UPDATE dbo.FaxLog SET FaxLogStatusID = @SentStatus WHERE FaxLogID = @FaxLogID;

			COMMIT TRANSACTION TSendFaxLogSubmission;
		END;
	ELSE
		PRINT 'Fax Submission cannot be sent.  One or more files are not ready.';

END
GO
