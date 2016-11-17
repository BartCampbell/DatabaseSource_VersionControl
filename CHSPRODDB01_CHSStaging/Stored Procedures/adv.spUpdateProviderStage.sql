SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/19/2016
--Updated 09/16/2016 for Wellcare 
--Update 09/21/2016 for Viva
-- 09/21/2016 changed to NOT IN (112551) PJ
-- Description:	Updates the provider_Stage_raw table with the metadata needed to load to the DataVault based on [dbo].[prUpdateProviderStagingRaw]
-- =============================================
CREATE PROCEDURE [adv].[spUpdateProviderStage]
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

		DECLARE @LoadDate datetime =  GetDate()

		IF @ClientID NOT IN (112551)
		BEGIN
		Update adv.tblProviderOfficeWCStage set RecordSource=@RecordsSource
		
UPDATE adv.tblProviderOfficeWCStage SET CCI=@ClientID
UPDATE  adv.tblProviderOfficeWCStage SET Client=@ClientName
UPDATE adv.tblProviderOfficeWCStage SET LoadDate = @LoadDate
		END
		ELSE
		BEGIN
		UPDATE adv.tblProviderOfficeStage SET RecordSource=@RecordsSource
		
UPDATE adv.tblProviderOfficeStage SET CCI=@ClientID
UPDATE  adv.tblProviderOfficeStage SET Client=@ClientName
UPDATE adv.tblProviderOfficeStage SET LoadDate = @LoadDate

	
	
	UPDATE adv.tblProviderOfficeStatusStage SET LoadDate = @LoadDate
		END
--SET THE RECORDSOURCE FOR THIS DATAFILE
UPDATE adv.tblProviderMasterStage SET RecordSource=@RecordsSource
UPDATE adv.tblProviderStage SET RecordSource=@RecordsSource

UPDATE adv.tblProviderOfficeScheduleStage SET RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
UPDATE adv.tblProviderMasterStage SET CCI=@ClientID
UPDATE  adv.tblProviderMasterStage SET Client=@ClientName

UPDATE adv.tblProviderStage SET CCI=@ClientID
UPDATE  adv.tblProviderStage SET Client=@ClientName


UPDATE adv.tblProviderOfficeScheduleStage SET CCI=@ClientID
UPDATE adv.tblProviderOfficeScheduleStage SET Client=@ClientName


--SET LOAD DATE

	UPDATE adv.tblProviderStage SET LoadDate = @LoadDate
	
	UPDATE adv.tblProviderMasterStage SET LoadDate = @LoadDate
	
	UPDATE adv.tblProviderOfficeScheduleStage SET LoadDate = @LoadDate
	
	
	

END



GO
