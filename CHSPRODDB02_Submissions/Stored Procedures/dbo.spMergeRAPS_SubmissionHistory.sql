SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	06/11/2016
-- Description:	merges the stage to fact for RAPS Submission History
-- Usage:			
--		  EXECUTE dbo.spMergeRAPS_SubmissionHistory
-- =============================================
CREATE PROC [dbo].[spMergeRAPS_SubmissionHistory]
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dbo.RAPS_SubmissionHistory AS t
        USING
            ( SELECT RAPSResponseID ,
                     ResponseFileID ,
                     SeqNo ,
                     CentauriClientID ,
                     CentauriMemberID ,
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
                     FileName ,
                     CreateDate ,
                     LastUpdate 
			 FROM stage.RAPS_SubmissionHistory
            ) AS s
        ON t.RAPSResponseID = s.RAPSResponseID
        WHEN MATCHED THEN
            UPDATE SET
                    t.ResponseFileID = s.ResponseFileID ,
                    t.SeqNo = s.SeqNo ,
                    t.CentauriClientID = s.CentauriClientID ,
                    t.CentauriMemberID = s.CentauriMemberID ,
                    t.HicNo = s.HicNo ,
                    t.PatientControlNo = s.PatientControlNo ,
                    t.ClaimNumber = s.ClaimNumber ,
                    t.PatientDOB = s.PatientDOB ,
                    t.DOBErrorCode = s.DOBErrorCode ,
                    t.HICErrorCode = s.HICErrorCode ,
                    t.PlanNo = s.PlanNo ,
                    t.FromDate = s.FromDate ,
                    t.ThruDate = s.ThruDate ,
                    t.ProviderType = s.ProviderType ,
                    t.DXCode = s.DXCode ,
                    t.ErrorA = s.ErrorA ,
                    t.ErrorB = s.ErrorB ,
                    t.RiskAssessmentCode = s.RiskAssessmentCode ,
                    t.RiskAssessmentCodeError = s.RiskAssessmentCodeError ,
				t.ClusteringGroupID = s.ClusteringGroupID ,
				t.FileTransactionDate = s.FileTransactionDate,
				t.FileDiagType = s.FileDiagType,
				t.Accepted = s.Accepted,
				t.FileName = s.FileName,
				t.CreateDate = s.CreateDate,
				t.LastUpdate = s.LastUpdate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( RAPSResponseID ,
				 ResponseFileID ,
                     SeqNo ,
                     CentauriClientID ,
                     CentauriMemberID ,
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
				 FileName ,
				 CreateDate ,
				 LastUpdate
                   )
            VALUES ( s.RAPSResponseID ,
		           ResponseFileID ,
                     SeqNo ,
                     CentauriClientID ,
                     CentauriMemberID ,
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
                     ClusteringGroupID ,
                     s.FileTransactionDate ,
                     FileDiagType ,
                     Accepted ,
				 FileName,
				 CreateDate ,
				 LastUpdate
                   );

    END;     




GO
