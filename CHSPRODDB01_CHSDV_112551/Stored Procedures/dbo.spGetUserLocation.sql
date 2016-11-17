SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
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
                INNER JOIN dbo.S_UserDetails d ON d.H_User_RK = h.H_User_RK
                INNER JOIN [dbo].[L_UserLocation] l ON l.H_User_RK = h.H_User_RK
                INNER JOIN dbo.H_Location c ON l.H_Location_RK = c.H_Location_RK
                INNER JOIN dbo.S_Location s ON s.H_Location_RK = c.H_Location_RK
                LEFT OUTER JOIN [dbo].[L_UserAdvanceLocation] lua ON lua.H_User_RK = h.H_User_RK
                LEFT OUTER JOIN dbo.H_AdvanceLocation a ON a.[H_AdvanceLocation_RK] = lua.[H_AdvanceLocation_RK]
                                                           AND h.LoadDate > @LoadDate;

    END;
GO
