SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/14/2015	
-- Description:	Updates the member_Stage_raw table with the metadata needed to load to the DataVault
-- =============================================
CREATE PROCEDURE [dbo].[prUpdateClaimsStagingRaw]
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
Update Claims_Stage_Raw set RecordSource=@RecordsSource

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
Update Claims_Stage_Raw set CCI=@ClientID
Update Claims_Stage_Raw set ClientName=@ClientName

--GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
update Claims_Stage_Raw set ClientHashKey = upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(CCI,''))),':',
			RTRIM(LTRIM(COALESCE(ClientName,'')))
			))
			),2))

--GENERATE MD5 HASH for the MemberHASHKEY AND UPDATE IT
update Claims_Stage_Raw set MemberHashKey = upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(CCI,''))),':',
			RTRIM(LTRIM(COALESCE([Member ID#],'')))
			))
			),2))



		--Update CPI
		Update rw set rw.CPI = ps.CPI, rw.ProviderHashKey = CONVERT(VARCHAR(32), HashBytes('MD5',  CONVERT(VARCHAR(10),ps.CPI)), 2)
		from Claims_Stage_Raw rw
			inner join Provider_Stage ps on
				rw.[Rendering Provider NPI] = ps.NPI
			
		
		--UPDATE CMI
		Update rw set rw.CMI = ps.CMI, rw.MemberHashKey = CONVERT(VARCHAR(32), HashBytes('MD5',  CONVERT(VARCHAR(10),ps.CMI)), 2)
		from Claims_Stage_Raw rw
		 inner join Member_Stage ps on
		  rw.[Member ID#] = ps.ClientMemberID
		  where ps.CCI = @ClientID

		--UPDATE LOAD DATE
		Declare @LoadDate datetime = GetDate()	
		Update Claims_Stage_Raw set LoadDate=@LoadDate

END
GO
