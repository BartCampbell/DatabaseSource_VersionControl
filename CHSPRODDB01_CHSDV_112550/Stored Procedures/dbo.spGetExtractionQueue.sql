SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/20/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 10/03/2016 Replace reecord end date and loaddate in link with Link Satellite PJ
-- Description:	Gets ExtractionQueues ChartRecLog details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetExtractionQueue]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ExtractionQueue_BK AS CentauriExtractionQueueID ,
                u.User_PK AS CentauriUserID ,
                s.PDFname ,
                s.ExtractionQueueSource_PK ,
                s.FileSize ,
                s.IsDuplicate ,
                s.UploadDate ,
                s.AssignedDate ,
                s.OfficeFaxOrID ,
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_ExtractionQueue] h
                INNER JOIN dbo.S_ExtractionQueueDetail s ON s.H_ExtractionQueue_RK = h.H_ExtractionQueue_RK
                                                            AND s.RecordEndDate IS NULL
                INNER JOIN L_ExtractionQueueUser a ON a.H_ExtractionQueue_RK = h.H_ExtractionQueue_RK
                INNER JOIN LS_ExtractionQueueUser q ON q.L_ExtractionQueueUser_RK = a.L_ExtractionQueueUser_RK
                                                       AND q.RecordEndDate IS NULL
                INNER  JOIN dbo.H_User u ON u.H_User_RK = a.H_User_RK
        WHERE   s.LoadDate > @LoadDate OR q.LoadDate>@LoadDate;

    END;
GO
