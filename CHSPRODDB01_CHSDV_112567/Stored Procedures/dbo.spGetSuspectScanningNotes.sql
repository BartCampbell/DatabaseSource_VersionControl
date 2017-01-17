SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets Suspects ScanningNotes details from DV
-- =============================================

CREATE PROCEDURE [dbo].[spGetSuspectScanningNotes]
-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Suspect_BK AS CentauriSuspectID ,
                u.User_PK AS CentauriUserID ,
                n.ScanningNotes_BK AS CentauriScanningNotesID ,
                [dtInsert] ,
                @CCI AS [ClientID] ,
                ls.[RecordSource] ,
                ls.[LoadDate]
        FROM    [dbo].[H_Suspect] h
                INNER JOIN dbo.L_SuspectUserScanningNotes l ON l.H_Suspect_RK = h.H_Suspect_RK 
                INNER JOIN dbo.LS_SuspectScanningNote ls ON ls.L_SuspectUserScanningNotes_RK = l.L_SuspectUserScanningNotes_RK AND ls.RecordEndDate IS NULL
                LEFT OUTER JOIN dbo.H_ScanningNotes n ON n.H_ScanningNotes_RK = l.H_ScanningNotes_RK
                LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = l.H_User_RK
        WHERE   ls.LoadDate > @LoadDate;

    END;

--GO


GO
