SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/14/2015	
-- Description:	Updates the provider_Stage_raw table with the metadata needed to load to the DataVault
-- =============================================
CREATE PROCEDURE [dbo].[prUpdateProviderStagingRaw]
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
	
--FORMAT FIRST AND LAST NAMES AND DIVIDE THEM INTO 2 FIELDS
		update Provider_Stage_Raw set ProviderFirstName = SUBSTRING(ProviderLastName, CHARINDEX(',', ProviderLastName)+2, LEN(ProviderLastName))
		where CHARINDEX(',',ProviderLastName)>0
		update Provider_Stage_Raw set ProviderLastName = SUBSTRING(ProviderLastName, 0, CHARINDEX(',', ProviderLastName))
		where CHARINDEX(',',ProviderLastName)>0
	
--SET THE RECORDSOURCE FOR THIS DATAFILE
Update Provider_Stage_Raw set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update Provider_Stage_Raw set CCI=@ClientID
Update Provider_Stage_Raw set ClientName=@ClientName

--GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
update Provider_Stage_Raw set ClientHashKey = upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(CCI,''))),':',
			RTRIM(LTRIM(COALESCE(ClientName,'')))
			))
			),2))

--GENERATE MD5 HASH for the NETWORKHASHKEY AND UPDATE IT
	update Provider_Stage_Raw set NetworkHashKey = upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(NetworkID,''))),':',
				RTRIM(LTRIM(COALESCE(NetworkName,'')))
				))
				),2))

--ADD SEQ NUMBER PER PROVIDERHASHKEY
	update T 
	set SeqNum = seq
	from (select row_number() over (
					 partition by ProviderHashKey
					 order by ProviderHashKey
					)as seq , SeqNum
					from Provider_Stage_Raw ) T

--SET LOAD DATE
	Declare @LoadDate datetime =  GetDate()
	update Provider_Stage_Raw set LoadDate = @LoadDate

	

END
GO
