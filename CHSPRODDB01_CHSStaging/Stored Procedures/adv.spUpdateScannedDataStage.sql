SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Updates the adv.tblScannedDataStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateScannedDataStage]
	-- Add the parameters for the stored procedure here
	@ClientID VARCHAR(32),
	@ClientName VARCHAR(100),
	@RecordsSource VARCHAR(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
		
--SET THE RECORDSOURCE FOR THIS DATAFILE
UPDATE adv.tblScannedDataStage SET RecordSource=@RecordsSource


--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
UPDATE adv.tblScannedDataStage SET CCI=@ClientID
UPDATE  adv.tblScannedDataStage SET Client=@ClientName


--SET LOAD DATE
	DECLARE @LoadDate DATETIME =  GETDATE()
	
	UPDATE adv.tblScannedDataStage SET LoadDate = @LoadDate
	
	
	
	END

GO
