SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Updates the adv.tblZipCodeStage table with the metadata needed to load to the DataVault 
-- =============================================
create PROCEDURE [adv].[spUpdateZipCodeStage]
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
Update adv.tblZipCodeStage set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update adv.tblZipCodeStage set CCI=@ClientID
Update  adv.tblZipCodeStage set Client=@ClientName



--SET LOAD DATE
	Declare @LoadDate datetime =  GetDate()
	update adv.tblZipCodeStage set LoadDate = @LoadDate
	

END
GO
