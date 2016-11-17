SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
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
			           
				s. [ContactNumber] AS 	[sch_Tel] ,
				s.[FaxNumber] AS [sch_Fax],
				s.EmailAddress AS EmailAddress,
				s.recordSource AS RecordSource,
				@CCI AS [ClientID] ,
				s.LoadDate AS LoadDate
          FROM    [dbo].[H_User] h
                INNER JOIN [dbo].[L_UserContact] l ON l.H_User_RK = h.H_User_RK
				INNER JOIN dbo.H_Contact c ON l.H_Contact_RK = c.H_Contact_RK
				INNER JOIN dbo.S_Contact s ON s.H_Contact_RK = c.H_Contact_RK
				AND  h.LoadDate> @LoadDate				
				;

    END;

GO
