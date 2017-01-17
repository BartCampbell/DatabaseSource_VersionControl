SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Update 10/05/2016 Replacing RecordEndDate with Link Satellite PJ
-- Description:	Gets User Location details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserLocation]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.User_PK AS CentauriUserID ,
                a.[AdvanceLocation_BK] AS [CentauriAdvanceLocationID] ,
                s.Address1 AS [address] ,
                s.ZIP AS [zipcode_pk] ,
                d.[Latitude] ,
                d.[Longitude] ,
                @CCI AS [ClientID] ,
                h.LoadDate AS LoadDate
        FROM    [dbo].[H_User] h
                INNER JOIN dbo.S_UserDetails d ON d.H_User_RK = h.H_User_RK AND d.RecordEndDate IS NULL
                INNER JOIN [dbo].[L_UserLocation] l ON l.H_User_RK = h.H_User_RK 
				INNER JOIN dbo.LS_UserLocation ls ON ls.L_UserLocation_RK = l.L_UserLocation_RK AND ls.RecordEndDate IS NULL
                INNER JOIN dbo.H_Location c ON l.H_Location_RK = c.H_Location_RK
                INNER JOIN dbo.S_Location s ON s.H_Location_RK = c.H_Location_RK AND s.RecordEndDate IS NULL
                LEFT OUTER JOIN (SELECT llua.H_User_RK,llua.H_AdvanceLocation_RK FROM [dbo].[L_UserAdvanceLocation] llua 
				INNER JOIN dbo.LS_UserAdvanceLocation lsua ON lsua.L_UserAdvanceLocation_RK = llua.L_UserAdvanceLocation_RK AND lsua.RecordEndDate IS NULL)	lua 
				ON lua.H_User_RK = h.H_User_RK 
				     LEFT OUTER JOIN dbo.H_AdvanceLocation a ON a.[H_AdvanceLocation_RK] = lua.[H_AdvanceLocation_RK]
             Where h.LoadDate > @LoadDate OR ls.LoadDate>@LoadDate;

    END;

GO
