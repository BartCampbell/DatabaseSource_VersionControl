SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
-- Description:	Updates the adv.tblNotesStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateNotesStage]
	-- Add the parameters for the stored procedure here
	@ClientID varchar(32),
	@ClientName varchar(100),
	@RecordsSource varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
		
--SET THE RECORDSOURCE FOR THIS DATAFILE
Update adv.tblNoteTextStage set RecordSource=@RecordsSource
UPDATE adv.tblNoteTypeStage set RecordSource=@RecordsSource


--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update adv.tblNoteTextStage set CCI=@ClientID
Update  adv.tblNoteTextStage set Client=@ClientName
Update adv.tblNoteTypeStage set CCI=@ClientID
Update  adv.tblNoteTypeStage set Client=@ClientName


--SET LOAD DATE
	Declare @LoadDate datetime =  GetDate()
	update adv.tblNoteTextStage set LoadDate = @LoadDate
	
	update adv.tblNoteTypeStage set LoadDate = @LoadDate
	
	
	
	END
GO
