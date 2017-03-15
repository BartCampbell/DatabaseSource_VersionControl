SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
-- Updated 09/19/2016 for Wellcare PJ
--Update 09/21/2016 for Viva PJ
-- 09/21/2016 changed to NOT IN (112551) PJ
-- Description:	Updates the adv.tblSuspectStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateSuspectStage]
	-- Add the parameters for the stored procedure here
    @ClientID VARCHAR(32) ,
    @ClientName VARCHAR(100) ,
    @RecordsSource VARCHAR(200)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        DECLARE @LoadDate DATETIME = GETDATE();
        IF @ClientID NOT IN (112551)
            BEGIN
--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblSuspectWCStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblSuspectDOSStage
                SET     RecordSource = @RecordsSource;
    
	--update adv.tblScannedDataStage set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblSuspectWCStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectWCStage
                SET     Client = @ClientName;
				UPDATE  adv.tblSuspectDOSStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectDOSStage
                SET     Client = @ClientName;
		--update adv.tblScannedDataStage set CCI=@ClientID
		--update adv.tblScannedDataStage set Client=@ClientName

--SET LOAD DATE
	
                UPDATE  adv.tblSuspectWCStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblSuspectDOSStage
                SET     LoadDate = @LoadDate;

            END; 
        ELSE
            BEGIN
		
--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblSuspectStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblSuspectInvoiceInfoStage
                SET     RecordSource = @RecordsSource;
        UPDATE  adv.tblSuspectNoteStage
                SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblSuspectStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectStage
                SET     Client = @ClientName;

                UPDATE  adv.tblSuspectInvoiceInfoStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectInvoiceInfoStage
                SET     Client = @ClientName;

				 UPDATE  adv.tblSuspectNoteStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectNoteStage
                SET     Client = @ClientName;

       
--SET LOAD DATE
	
                UPDATE  adv.tblSuspectStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblSuspectInvoiceInfoStage
                SET     LoadDate = @LoadDate;

                UPDATE  adv.tblSuspectNoteStage
                SET     LoadDate = @LoadDate;
	

	
              
            END;

--SET THE RECORDSOURCE FOR THIS DATAFILE
               
                UPDATE  adv.tblSuspectScanningNotesStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblSuspectChartRecLogStage
                SET     RecordSource = @RecordsSource;
	

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                
               
                UPDATE  adv.tblSuspectScanningNotesStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectScanningNotesStage
                SET     Client = @ClientName;

                UPDATE  adv.tblSuspectChartRecLogStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblSuspectChartRecLogStage
                SET     Client = @ClientName;

		

--SET LOAD DATE
	
	
                UPDATE  adv.tblSuspectScanningNotesStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblSuspectChartRecLogStage
                SET     LoadDate = @LoadDate;
	
	

    END;


GO
