SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 10/05/2016 Moving RecordEndDate to Link Satellite PJ
-- Description:	Gets User contact details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserContact]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20),
	 @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    
        SELECT  h.User_PK AS CentauriUserID ,
			           
				s. [Phone] AS 	[sch_Tel] ,
				s.[Fax] AS [sch_Fax],
				s.EmailAddress AS EmailAddress,
				s.recordSource AS RecordSource,
				@CCI AS [ClientID] ,
				s.LoadDate AS LoadDate
          FROM    [dbo].[H_User] h
                INNER JOIN [dbo].[L_UserContact] l ON l.H_User_RK = h.H_User_RK 
				INNER JOIN  dbo.LS_UserContact ls ON ls.L_UserContact_RK = l.L_UserContact_RK AND ls.RecordEndDate IS NULL
				INNER JOIN dbo.H_Contact c ON l.H_Contact_RK = c.H_Contact_RK
				INNER JOIN dbo.S_Contact s ON s.H_Contact_RK = c.H_Contact_RK AND s.RecordEndDate IS NULL
			WHERE h.LoadDate> @LoadDate	OR ls.LoadDate>@LoadDate			
				;

    END;



GO
