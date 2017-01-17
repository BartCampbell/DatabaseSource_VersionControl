SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets Member Chase details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMemberChase]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Member_BK AS CentauriMemberID ,
                s.[ChaseID] ,
                s.[PID] ,
                s.[REN_Provider_Specialty] ,
                s.[Segment_PK] ,
                s.[ChartPriority] ,
                s.[Ref_Number] ,
                s.recordSource AS RecordSource ,
                @CCI AS [ClientID] ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_Member] h
                INNER JOIN dbo.S_MemberChase s ON s.H_Member_RK = h.H_Member_RK AND s.RecordEndDate IS NULL
        WHERE   s.LoadDate > @LoadDate;

    END;

GO
