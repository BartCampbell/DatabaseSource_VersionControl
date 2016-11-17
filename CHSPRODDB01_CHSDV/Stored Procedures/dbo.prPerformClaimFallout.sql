SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 1/13/2016
-- Description:Returns Claim Numbers without 
-- =============================================
CREATE PROCEDURE [dbo].[prPerformClaimFallout]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert into CHSStaging.dbo.Claims_Member_Fallout
	select [Claim Number],  [Member ID#], [Rendering Provider NPI], SequenceNumber, GetDate() as 'FalloutDate', 'NO MATCHING MEMBER ID' as 'Reason'
	from CHSStaging.dbo.Claims_Stage_Raw WITH(NOLOCK)
	where 
	[Member ID#] not in (Select ClientMemberID from CHSDW_DEV..H_Member) 

	Insert into CHSStaging.dbo.Claims_Provider_Fallout
	select [Claim Number],  [Member ID#], [Rendering Provider NPI], SequenceNumber, GetDate() as 'FalloutDate', 'NO MATCHING PROVIDER NPI' as 'Reason'
	from CHSStaging.dbo.Claims_Stage_Raw WITH(NOLOCK)
	where 
	[Rendering Provider NPI] not in (Select NPI from CHSDW_DEV..S_ProviderDemo) 
	
	--truncate table CHSStaging.dbo.Claims_Member_Fallout
	--truncate table CHSStaging.dbo.Claims_Provider_Fallout
	

END
GO
