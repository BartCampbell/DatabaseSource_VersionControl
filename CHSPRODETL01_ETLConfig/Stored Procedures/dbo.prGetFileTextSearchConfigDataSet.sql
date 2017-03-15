SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/6/2015
-- Description:	Get FTP Config dataset
-- =============================================
CREATE PROCEDURE [dbo].[prGetFileTextSearchConfigDataSet]
	-- Add the parameters for the stored procedure here
	@FTPConfigID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Get FTPConfig data
	SELECT
	FileTextSearchID, 
	FTPConfigID, 
	FileTextSearchString,
	FileTextSearchDestPath,
	FileTextSearchArchPath	
	FROM dbo.FileTextSearchConfig
	WHERE IsActive = 1
	AND FTPConfigID=FTPConfigID 


END
GO
