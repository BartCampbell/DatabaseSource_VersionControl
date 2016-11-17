SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/31/2016
-- Description:	Gets Members details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMember]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20), @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  CAST(h.Member_BK AS INT)AS CentauriMemberID ,
                NULL AS SSN ,
                s.LastName AS LastName ,
                s.FirstName AS FirstName ,
                NULL AS MiddleName ,
                NULL AS Prefix ,
                NULL AS Suffix ,
                s.Gender AS Gender ,
                s.DOB AS DOB ,
                s.RecordSource AS RecordSource ,
                @CCI AS ClientID ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_Member] h
                LEFT OUTER JOIN [dbo].[S_MemberDemo] s ON s.H_Member_RK = h.H_Member_RK
		WHERE s.LoadDate> @LoadDate				
				;

    END;
GO
