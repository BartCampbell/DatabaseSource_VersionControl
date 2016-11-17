SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Description:	Gets User Password details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserPassword]
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
             s.[Password] ,
	s.[dtPassword] ,
                @CCI AS ClientID ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_User] h
                INNER JOIN [dbo].[S_UserPassword] s ON s.H_User_RK = h.H_User_RK
        WHERE   s.LoadDate > @LoadDate;

    END;

GO
