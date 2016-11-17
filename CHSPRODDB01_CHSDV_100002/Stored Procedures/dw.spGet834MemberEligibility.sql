SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/20/2016
---- Description:	Gets the latest RAPS Response MemberClient data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834MemberEligibility '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834MemberEligibility]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Member_BK AS CentauriMemberID ,
		  l.ProviderID ,
		  l.NetworkID ,
            l.Payor ,
		  CONVERT(VARCHAR(10),l.EffectiveStartDate,112) AS EffectiveStartDate,
		  CONVERT(VARCHAR(10),l.EffectiveEndDate,112) AS EffectiveEndDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.S_MemberEligibility l ON l.H_Member_RK = h.H_Member_RK
    WHERE   l.RecordEndDate IS NULL
            AND l.LoadDate > @LastLoadTime;


GO
