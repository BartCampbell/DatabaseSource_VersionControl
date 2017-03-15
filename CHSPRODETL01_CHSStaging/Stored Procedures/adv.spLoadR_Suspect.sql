SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
--updated 09/19/2016 for Wellcare  PJ
--updated 09/20/2016 for Viva PJ
-- 09/21/2016 changed to NOT IN (112551) PJ
-- Description:	Load the R_Suspect reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_Suspect] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

		IF @CCI NOT IN( 112551)
		BEGIN
		
    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceSuspect]
                ( [ClientID] ,
                  [ClientSuspectID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[Suspect_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblSuspectWCStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceSuspect] b ON a.Suspect_PK = b.ClientSuspectID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientSuspectID IS NULL;


        UPDATE  CHSStaging.adv.tblSuspectWCStage
        SET     SuspectHashKey = b.SuspectHashKey,CSI = b.CentauriSuspectID
        FROM    CHSStaging.adv.tblSuspectWCStage a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblSuspectWCStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblSuspectWCStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


	

		UPDATE  CHSStaging.adv.[tblSuspectScanningNotesStage]
        SET     UserHashKey = b.UserHashKey ,
                CUI = b.CentauriUserID
        FROM    CHSStaging.adv.[tblSuspectScanningNotesStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON ISNULL(a.User_PK, '') = ISNULL(b.ClientUserID,
                                                              '')
                                                        AND a.CCI = b.ClientID;

																											   
        UPDATE  CHSStaging.adv.[tblSuspectScanningNotesStage]
        SET     ScanningNoteHashKey = b.ScanningNotesHashKey ,
                CNI = b.CentauriScanningNotesID
        FROM    CHSStaging.adv.[tblSuspectScanningNotesStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceScanningNotes b ON a.ScanningNote_PK = b.ClientScanningNotesID
                                                              AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.[tblSuspectScanningNotesStage]
        SET     SuspectHashKey = b.SuspectHashKey ,
                CSI = b.CentauriSuspectID
        FROM    CHSStaging.adv.[tblSuspectScanningNotesStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
		                                                   AND a.CCI = b.ClientID;


		END 
		ELSE
		BEGIN 

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceSuspect]
                ( [ClientID] ,
                  [ClientSuspectID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[Suspect_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblSuspectStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceSuspect] b ON a.Suspect_PK = b.ClientSuspectID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientSuspectID IS NULL;

        UPDATE  CHSStaging.adv.tblSuspectStage
        SET     SuspectHashKey = b.SuspectHashKey
        FROM    CHSStaging.adv.tblSuspectStage a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblSuspectStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblSuspectStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;

		
        UPDATE  CHSStaging.adv.tblSuspectStage
        SET     CSI = b.CentauriSuspectID
        FROM    CHSStaging.adv.tblSuspectStage a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
                                                           AND a.CCI = b.ClientID;

        UPDATE  CHSStaging.adv.[tblSuspectInvoiceInfoStage]
        SET     SuspectHashKey = b.SuspectHashKey ,
                CSI = b.CentauriSuspectID
        FROM    CHSStaging.adv.[tblSuspectInvoiceInfoStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.[tblSuspectInvoiceInfoStage]
        SET     UserHashKey = b.UserHashKey ,
                CUI = b.CentauriUserID
        FROM    CHSStaging.adv.[tblSuspectInvoiceInfoStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON ISNULL(a.User_PK, '') = ISNULL(b.ClientUserID,
                                                              '')
                                                        AND a.CCI = b.ClientID;




        UPDATE  CHSStaging.adv.[tblSuspectInvoiceInfoStage]
        SET     UpdateUserHashKey = b.UserHashKey ,
                CUUI = b.CentauriUserID
        FROM    CHSStaging.adv.[tblSuspectInvoiceInfoStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON ISNULL(a.Update_User_PK,
                                                              '') = ISNULL(b.ClientUserID,
                                                              '')
                                                        AND a.CCI = b.ClientID;

														   
        UPDATE  CHSStaging.adv.[tblSuspectInvoiceInfoStage]
        SET     InvoiceVendorHashKey = b.InvoiceVendorHashKey ,
                CVI = b.CentauriInvoiceVendorID
        FROM    CHSStaging.adv.[tblSuspectInvoiceInfoStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceInvoiceVendor b ON a.InvoiceVendor_PK = b.ClientInvoiceVendorID
                                                              AND a.CCI = b.ClientID;

        UPDATE  CHSStaging.adv.[tblSuspectNoteStage]
        SET     UserHashKey = b.UserHashKey ,
                CUI = b.CentauriUserID
        FROM    CHSStaging.adv.[tblSuspectNoteStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON ISNULL(a.Coded_User_PK,
                                                              '') = ISNULL(b.ClientUserID,
                                                              '')
                                                        AND a.CCI = b.ClientID;
												   
        UPDATE  CHSStaging.adv.[tblSuspectNoteStage]
        SET     NoteTextHashKey = b.NoteTextHashKey ,
                CNI = b.CentauriNoteTextID
        FROM    CHSStaging.adv.[tblSuspectNoteStage] a
                INNER JOIN CHSDV.dbo.R_NoteText b ON a.NoteText_PK = b.ClientNoteTextID
                                                     AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.[tblSuspectNoteStage]
        SET     SuspectHashKey = b.SuspectHashKey ,
                CSI = b.CentauriSuspectID
        FROM    CHSStaging.adv.[tblSuspectNoteStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.[tblSuspectScanningNotesStage]
        SET     UserHashKey = b.UserHashKey ,
                CUI = b.CentauriUserID
        FROM    CHSStaging.adv.[tblSuspectScanningNotesStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON ISNULL(a.User_PK, '') = ISNULL(b.ClientUserID,
                                                              '')
                                                        AND a.CCI = b.ClientID;



														   
        UPDATE  CHSStaging.adv.[tblSuspectScanningNotesStage]
        SET     ScanningNoteHashKey = b.ScanningNotesHashKey ,
                CNI = b.CentauriScanningNotesID
        FROM    CHSStaging.adv.[tblSuspectScanningNotesStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceScanningNotes b ON a.ScanningNote_PK = b.ClientScanningNotesID
                                                              AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.[tblSuspectScanningNotesStage]
        SET     SuspectHashKey = b.SuspectHashKey ,
                CSI = b.CentauriSuspectID
        FROM    CHSStaging.adv.[tblSuspectScanningNotesStage] a
                INNER JOIN CHSDV.dbo.R_AdvanceSuspect b ON a.Suspect_PK = b.ClientSuspectID
                                                           AND a.CCI = b.ClientID;

END 


    END;


GO
