SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Updates the adv.tblCodedDataStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateCodedDataStage]
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
		
--SET THE RECORDSOURCE FOR THIS DATAFILE
        UPDATE  adv.tblCodedDataStage
        SET     RecordSource = @RecordsSource;
        UPDATE  [adv].[tblCodedDataNoteStage]
        SET     RecordSource = @RecordsSource;
        UPDATE  [adv].[tblCodedDataQAStage]
        SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
        UPDATE  adv.tblCodedDataStage
        SET     CCI = @ClientID;
        UPDATE  adv.tblCodedDataStage
        SET     Client = @ClientName;

        UPDATE  [adv].[tblCodedDataNoteStage]
        SET     CCI = @ClientID;
        UPDATE  [adv].[tblCodedDataNoteStage]
        SET     Client = @ClientName;

        UPDATE  [adv].[tblCodedDataQAStage]
        SET     CCI = @ClientID;
        UPDATE  [adv].[tblCodedDataQAStage]
        SET     Client = @ClientName;
--SET LOAD DATE
        DECLARE @LoadDate DATETIME = GETDATE();
	
        UPDATE  adv.tblCodedDataStage
        SET     LoadDate = @LoadDate;
        UPDATE  [adv].[tblCodedDataNoteStage]
        SET     LoadDate = @LoadDate;
        UPDATE  [adv].[tblCodedDataQAStage]
        SET     LoadDate = @LoadDate;
	
    END;

GO
