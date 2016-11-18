SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	06/11/2016
-- Description:	merges the stage to fact for RAPS Response
-- Usage:			
--		  EXECUTE dbo.spRAPSMergeRAPSResponse
-- =============================================
CREATE PROC [dbo].[spRAPSMergeRAPSResponse]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.RAPSResponse AS t
        USING
            ( SELECT    r.FileID ,
                        r.SeqNo ,
                        c.ClientID ,
                        m.MemberID ,
                        r.HicNo ,
                        r.PatientControlNo ,
                        r.ClaimNumber ,
                        r.PatientDOB ,
                        r.DOBErrorCode ,
                        r.HicErrorCode ,
                        r.PlanNo ,
                        r.FromDate ,
                        r.ThruDate ,
                        r.ProviderType ,
                        r.DXCode ,
                        r.ErrorA ,
                        r.ErrorB ,
                        r.RiskAssessmentCode ,
                        r.RiskAssessmentCodeError ,
                        r.ClusterGrouping ,
                        r.TransactionDate ,
                        r.FileDiagType ,
                        r.Accepted ,
				    r.FileName
              FROM      stage.RAPSResponse r
                        INNER JOIN dim.Client c ON c.CentauriClientID = r.CentauriClientID
                        INNER JOIN dim.Member m ON m.CentauriMemberID = r.CentauriMemberID
            ) AS s
        ON t.ResponseFileID = s.FileID
            AND t.SeqNo = s.SeqNo
		  AND t.DXCode = s.DXCode
            AND t.ClientID = s.ClientID
        WHEN MATCHED AND ( ISNULL(t.HicNo, '') <> ISNULL(s.HicNo, '')
                           OR ISNULL(t.PatientControlNo, '') <> ISNULL(s.PatientControlNo, '')
                           OR ISNULL(t.ClaimNumber, '') <> ISNULL(s.ClaimNumber, '')
                           OR ISNULL(t.PatientDOB, '') <> ISNULL(s.PatientDOB, '')
                           OR ISNULL(t.DOBErrorCode, '') <> ISNULL(s.DOBErrorCode, '')
                           OR ISNULL(t.HICErrorCode, '') <> ISNULL(s.HicErrorCode, '')
                           OR ISNULL(t.PlanNo, '') <> ISNULL(s.PlanNo, '')
                           OR ISNULL(t.FromDate, '') <> ISNULL(s.FromDate, '')
                           OR ISNULL(t.ThruDate, '') <> ISNULL(s.ThruDate, '')
                           OR ISNULL(t.ProviderType, '') <> ISNULL(s.ProviderType, '')
                           OR ISNULL(t.MemberID, '') <> ISNULL(s.MemberID, '')
                           OR ISNULL(t.ErrorA, '') <> ISNULL(s.ErrorA, '')
                           OR ISNULL(t.ErrorB, '') <> ISNULL(s.ErrorB, '')
                           OR ISNULL(t.RiskAssessmentCode, '') <> ISNULL(s.RiskAssessmentCode, '')
                           OR ISNULL(t.RiskAssessmentCodeError, '') <> ISNULL(s.RiskAssessmentCodeError, '')
                           OR ISNULL(t.ClusteringGroupID, '') <> ISNULL(s.ClusterGrouping, '')
                           OR ISNULL(t.FileTransactionDate, '') <> ISNULL(s.TransactionDate, '')
                           OR ISNULL(t.FileDiagType, '') <> ISNULL(s.FileDiagType, '')
                           OR ISNULL(t.Accepted, '') <> ISNULL(s.Accepted, '')
					  OR ISNULL(t.FileName,'') <> ISNULL(s.FileName,'')
                         ) THEN
            UPDATE SET
                    t.HicNo = s.HicNo ,
                    t.PatientControlNo = s.PatientControlNo ,
                    t.ClaimNumber = s.ClaimNumber ,
                    t.PatientDOB = s.PatientDOB ,
                    t.DOBErrorCode = s.DOBErrorCode ,
                    t.HICErrorCode = s.HicErrorCode ,
                    t.PlanNo = s.PlanNo ,
                    t.FromDate = s.FromDate ,
                    t.ThruDate = s.ThruDate ,
                    t.ProviderType = s.ProviderType ,
                    t.MemberID = s.MemberID ,
                    t.ErrorA = s.ErrorA ,
                    t.ErrorB = s.ErrorB ,
                    t.RiskAssessmentCode = s.RiskAssessmentCode ,
                    t.RiskAssessmentCodeError = s.RiskAssessmentCodeError ,
                    t.ClusteringGroupID = s.ClusterGrouping ,
                    t.FileTransactionDate = s.TransactionDate ,
                    t.FileDiagType = s.FileDiagType ,
                    t.Accepted = s.Accepted ,
				t.FileName = s.FileName ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ResponseFileID ,
                     SeqNo ,
                     ClientID ,
                     MemberID ,
                     HicNo ,
                     PatientControlNo ,
                     ClaimNumber ,
                     PatientDOB ,
                     DOBErrorCode ,
                     HICErrorCode ,
                     PlanNo ,
                     FromDate ,
                     ThruDate ,
                     ProviderType ,
                     DXCode ,
                     ErrorA ,
                     ErrorB ,
                     RiskAssessmentCode ,
                     RiskAssessmentCodeError ,
                     ClusteringGroupID ,
                     FileTransactionDate ,
                     FileDiagType ,
                     Accepted ,
				 FileName
                   )
            VALUES ( FileID ,
                     SeqNo ,
                     ClientID ,
                     MemberID ,
                     HicNo ,
                     PatientControlNo ,
                     ClaimNumber ,
                     PatientDOB ,
                     DOBErrorCode ,
                     HicErrorCode ,
                     PlanNo ,
                     FromDate ,
                     ThruDate ,
                     ProviderType ,
                     DXCode ,
                     ErrorA ,
                     ErrorB ,
                     RiskAssessmentCode ,
                     RiskAssessmentCodeError ,
                     ClusterGrouping ,
                     TransactionDate ,
                     FileDiagType ,
                     Accepted ,
				 FileName
                   );

    END;     



GO
