SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 09/29/2016
-- Description:	Get Config for File Missing Configuration
-- =============================================
CREATE PROCEDURE [dbo].[prGetFileMissingConfig]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT ClientName ,
          ClientID ,
          FileDescription ,
          FileNameStringFormatCheck ,
          NotificationEmail ,
          CentauriOwner ,
          ClientContactName ,
          ClientContactNumber, 
		  frq.FreqValue AS [Hours]
 FROM dbo.FTPFileMissingConfig cfg
 INNER JOIN dbo.Frequency frq ON frq.FreqID = cfg.FrequencyID
 WHERE IsActive = 1



END
GO
