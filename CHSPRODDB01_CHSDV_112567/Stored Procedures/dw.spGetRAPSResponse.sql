SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSResponse '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetRAPSResponse]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  cl.Client_BK AS CentauriClientID ,
            m.Member_BK AS CentauriMemberID ,
            a.FileID ,
            c.SeqNo ,
            c.HicNo ,
            RTRIM(c.PatientControlNo) AS 'PatientControlNo' ,
            CONVERT(VARCHAR(50),dbo.ufn_parsefind(c.PatientControlNo, '-', 2)) AS ClaimNumber ,
            c.PatientDOB ,
            c.DOBErrorCode ,
            c.HicErrorCode ,
            b.PlanNo ,
            pvt.FromDate ,
            pvt.ThruDate ,
            pvt.ProviderType ,
            pvt.DXCode ,
            pvt.ErrorA ,
            pvt.ErrorB ,
            pvt.RiskAssessmentCode ,
            pvt.RiskAssessmentCodeError ,
            pvt.ClusterGrouping ,
            a.TransactionDate ,
            a.FileDiagType ,
            CASE WHEN COALESCE(REPLACE(c.DOBErrorCode, '500', ''),
                               REPLACE(c.HicErrorCode, '500', ''),
                               REPLACE(pvt.ErrorA, '500', ''),
                               REPLACE(pvt.ErrorB, '500', ''), '') <> ''
                 THEN 0
                 ELSE 1
            END AS Accepted,
		  c.RecordSource AS FileName
    FROM    dbo.S_RAPS_Response_CCC c
            INNER JOIN dbo.S_RAPS_Response_AAA a ON a.H_RAPS_Response_RK = c.H_RAPS_Response_RK
            INNER JOIN dbo.S_RAPS_Response_BBB b ON b.H_RAPS_Response_RK = a.H_RAPS_Response_RK
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_RAPS_Response_RK = a.H_RAPS_Response_RK
            INNER JOIN dbo.H_Member m ON m.H_Member_RK = l.H_Member_RK
            CROSS JOIN dbo.H_Client cl
            CROSS APPLY ( VALUES
            ( c.FromDate1, c.ThruDate1, c.ProviderType1, c.DiagnosisCode1, c.DiagClstrErrorA1, c.DiagClstrErrorB1, c.RiskAssessmentCode1, c.RiskAssessmentCodeError1, 1)
					,
            ( c.FromDate2, c.ThruDate2, c.ProviderType2, c.DiagnosisCode2, c.DiagClstrErrorA2, c.DiagClstrErrorB2, c.RiskAssessmentCode2, c.RiskAssessmentCodeError2, 2)
					,
            ( c.FromDate3, c.ThruDate3, c.ProviderType3, c.DiagnosisCode3, c.DiagClstrErrorA3, c.DiagClstrErrorB3, c.RiskAssessmentCode3, c.RiskAssessmentCodeError3, 3)
					,
            ( c.FromDate4, c.ThruDate4, c.ProviderType4, c.DiagnosisCode4, c.DiagClstrErrorA4, c.DiagClstrErrorB4, c.RiskAssessmentCode4, c.RiskAssessmentCodeError4, 4)
					,
            ( c.FromDate5, c.ThruDate5, c.ProviderType5, c.DiagnosisCode5, c.DiagClstrErrorA5, c.DiagClstrErrorB5, c.RiskAssessmentCode5, c.RiskAssessmentCodeError5, 5)
					,
            ( c.FromDate6, c.ThruDate6, c.ProviderType6, c.DiagnosisCode6, c.DiagClstrErrorA6, c.DiagClstrErrorB6, c.RiskAssessmentCode6, c.RiskAssessmentCodeError6, 6)
					,
            ( c.FromDate7, c.ThruDate7, c.ProviderType7, c.DiagnosisCode7, c.DiagClstrErrorA7, c.DiagClstrErrorB7, c.RiskAssessmentCode7, c.RiskAssessmentCodeError7, 7)
					,
            ( c.FromDate8, c.ThruDate8, c.ProviderType8, c.DiagnosisCode8, c.DiagClstrErrorA8, c.DiagClstrErrorB8, c.RiskAssessmentCode8, c.RiskAssessmentCodeError8, 8)
					,
            ( c.FromDate9, c.ThruDate9, c.ProviderType9, c.DiagnosisCode9, c.DiagClstrErrorA9, c.DiagClstrErrorB9, c.RiskAssessmentCode9, c.RiskAssessmentCodeError9, 9)
					,
            ( c.FromDate10, c.ThruDate10, c.ProviderType10, c.DiagnosisCode10, c.DiagClstrErrorA10, c.DiagClstrErrorB10, c.RiskAssessmentCode10, c.RiskAssessmentCodeError10, 10) ) pvt ( FromDate, ThruDate, ProviderType, DXCode, ErrorA, ErrorB, RiskAssessmentCode, RiskAssessmentCodeError, ClusterGrouping )
    WHERE   ISNULL(pvt.FromDate, '') <> ''
            AND ISNULL(pvt.ThruDate, '') <> ''
            AND ISNULL(pvt.ProviderType, '') <> ''
            AND ISNULL(pvt.DXCode, '') <> ''
            AND c.LoadDate > @LastLoadTime;



GO
