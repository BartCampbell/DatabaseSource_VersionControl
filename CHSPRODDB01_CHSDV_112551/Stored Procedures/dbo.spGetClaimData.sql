SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Description:	Gets ClaimDatas details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetClaimData]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ClaimData_BK AS CentauriClaimDataID ,
                lp.Provider_BK AS CentauriProviderID ,
                hm.Member_BK AS CentauriMemberID ,
                s.[DiagnosisCode] ,
                s.[DOS_From] ,
                s.[DOS_Thru] ,
                s.[CPT] ,
                s.[IsICD10] ,
                s.[Claim_ID] ,
                @CCI AS [ClientID] ,
                s.RecordSource ,
                s.[LoadDate]
        FROM    [dbo].[H_ClaimData] h
                INNER JOIN dbo.S_ClaimDataDetail s ON s.H_ClaimData_RK = h.H_ClaimData_RK
				INNER JOIN dbo.L_ClaimDataProvider l ON h.H_ClaimData_RK = l.H_ClaimData_RK
                LEFT OUTER JOIN  (SELECT lpm.H_ProviderMaster_RK,MIN(p.Provider_BK) AS Provider_BK FROM dbo.L_ProviderProviderMaster lpm
								INNER JOIN dbo.H_Provider p ON p.H_Provider_RK = lpm.H_Provider_RK
								GROUP BY lpm.H_ProviderMaster_RK) lp ON lp.H_ProviderMaster_RK = l.H_ProviderMaster_RK
                LEFT OUTER JOIN dbo.L_ClaimDataMember lcm ON lcm.H_ClaimData_RK = h.H_ClaimData_RK
                LEFT OUTER JOIN dbo.H_Member hm ON hm.H_Member_RK = lcm.H_Member_RK
        WHERE   s.LoadDate > @LoadDate;

    END;

--GO
GO
