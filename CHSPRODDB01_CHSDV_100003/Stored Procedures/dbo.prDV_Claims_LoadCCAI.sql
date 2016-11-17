SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 03/07/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Claims_LoadCCAI] 
	-- Add the parameters for the stored procedure here
	@ClientID INT,
	@ClientName VARCHAR(50),
	@RecordSource VARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	EXECUTE chsstaging.[dbo].[prClaimsStageRawMerge]
	EXECUTE chsstaging.[dbo].[prUpdateClaimsStagingRaw] @ClientID, @ClientName, @RecordSource
	
	EXECUTE [dbo].[prPerformClaimFallout]

	EXECUTE [dbo].[prDV_Claim_LoadHubs]
	EXECUTE [dbo].[prDV_Claim_LoadSats]

END
GO
