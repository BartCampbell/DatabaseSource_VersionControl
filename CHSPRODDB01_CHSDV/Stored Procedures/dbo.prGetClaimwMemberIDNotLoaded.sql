SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 1/13/2016
-- Description:Returns Claim Numbers without 
-- =============================================
CREATE PROCEDURE [dbo].[prGetClaimwMemberIDNotLoaded] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select [Claim Number],  [Member ID#]
	from CCAI_Claims_Export..CCAIClaimDetailExtract WITH(NOLOCK)
	where 
	[Member ID#] not in (Select ClientMemberID from CHSDW_DEV..H_Member) 
	and [Member ID#] <> '000000000'

END
GO
