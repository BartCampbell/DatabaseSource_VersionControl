SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/20/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets SuspectDOS details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetSuspectDOS]
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
                s.SuspectDOS_PK ,
                s.DOS_From ,
                s.DOS_To ,
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_Suspect] h
                INNER JOIN dbo.S_SuspectDOS s ON s.H_Suspect_RK = h.H_Suspect_RK AND s.RecordEndDate IS NULL
        WHERE   s.LoadDate > @LoadDate;

    END;

--GO


GO
