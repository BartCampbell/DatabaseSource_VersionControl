SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets Member contact details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMemberContact]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20),
	 @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Member_BK AS CentauriMemberID ,
				s.ContactNumber AS Phone,
				s.CellNumber AS Cell,
				s.EmailAddress AS EmailAddress,
				t.ContactType AS ContactType,
				h.recordSource AS RecordSource,
				@CCI AS [ClientID] ,
				h.LoadDate AS LoadDate
          FROM    [dbo].[H_Member] h
                INNER JOIN [dbo].[L_MemberContact] l ON l.H_Member_RK = h.H_Member_RK
				INNER JOIN dbo.H_Contact c ON l.H_Contact_RK = c.H_Contact_RK
				INNER JOIN dbo.S_Contact s ON s.H_Contact_RK = c.H_Contact_RK
				LEFT OUTER JOIN [dbo].[LS_MemberContactType] t ON t.[L_MemberContact_RK] = L.[L_MemberContact_RK]
				WHERE (ISNULL(s.ContactNumber ,'') <>''  OR ISNULL(s.CellNumber,'')<>'' OR ISNULL(s.EmailAddress,'')<>'')
				AND  h.LoadDate> @LoadDate				
				;

    END;

GO
