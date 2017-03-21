
/*
This migration script replaces uncommitted changes made to these objects:
L_MemberRAPSResponse
prDV_RAPS_IsFileProcessed
prDV_RAPS_LoadSats
spGetRAPSMemberClient
spGetRAPSMemberHICN
spGetRAPSMember
spGetRAPSResponse
db_owner
INTERNAL\travis.parker

Use this script to make necessary schema and data changes for these objects only. Schema changes to any other objects won't be deployed.

Schema changes and migration scripts are deployed in the order they're committed.
*/

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\travis.parker')
CREATE LOGIN [INTERNAL\travis.parker] FROM WINDOWS
GO
CREATE USER [INTERNAL\travis.parker] FOR LOGIN [INTERNAL\travis.parker]
GO
PRINT N'Altering members of role db_owner'
GO
EXEC sp_addrolemember N'db_owner', N'INTERNAL\travis.parker'
GO
PRINT N'Altering [dbo].[L_MemberRAPSResponse]'
GO
ALTER TABLE [dbo].[L_MemberRAPSResponse] DROP
COLUMN [RecordEndDate]
GO
PRINT N'Creating [dbo].[prDV_RAPS_IsFileProcessed]'
GO



---- =============================================
---- Author:		Travis Parker
---- Create date:	07/06/2016
---- Description:	Returns 1 or 0 as indicator if file has been processed
---- Usage:			
----		  EXECUTE dbo.prDV_RAPS_IsFileProcessed @IsFileProcessed 
---- =============================================

CREATE PROCEDURE [dbo].[prDV_RAPS_IsFileProcessed]
    @IsFileProcessed INT OUTPUT
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY


            SELECT TOP 1
                    @IsFileProcessed = t.FileProcessed
            FROM    ( SELECT    1 AS FileProcessed
                      FROM      CHSStaging.raps.RAPS_RESPONSE_AAA
                      WHERE     RecordSource IN ( SELECT    RecordSource
                                                  FROM      dbo.H_RAPS_Response )
                      UNION
                      SELECT    0 AS FileProcessed
                    ) t
            ORDER BY t.FileProcessed DESC;

        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
PRINT N'Altering [dbo].[prDV_RAPS_LoadSats]'
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	06/10/2016
-- Description:	Loads all the Satellites from the RAPS Response staging tables
-- Usage:			
--		  EXECUTE dbo.prDV_RAPS_LoadSats
-- =============================================

ALTER PROCEDURE [dbo].[prDV_RAPS_LoadSats]
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
                    WHERE   a.S_RAPS_Response_AAA_RK IS NULL
            OPTION  ( MAXDOP 2 ); 
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_AAA
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_AAA AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_AAA a
            WHERE   a.RecordEndDate IS NULL
            OPTION  ( MAXDOP 2 );
		  

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
                    WHERE   b.S_RAPS_Response_BBB_RK IS NULL
            OPTION  ( MAXDOP 2 ); 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_BBB
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_BBB AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_BBB a
            WHERE   a.RecordEndDate IS NULL
            OPTION  ( MAXDOP 2 );


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
                    WHERE   c.S_RAPS_Response_CCC_RK IS NULL
            OPTION  ( MAXDOP 2 ); 
		  
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_CCC
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_CCC AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_CCC a
            WHERE   a.RecordEndDate IS NULL
            OPTION  ( MAXDOP 2 );
		  
		  
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
                    WHERE   y.S_RAPS_Response_YYY_RK IS NULL
            OPTION  ( MAXDOP 2 ); 
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_YYY
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_YYY AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_YYY a
            WHERE   a.RecordEndDate IS NULL
            OPTION  ( MAXDOP 2 );
		  
		  
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
                    WHERE   z.S_RAPS_Response_ZZZ_RK IS NULL
            OPTION  ( MAXDOP 2 ); 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_RAPS_Response_ZZZ
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_RAPS_Response_ZZZ AS z
                                      WHERE     z.H_RAPS_Response_RK = a.H_RAPS_Response_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_RAPS_Response_ZZZ a
            WHERE   a.RecordEndDate IS NULL
            OPTION  ( MAXDOP 2 );

		  
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
                    WHERE   s.S_MemberHICN_RK IS NULL
            OPTION  ( MAXDOP 2 ); 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_MemberHICN
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_MemberHICN AS z
                                      WHERE     z.H_Member_RK = a.H_Member_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_MemberHICN a
            WHERE   a.RecordEndDate IS NULL
            OPTION  ( MAXDOP 2 );



        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
PRINT N'Altering [dw].[spGetRAPSResponse]'
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSResponse '06/10/2016'
---- =============================================
ALTER PROC [dw].[spGetRAPSResponse]
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
            CASE WHEN REPLACE(c.DOBErrorCode, '500', '') <> ''
                  OR REPLACE(c.HICErrorCode, '500', '') <> ''
                  OR REPLACE(pvt.ErrorA, '500', '') <> ''
                  OR REPLACE(pvt.ErrorB, '500', '') <> '' THEN 0
             ELSE 1
        END AS Accepted,
		  c.RecordSource AS FileName ,
		  c.LoadDate
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
PRINT N'Altering [dw].[spGetRAPSMember]'
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response member data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSMember '06/10/2016'
---- =============================================
ALTER PROC [dw].[spGetRAPSMember]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
            s.LastName ,
            s.FirstName ,
            CONVERT(VARCHAR(10),CASE s.Gender WHEN '1' THEN 'M' WHEN '2' THEN 'F' ELSE s.Gender END) AS Gender ,
            CONVERT(VARCHAR(8),s.DOB,112) AS DOB ,
            c.Client_BK AS CentauriClientID ,
            h.RecordSource ,
            ISNULL(s.LoadDate, h.LoadDate) AS LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK
            LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = h.H_Member_RK
            CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND ISNULL(s.LoadDate, h.LoadDate) > @LastLoadTime;


    
GO
PRINT N'Altering [dw].[spGetRAPSMemberHICN]'
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response member HICN data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSMemberHICN '06/10/2016'
---- =============================================
ALTER PROC [dw].[spGetRAPSMemberHICN] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
		  s.HICNumber ,
		  s.RecordSource ,
		  c.Client_BK AS CentauriClientID ,
		  s.LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK
		  INNER JOIN dbo.S_MemberHICN s ON s.H_Member_RK = h.H_Member_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL AND s.LoadDate > @LastLoadTime;

GO
PRINT N'Altering [dw].[spGetRAPSMemberClient]'
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response MemberClient data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSMemberClient '06/10/2016'
---- =============================================
ALTER PROC [dw].[spGetRAPSMemberClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Member_BK AS CentauriMemberID ,
            c.Client_BK AS CentauriClientID ,
            h.ClientMemberID ,
		  h.RecordSource ,
		  h.LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK
            CROSS JOIN dbo.H_Client c
    WHERE   l.LoadDate > @LastLoadTime;

GO

