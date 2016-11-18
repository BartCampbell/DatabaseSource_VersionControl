SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance ClaimData 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeClaimData
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeClaimData]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.ClaimData AS t
        USING
            ( SELECT    ps.[CentauriClaimDataID] ,
                        po.[ProviderID] ,
                        MAX(me.[MemberID] ) AS MemberID,
                        ps.[DiagnosisCode] ,
                        ps.[DOS_From] ,
                        ps.[DOS_Thru] ,
                        ps.[CPT] ,
                        ps.[IsICD10] ,
                        ps.[Claim_ID]
			       FROM      [stage].[ClaimData_ADV] ps
                        LEFT OUTER JOIN [dim].[Provider] po ON po.CentauriProviderID = ps.CentauriProviderID
                        LEFT OUTER JOIN [dim].[Member] me ON me.CentauriMemberID = ps.CentauriMemberID
						GROUP BY ps.[CentauriClaimDataID] ,
                        po.[ProviderID] ,
                                              ps.[DiagnosisCode] ,
                        ps.[DOS_From] ,
                        ps.[DOS_Thru] ,
                        ps.[CPT] ,
                        ps.[IsICD10] ,
                        ps.[Claim_ID]
            ) AS s
        ON t.CentauriClaimDataID = s.CentauriClaimDataID
        WHEN MATCHED AND ( ISNULL(t.[ProviderID], 0) <> ISNULL(s.[ProviderID],
                                                              0)
                           OR ISNULL(t.[MemberID], 0) <> ISNULL(s.[MemberID],
                                                              0)
                           OR ISNULL(t.[DiagnosisCode], '') <> ISNULL(s.[DiagnosisCode],
                                                              '')
                           OR ISNULL(t.[DOS_From], '') <> ISNULL(s.[DOS_From],
                                                              '')
                           OR ISNULL(t.[DOS_Thru], '') <> ISNULL(s.[DOS_Thru],
                                                              '')
                           OR ISNULL(t.[CPT], '') <> ISNULL(s.[CPT], '')
                           OR ISNULL(t.[IsICD10], 0) <> ISNULL(s.[IsICD10], 0)
                           OR ISNULL(t.[Claim_ID], '') <> ISNULL(s.[Claim_ID],
                                                              '')
                         ) THEN
            UPDATE SET
                    t.[ProviderID] = s.[ProviderID] ,
                    t.[MemberID] = s.[MemberID] ,
                    t.[DiagnosisCode] = s.[DiagnosisCode] ,
                    t.[DOS_From] = s.[DOS_From] ,
                    t.[DOS_Thru] = s.[DOS_Thru] ,
                    t.[CPT] = s.[CPT] ,
                    t.[IsICD10] = s.[IsICD10] ,
                    t.[Claim_ID] = s.[Claim_ID] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriClaimDataID] ,
                     [ProviderID] ,
                     [MemberID] ,
                     [DiagnosisCode] ,
                     [DOS_From] ,
                     [DOS_Thru] ,
                     [CPT] ,
                     [IsICD10] ,
                     [Claim_ID]

                   )
            VALUES ( [CentauriClaimDataID] ,
                     [ProviderID] ,
                     [MemberID] ,
                     [DiagnosisCode] ,
                     [DOS_From] ,
                     [DOS_Thru] ,
                     [CPT] ,
                     [IsICD10] ,
                     [Claim_ID]
                   );

    END;     

GO
