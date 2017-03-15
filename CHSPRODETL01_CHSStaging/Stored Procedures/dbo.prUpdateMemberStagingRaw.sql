SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/14/2015	
-- Description:	Updates the member_Stage_raw table with the metadata needed to load to the DataVault
-- Modified:  TP - 04/27/2016 - Changed MemberHashKey to CCI only, removed ClientMemberID 
-- =============================================
CREATE PROCEDURE [dbo].[prUpdateMemberStagingRaw]
	-- Add the parameters for the stored procedure here
	@ClientID varchar(32),
	@ClientName varchar(100),
	@RecordsSource varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--SET THE RECORDSOURCE FOR THIS DATAFILE
Update Member_Stage_Raw set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update Member_Stage_Raw set CCI=@ClientID
Update Member_Stage_Raw set ClientName=@ClientName

--GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
update Member_Stage_Raw set ClientHashKey = upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(CCI,''))),':',
			RTRIM(LTRIM(COALESCE(ClientName,'')))
			))
			),2))

--GENERATE MD5 HASH for the MemberHASHKEY AND UPDATE IT
update Member_Stage_Raw set MemberHashKey = upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(CCI,''))))),2))


update Member_Stage_Raw set TerminationDate=null where TerminationDate='NULL'
UPDATE Member_Stage_Raw set Address2=null where Address2='NULL'

-- SET LOAD DATE
	Declare @LoadDate datetime =  GetDate()
	update Member_Stage_Raw set LoadDate = @LoadDate

	select * from Member_Stage

END
GO
