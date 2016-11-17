SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets Member Location details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMemberLocation]
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
                s.Address1 AS Addr1 ,
                s.City AS City ,
                s.[State] AS [State] ,
                s.Zip AS Zip ,
                t.LocationType AS LocationType ,
                h.recordSource AS RecordSource ,
                @CCI AS [ClientID] ,
                h.LoadDate AS LoadDate
        FROM    [dbo].[H_Member] h
                INNER JOIN [dbo].[L_MemberLocation] l ON l.H_Member_RK = h.H_Member_RK
                INNER JOIN dbo.H_Location c ON l.H_Location_RK = c.H_Location_RK 
                INNER JOIN dbo.S_Location s ON s.H_Location_RK = c.H_Location_RK AND s.RecordEndDate IS NULL
                LEFT OUTER JOIN [dbo].[LS_MemberLocationType] t ON t.[L_MemberLocation_RK] = l.[L_MemberLocation_RK] AND t.RecordEndDate IS NULL
        WHERE   ( ISNULL(s.Address1, '') <> ''
                  OR ISNULL(s.City, '') <> ''
                  OR ISNULL(s.[State], '') <> ''
                  OR ISNULL(s.[Zip], '') <> ''
                )
                AND (h.LoadDate > @LoadDate OR l.LoadDate>@LoadDate OR s.LoadDate>@LoadDate OR t.LoadDate>@LoadDate);

    END;

GO
