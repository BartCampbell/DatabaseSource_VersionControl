SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW  [dbo].[vwRAPSResponseErrors]
AS

/******************************************************************
NAME:		vwRAPSResponseErrors
PURPOSE:	Provide a full listing of Error Codes from the RAPs
				history table across the multiple error code
				fields in the CMS response flat file.
				Can run a group by using this view to generate a
				count of errors by error code by file.

CREATED BY:	Chris Shannon
DATE:		12/14/2015

******************************************************************/

SELECT	err.CentauriClientID
		,err.ResponseFileID
		,err.FileDiagType		AS 'DXVersion'
		,err.FileTransactionDate
		,err.ErrorCode
		,ISNULL(ec.ErrorDescription,'') AS 'ErrorDescription'
FROM	(
			SELECT	h1.CentauriClientID
					,h1.ResponseFileID
					,h1.FileDiagType
					,h1.FileTransactionDate
					,h1.DOBErrorCode		AS 'ErrorCode'
			FROM	Submissions.dbo.RAPS_SubmissionHistory h1
			WHERE	ISNULL(h1.DOBErrorCode,'') <> ''
			UNION ALL	
			SELECT	h2.CentauriClientID
					,h2.ResponseFileID
					,h2.FileDiagType
					,h2.FileTransactionDate
					,h2.HICErrorCode		AS 'ErrorCode'
			FROM	Submissions.dbo.RAPS_SubmissionHistory h2
			WHERE	ISNULL(h2.HICErrorCode,'') <> ''
			UNION ALL	
			SELECT	h3.CentauriClientID
					,h3.ResponseFileID
					,h3.FileDiagType
					,h3.FileTransactionDate
					,h3.ErrorA		AS 'ErrorCode'
			FROM	Submissions.dbo.RAPS_SubmissionHistory h3
			WHERE	ISNULL(h3.ErrorA,'') <> ''
			UNION ALL	
			SELECT	h4.CentauriClientID
					,h4.ResponseFileID
					,h4.FileDiagType
					,h4.FileTransactionDate
					,h4.ErrorB		AS 'ErrorCode'
			FROM	Submissions.dbo.RAPS_SubmissionHistory h4
			WHERE	ISNULL(h4.ErrorB,'') <> ''
		) AS err
		LEFT JOIN CHSDW.ref.CMSErrorCode ec
			ON err.ErrorCode = ec.ErrorCode

GO
