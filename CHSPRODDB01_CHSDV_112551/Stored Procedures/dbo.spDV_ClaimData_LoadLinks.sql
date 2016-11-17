SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
-- Description:	Load all Link Tables from the tblClaimDataStage table.  BAsed on CHSDV.dbo.prDV_ClaimData_LoadLinks
-- =============================================
CREATE  PROCEDURE [dbo].[spDV_ClaimData_LoadLinks]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** Load L_ClaimDataMember
	Insert into L_ClaimDataMember
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.ClaimDataHashKey,
		b.MemberHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblClaimDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblMemberStage b with(nolock) 
	 ON b.Member_PK = rw.Member_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_ClaimDataMember_RK from L_ClaimDataMember where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.ClaimDataHashKey,
		b.MemberHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource

--*LOAD L_ClaimDataProvider

	Insert into L_ClaimDataProvider
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.ClaimDataHashKey,
		b.ProviderMasterHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblClaimDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblProviderMasterStage b with(nolock) 
	 ON b.ProviderMaster_PK = rw.ProviderMaster_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_ClaimDataProvider_RK from L_ClaimDataProvider where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.ClaimDataHashKey,
		b.ProviderMasterHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource


END
GO
