SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Description:	Gets User client details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserClient]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20),
	 @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.User_PK AS CentauriUserID ,
				c.Client_BK AS CentauriClientID,
               h.ClientUserID AS ClientUserID,
                 h.LoadDate AS LoadDate
        FROM    [dbo].[H_User] h
                INNER JOIN [dbo].[L_UserClient] l ON l.H_User_RK = h.H_User_RK
				INNER JOIN dbo.H_Client c ON l.H_Client_RK = c.H_Client_RK
		WHERE h.LoadDate> @LoadDate				
				;

    END;
GO
