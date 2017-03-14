SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
--Update 09/29/2014 adding EdgeMemberID PJ
--Update adding new columns for Advance updates 02282017 PDJ
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadSuspectWCHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadSuspectWCHash]
    @CCI INT ,
    @Date DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @recordsource VARCHAR(20)
	SET @recordsource =(SELECT TOP 1 RecordSource FROM adv.AdvanceVariables WHERE  AVKey =(SELECT TOP 1 VariableLoadKey FROM adv.AdvanceVariableLoad))
     
        INSERT  INTO adv.StagingHash
                ( HashDiff ,
                  ClientID ,
                  TableName ,
                  CreateDate,
				  RecordSource
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Project_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.Provider_PK, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.Member_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Suspect_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.IsScanned, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.IsCNA, ''))), ':', RTRIM(LTRIM(COALESCE(a.IsCoded, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.IsQA, ''))), ':', RTRIM(LTRIM(COALESCE(a.Scanned_User_PK, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.CNA_User_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Coded_User_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.QA_User_PK, ''))), ':', RTRIM(LTRIM(COALESCE(a.Scanned_Date, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.CNA_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.Coded_Date, ''))), ':', RTRIM(LTRIM(COALESCE(a.QA_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.IsDiagnosisCoded, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.IsNotesCoded, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.LastAccessed_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.LastUpdated, ''))), ':', RTRIM(LTRIM(COALESCE(a.dtCreated, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.IsInvoiced, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.MemberStatus, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ProspectiveFormStatus, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.InvoiceRec_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ChartRec_FaxIn_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ChartRec_MailIn_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ChartRec_InComp_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.IsHighPriority, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.IsInComp_Replied, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ChaseID, ''))), ':', RTRIM(LTRIM(COALESCE(a.ContractCode, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.REN_PROVIDER_SPECIALTY, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ChartPriority, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.ChartRec_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.InvoiceExt_Date, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Channel_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.EDGEMemberID, '')))
																	   --, ':',
                    --                                                   RTRIM(LTRIM(COALESCE(a.LastContacted, ''))), ':',
                    --                                                   RTRIM(LTRIM(COALESCE(a.FollowUp, '')))
																	   
																	   ))), 2)) ,
                        @CCI ,
                        'tblSuspect' ,
                        @Date,
						@recordsource
                FROM    adv.tblSuspectWCStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                                               UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Project_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Provider_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Member_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Suspect_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsScanned, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsCNA, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsCoded, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsQA, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Scanned_User_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.CNA_User_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Coded_User_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.QA_User_PK, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Scanned_Date, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.CNA_Date, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.Coded_Date, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.QA_Date, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsDiagnosisCoded, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsNotesCoded, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.LastAccessed_Date, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.LastUpdated, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.dtCreated, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.IsInvoiced, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.MemberStatus, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.ProspectiveFormStatus, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.InvoiceRec_Date, ''))),
                                                                                                            ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.ChartRec_FaxIn_Date, ''))),
                                                                                                            ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.ChartRec_MailIn_Date, ''))),
                                                                                                            ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.ChartRec_InComp_Date, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.IsHighPriority, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.IsInComp_Replied, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.ChaseID, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.ContractCode, ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.REN_PROVIDER_SPECIALTY, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.ChartPriority, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.ChartRec_Date, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.InvoiceExt_Date, ''))),
                                                                                                            ':', RTRIM(LTRIM(COALESCE(a.[Channel_PK], ''))), ':',
                                                                                                            RTRIM(LTRIM(COALESCE(a.EDGEMemberID, '')))
																											--, ':',
                           --                                            RTRIM(LTRIM(COALESCE(a.LastContacted, ''))), ':',
                           --                                            RTRIM(LTRIM(COALESCE(a.FollowUp, '')))
						   ))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblSuspect'
															 AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;






    END;
GO
