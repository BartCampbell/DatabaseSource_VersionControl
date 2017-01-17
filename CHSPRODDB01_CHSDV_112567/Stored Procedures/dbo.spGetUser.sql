SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets User details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetUser]
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
                s.[Username] ,
                s.[sch_Name] ,
                s.[FirstName] ,
                s.[LastName] ,
                s.[ismale] ,
                @CCI AS ClientID ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_User] h
                INNER JOIN [dbo].[S_UserDemo] s ON s.H_User_RK = h.H_User_RK AND s.RecordEndDate IS NULL
        WHERE   s.LoadDate > @LoadDate;

    END;



GO
