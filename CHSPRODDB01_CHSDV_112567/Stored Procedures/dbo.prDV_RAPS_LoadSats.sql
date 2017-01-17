SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	06/10/2016
-- Description:	Loads all the Satellites from the RAPS Response staging tables
-- Usage:			
--		  EXECUTE dbo.prDV_RAPS_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[prDV_RAPS_LoadSats]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

		  --LOAD RAPS AAA
            INSERT  INTO dbo.S_RAPS_Response_AAA
                    ( S_RAPS_Response_AAA_RK ,
                      H_RAPS_Response_RK ,
                      RecordID ,
                      SubmitterID ,
                      FileID ,
                      TransactionDate ,
                      ProdTestIND ,
                      FileDiagType ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT  r.S_RAPS_Response_AAA_RK ,
                            r.H_RAPS_Response_RK ,
                            r.RecordID ,
                            r.SubmitterID ,
                            r.FileID ,
                            r.TransactionDate ,
                            r.ProdTestIND ,
                            r.FileDiagType ,
                            r.HashDiff ,
                            r.LoadDate ,
                            r.RecordSource
                    FROM    CHSStaging.raps.vwRAPS_RESPONSE_AAA r
                            LEFT JOIN dbo.S_RAPS_Response_AAA a ON a.H_RAPS_Response_RK = r.H_RAPS_Response_RK
                                                              AND a.RecordEndDate IS NULL
                                                              AND a.HashDiff = r.HashDiff
                    WHERE   a.S_RAPS_Response_AAA_RK IS NULL; 
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_AAA
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_AAA AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_AAA a
            WHERE   a.RecordEndDate IS NULL;
		  

		  --LOAD RAPS BBB
            INSERT  INTO dbo.S_RAPS_Response_BBB
                    ( S_RAPS_Response_BBB_RK ,
                      H_RAPS_Response_RK ,
                      RecordID ,
                      SeqNo ,
                      PlanNo ,
                      OverpaymentID ,
                      OverpaymentIDErrorCode ,
                      PaymentYear ,
                      PaymentYearErrorCode ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT  r.S_RAPS_Response_BBB_RK ,
                            r.H_RAPS_Response_RK ,
                            r.RecordID ,
                            r.SeqNo ,
                            r.PlanNo ,
                            r.OverpaymentID ,
                            r.OverpaymentIDErrorCode ,
                            r.PaymentYear ,
                            r.PaymentYearErrorCode ,
                            r.HashDiff ,
                            r.LoadDate ,
                            r.RecordSource
                    FROM    CHSStaging.raps.vwRAPS_RESPONSE_BBB r
                            LEFT JOIN dbo.S_RAPS_Response_BBB b ON b.H_RAPS_Response_RK = r.H_RAPS_Response_RK
                                                              AND b.RecordEndDate IS NULL
                                                              AND b.HashDiff = r.HashDiff
                    WHERE   b.S_RAPS_Response_BBB_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_BBB
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_BBB AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_BBB a
            WHERE   a.RecordEndDate IS NULL;


		  --LOAD RAPS CCC
            INSERT  INTO dbo.S_RAPS_Response_CCC
                    ( S_RAPS_Response_CCC_RK ,
                      H_RAPS_Response_RK ,
                      RecordID ,
                      SeqNo ,
                      SeqErrorCode ,
                      PatientControlNo ,
                      HicNo ,
                      HicErrorCode ,
                      PatientDOB ,
                      DOBErrorCode ,
                      ProviderType1 ,
                      FromDate1 ,
                      ThruDate1 ,
                      DeleteIND1 ,
                      DiagnosisCode1 ,
                      DiagClstrErrorA1 ,
                      DiagClstrErrorB1 ,
                      ProviderType2 ,
                      FromDate2 ,
                      ThruDate2 ,
                      DeleteIND2 ,
                      DiagnosisCode2 ,
                      DiagClstrErrorA2 ,
                      DiagClstrErrorB2 ,
                      ProviderType3 ,
                      FromDate3 ,
                      ThruDate3 ,
                      DeleteIND3 ,
                      DiagnosisCode3 ,
                      DiagClstrErrorA3 ,
                      DiagClstrErrorB3 ,
                      ProviderType4 ,
                      FromDate4 ,
                      ThruDate4 ,
                      DeleteIND4 ,
                      DiagnosisCode4 ,
                      DiagClstrErrorA4 ,
                      DiagClstrErrorB4 ,
                      ProviderType5 ,
                      FromDate5 ,
                      ThruDate5 ,
                      DeleteIND5 ,
                      DiagnosisCode5 ,
                      DiagClstrErrorA5 ,
                      DiagClstrErrorB5 ,
                      ProviderType6 ,
                      FromDate6 ,
                      ThruDate6 ,
                      DeleteIND6 ,
                      DiagnosisCode6 ,
                      DiagClstrErrorA6 ,
                      DiagClstrErrorB6 ,
                      ProviderType7 ,
                      FromDate7 ,
                      ThruDate7 ,
                      DeleteIND7 ,
                      DiagnosisCode7 ,
                      DiagClstrErrorA7 ,
                      DiagClstrErrorB7 ,
                      ProviderType8 ,
                      FromDate8 ,
                      ThruDate8 ,
                      DeleteIND8 ,
                      DiagnosisCode8 ,
                      DiagClstrErrorA8 ,
                      DiagClstrErrorB8 ,
                      ProviderType9 ,
                      FromDate9 ,
                      ThruDate9 ,
                      DeleteIND9 ,
                      DiagnosisCode9 ,
                      DiagClstrErrorA9 ,
                      DiagClstrErrorB9 ,
                      ProviderType10 ,
                      FromDate10 ,
                      ThruDate10 ,
                      DeleteIND10 ,
                      DiagnosisCode10 ,
                      DiagClstrErrorA10 ,
                      DiagClstrErrorB10 ,
                      CorrectedHicNo ,
                      RiskAssessmentCode1 ,
                      RiskAssessmentCodeError1 ,
                      RiskAssessmentCode2 ,
                      RiskAssessmentCodeError2 ,
                      RiskAssessmentCode3 ,
                      RiskAssessmentCodeError3 ,
                      RiskAssessmentCode4 ,
                      RiskAssessmentCodeError4 ,
                      RiskAssessmentCode5 ,
                      RiskAssessmentCodeError5 ,
                      RiskAssessmentCode6 ,
                      RiskAssessmentCodeError6 ,
                      RiskAssessmentCode7 ,
                      RiskAssessmentCodeError7 ,
                      RiskAssessmentCode8 ,
                      RiskAssessmentCodeError8 ,
                      RiskAssessmentCode9 ,
                      RiskAssessmentCodeError9 ,
                      RiskAssessmentCode10 ,
                      RiskAssessmentCodeError10 ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT  r.S_RAPS_Response_CCC_RK ,
                            r.H_RAPS_Response_RK ,
                            r.RecordID ,
                            r.SeqNo ,
                            r.SeqErrorCode ,
                            r.PatientControlNo ,
                            r.HicNo ,
                            r.HicErrorCode ,
                            r.PatientDOB ,
                            r.DOBErrorCode ,
                            r.ProviderType1 ,
                            r.FromDate1 ,
                            r.ThruDate1 ,
                            r.DeleteIND1 ,
                            r.DiagnosisCode1 ,
                            r.DiagClstrErrorA1 ,
                            r.DiagClstrErrorB1 ,
                            r.ProviderType2 ,
                            r.FromDate2 ,
                            r.ThruDate2 ,
                            r.DeleteIND2 ,
                            r.DiagnosisCode2 ,
                            r.DiagClstrErrorA2 ,
                            r.DiagClstrErrorB2 ,
                            r.ProviderType3 ,
                            r.FromDate3 ,
                            r.ThruDate3 ,
                            r.DeleteIND3 ,
                            r.DiagnosisCode3 ,
                            r.DiagClstrErrorA3 ,
                            r.DiagClstrErrorB3 ,
                            r.ProviderType4 ,
                            r.FromDate4 ,
                            r.ThruDate4 ,
                            r.DeleteIND4 ,
                            r.DiagnosisCode4 ,
                            r.DiagClstrErrorA4 ,
                            r.DiagClstrErrorB4 ,
                            r.ProviderType5 ,
                            r.FromDate5 ,
                            r.ThruDate5 ,
                            r.DeleteIND5 ,
                            r.DiagnosisCode5 ,
                            r.DiagClstrErrorA5 ,
                            r.DiagClstrErrorB5 ,
                            r.ProviderType6 ,
                            r.FromDate6 ,
                            r.ThruDate6 ,
                            r.DeleteIND6 ,
                            r.DiagnosisCode6 ,
                            r.DiagClstrErrorA6 ,
                            r.DiagClstrErrorB6 ,
                            r.ProviderType7 ,
                            r.FromDate7 ,
                            r.ThruDate7 ,
                            r.DeleteIND7 ,
                            r.DiagnosisCode7 ,
                            r.DiagClstrErrorA7 ,
                            r.DiagClstrErrorB7 ,
                            r.ProviderType8 ,
                            r.FromDate8 ,
                            r.ThruDate8 ,
                            r.DeleteIND8 ,
                            r.DiagnosisCode8 ,
                            r.DiagClstrErrorA8 ,
                            r.DiagClstrErrorB8 ,
                            r.ProviderType9 ,
                            r.FromDate9 ,
                            r.ThruDate9 ,
                            r.DeleteIND9 ,
                            r.DiagnosisCode9 ,
                            r.DiagClstrErrorA9 ,
                            r.DiagClstrErrorB9 ,
                            r.ProviderType10 ,
                            r.FromDate10 ,
                            r.ThruDate10 ,
                            r.DeleteIND10 ,
                            r.DiagnosisCode10 ,
                            r.DiagClstrErrorA10 ,
                            r.DiagClstrErrorB10 ,
                            r.CorrectedHicNo ,
                            r.RiskAssessmentCode1 ,
                            r.RiskAssessmentCodeError1 ,
                            r.RiskAssessmentCode2 ,
                            r.RiskAssessmentCodeError2 ,
                            r.RiskAssessmentCode3 ,
                            r.RiskAssessmentCodeError3 ,
                            r.RiskAssessmentCode4 ,
                            r.RiskAssessmentCodeError4 ,
                            r.RiskAssessmentCode5 ,
                            r.RiskAssessmentCodeError5 ,
                            r.RiskAssessmentCode6 ,
                            r.RiskAssessmentCodeError6 ,
                            r.RiskAssessmentCode7 ,
                            r.RiskAssessmentCodeError7 ,
                            r.RiskAssessmentCode8 ,
                            r.RiskAssessmentCodeError8 ,
                            r.RiskAssessmentCode9 ,
                            r.RiskAssessmentCodeError9 ,
                            r.RiskAssessmentCode10 ,
                            r.RiskAssessmentCodeError10 ,
                            r.HashDiff ,
                            r.LoadDate ,
                            r.RecordSource
                    FROM    CHSStaging.raps.RAPS_RESPONSE_CCC r
                            LEFT JOIN dbo.S_RAPS_Response_CCC c ON c.H_RAPS_Response_RK = r.H_RAPS_Response_RK
                                                              AND c.RecordEndDate IS NULL
                                                              AND c.HashDiff = r.HashDiff
                    WHERE   c.S_RAPS_Response_CCC_RK IS NULL; 
		  
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_CCC
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_CCC AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_CCC a
            WHERE   a.RecordEndDate IS NULL;
		  
		  
		  --LOAD RAPS YYY
            INSERT  INTO dbo.S_RAPS_Response_YYY
                    ( S_RAPS_Response_YYY_RK ,
                      H_RAPS_Response_RK ,
                      RecordID ,
                      SeqNo ,
                      PlanNo ,
                      CCCRecordTotal ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT  r.S_RAPS_Response_YYY_RK ,
                            r.H_RAPS_Response_RK ,
                            r.RecordID ,
                            r.SeqNo ,
                            r.PlanNo ,
                            r.CCCRecordTotal ,
                            r.HashDiff ,
                            r.LoadDate ,
                            r.RecordSource
                    FROM    CHSStaging.raps.vwRAPS_RESPONSE_YYY r
                            LEFT JOIN dbo.S_RAPS_Response_YYY y ON y.H_RAPS_Response_RK = r.H_RAPS_Response_RK
                                                              AND y.HashDiff = r.HashDiff
                                                              AND y.RecordEndDate IS NULL
                    WHERE   y.S_RAPS_Response_YYY_RK IS NULL; 
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_YYY
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_YYY AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_YYY a
            WHERE   a.RecordEndDate IS NULL;
		  
		  
		  --LOAD RAPS ZZZ
            INSERT  INTO dbo.S_RAPS_Response_ZZZ
                    ( S_RAPS_Response_ZZZ_RK ,
                      H_RAPS_Response_RK ,
                      RecordID ,
                      SubmitterID ,
                      FileID ,
                      BBBRecordTotal ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT  r.S_RAPS_Response_ZZZ_RK ,
                            r.H_RAPS_Response_RK ,
                            r.RecordID ,
                            r.SubmitterID ,
                            r.FileID ,
                            r.BBBRecordTotal ,
                            r.HashDiff ,
                            r.LoadDate ,
                            r.RecordSource
                    FROM    CHSStaging.raps.vwRAPS_RESPONSE_ZZZ r
                            LEFT JOIN dbo.S_RAPS_Response_ZZZ z ON z.H_RAPS_Response_RK = r.H_RAPS_Response_RK
                                                              AND z.HashDiff = r.HashDiff
                                                              AND z.RecordEndDate IS NULL
                    WHERE   z.S_RAPS_Response_ZZZ_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_ZZZ
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_ZZZ AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_ZZZ a
            WHERE   a.RecordEndDate IS NULL;

		  
		  --LOAD MemberHICN satellite
            INSERT  INTO dbo.S_MemberHICN
                    ( S_MemberHICN_RK ,
                      LoadDate ,
                      H_Member_RK ,
                      HICNumber ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            r.S_MemberHICN_RK ,
                            r.LoadDate ,
                            r.H_Member_RK ,
                            r.HicNo ,
                            r.S_MemberHICN_HashDiff ,
                            r.RecordSource
                    FROM    CHSStaging.raps.RAPS_RESPONSE_CCC r
                            LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = r.H_Member_RK
                                                            AND s.RecordEndDate IS NULL
                                                            AND r.S_MemberHICN_HashDiff = s.HashDiff
                    WHERE   s.S_MemberHICN_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_MemberHICN
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_MemberHICN AS z
                                      WHERE     z.H_Member_RK = a.H_Member_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_MemberHICN a
            WHERE   a.RecordEndDate IS NULL;



        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
