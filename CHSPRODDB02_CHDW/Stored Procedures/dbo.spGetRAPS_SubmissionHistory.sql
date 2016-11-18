SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response data for loading into the Submission HX
---- Usage:			
----		  EXECUTE dbo.spGetRAPS_SubmissionHistory '06/11/2016'
---- =============================================
CREATE PROC [dbo].[spGetRAPS_SubmissionHistory]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  r.RAPSResponseID ,
            r.ResponseFileID ,
            r.SeqNo ,
            c.CentauriClientID ,
            m.CentauriMemberID ,
            r.HicNo ,
            r.PatientControlNo ,
            r.ClaimNumber ,
            r.PatientDOB ,
            r.DOBErrorCode ,
            r.HICErrorCode ,
            r.PlanNo ,
            r.FromDate ,
            r.ThruDate ,
            r.ProviderType ,
            r.DXCode ,
            r.ErrorA ,
            r.ErrorB ,
            r.RiskAssessmentCode ,
            r.RiskAssessmentCodeError ,
            r.ClusteringGroupID ,
            r.FileTransactionDate ,
            r.FileDiagType ,
            r.Accepted ,
		  r.FileName ,
		  r.CreateDate ,
		  r.LastUpdate
    FROM    CHSDW.fact.RAPSResponse r
            INNER JOIN dim.Client c ON c.ClientID = r.ClientID
            INNER JOIN dim.Member m ON m.MemberID = r.MemberID
    WHERE   r.LastUpdate > @LastLoadTime;



GO
