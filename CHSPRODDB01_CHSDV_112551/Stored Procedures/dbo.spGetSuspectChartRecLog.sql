SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Description:	Gets Suspects ChartRecLog details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetSuspectChartRecLog]
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
                [Log_Date] ,
                [Log_Info] ,
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_Suspect] h
                INNER JOIN dbo.S_SuspectChartRecLog s ON s.H_Suspect_RK = h.H_Suspect_RK
                INNER JOIN L_SuspectUser a ON a.H_Suspect_RK = h.H_Suspect_RK
                INNER  JOIN dbo.H_User u ON u.H_User_RK = a.H_User_RK
                                            AND s.User_PK = u.ClientUserID
        WHERE   s.LoadDate > @LoadDate;

    END;

--GO
GO
