SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Load the R_ScanningNotes reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_ScanningNotes] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceScanningNotes]
                ( [ClientID] ,
                  [ClientScanningNotesID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[ScanningNote_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblScanningNotesStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceScanningNotes] b ON a.ScanningNote_PK = b.ClientScanningNotesID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                WHERE   a.CCI = @CCI                         AND 				b.ClientScanningNotesID IS NULL;

        UPDATE  CHSStaging.adv.tblScanningNotesStage
        SET     ScanningNotesHashKey = b.ScanningNotesHashKey
        FROM    CHSStaging.adv.tblScanningNotesStage a
                INNER JOIN CHSDV.dbo.R_AdvanceScanningNotes b ON a.ScanningNote_PK = b.ClientScanningNotesID AND b.RecordSource = a.RecordSource
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblScanningNotesStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblScanningNotesStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;





        UPDATE  CHSStaging.adv.tblScanningNotesStage
        SET     CNI = b.CentauriScanningNotesID
        FROM    CHSStaging.adv.tblScanningNotesStage a
                INNER JOIN CHSDV.dbo.R_AdvanceScanningNotes b ON a.ScanningNote_PK = b.ClientScanningNotesID AND b.RecordSource = a.RecordSource
                                                           AND a.CCI = b.ClientID;


										   


    END;
GO
