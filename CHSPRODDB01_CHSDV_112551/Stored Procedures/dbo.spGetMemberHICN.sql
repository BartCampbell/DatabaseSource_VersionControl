SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets Member HICN details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMemberHICN]
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
				s.HICNumber AS HICN,
				s.RecordSource AS RecordSource,
				@CCI AS [ClientID] ,
				s.LoadDate AS LoadDate
          FROM    [dbo].[H_Member] h
                INNER JOIN dbo.S_MemberHICN s ON s.H_Member_RK = h.H_Member_RK
			WHERE s.LoadDate> @LoadDate				
				;

    END;
GO
