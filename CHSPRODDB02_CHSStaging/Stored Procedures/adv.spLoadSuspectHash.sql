SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblSuspectHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadSuspectHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadSuspectHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        INSERT  INTO adv.tblSuspectHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Provider_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Member_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsScanned,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCNA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCoded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsQA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Scanned_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNA_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.QA_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Scanned_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNA_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.QA_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDiagnosisCoded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsNotesCoded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastAccessed_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtCreated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsInvoiced,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.MemberStatus,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProspectiveFormStatus,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceRec_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ChartRec_FaxIn_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ChartRec_MailIn_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ChartRec_InComp_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsHighPriority,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsInComp_Replied,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblSuspectStage a
                        LEFT OUTER JOIN adv.tblSuspectHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Provider_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Member_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsScanned,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCNA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCoded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsQA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Scanned_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNA_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.QA_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Scanned_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CNA_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.QA_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDiagnosisCoded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsNotesCoded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastAccessed_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtCreated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsInvoiced,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.MemberStatus,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProspectiveFormStatus,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceRec_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ChartRec_FaxIn_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ChartRec_MailIn_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ChartRec_InComp_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsHighPriority,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsInComp_Replied,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;






    END;
GO
