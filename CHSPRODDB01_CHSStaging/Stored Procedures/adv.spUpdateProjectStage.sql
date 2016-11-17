SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/19/2016
-- Description:	Updates the adv.tblProjectStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateProjectStage]
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
Update adv.tblProjectStage set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update adv.tblProjectStage set CCI=@ClientID
Update  adv.tblProjectStage set Client=@ClientName



--update  adv.tblProviderMasterStage set ProviderHashKey = upper(convert(char(32), HashBytes('MD5',
--		Upper(RTRIM(LTRIM(COALESCE(CAST([ProviderMaster_PK] AS VARCHAR),'')))))		,2))


----GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
--update  adv.tblProviderMasterStage set ClientHashKey = upper(convert(char(32), HashBytes('MD5',
--		Upper(Concat(
--			RTRIM(LTRIM(COALESCE(CCI,''))),':',
--			RTRIM(LTRIM(COALESCE(Client,'')))
--			))
--			),2))


----GENERATE MD5 HASH for the NETWORKHASHKEY AND UPDATE IT
--	update Provider_Stage_Raw set NetworkHashKey = upper(convert(char(32), HashBytes('MD5',
--			Upper(Concat(
--				RTRIM(LTRIM(COALESCE(NetworkID,''))),':',
--				RTRIM(LTRIM(COALESCE(NetworkName,'')))
--				))
--				),2))

----ADD SEQ NUMBER PER PROVIDERHASHKEY
--	update T 
--	set SeqNum = seq
--	from (select row_number() over (
--					 partition by ProviderHashKey
--					 order by ProviderHashKey
--					)as seq , SeqNum
--					from Provider_Stage_Raw ) T

--SET LOAD DATE
	Declare @LoadDate datetime =  GetDate()
	update adv.tblProjectStage set LoadDate = @LoadDate
	

END
GO
