SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sync_getSuspect 2,2,'1/1/2014'
Create PROCEDURE [dbo].[sync_getDocumentType]
	@Project smallint,
	@User int,
	@LastSync smalldatetime
AS
BEGIN
	SELECT [DocumentType_PK],[DocumentType]
	FROM [tblDocumentType]
	WHERE LastUpdated>=@LastSync
END

GO
