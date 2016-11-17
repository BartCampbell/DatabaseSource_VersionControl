SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 1/14/2016
-- Description:	LOAD HUBS ASSOCIATED WITH CLAIMS
-- Example: [dbo].[prDV_Claim_LoadHubs]
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Claim_LoadHubs]
-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO H_Claim
		SELECT 
			DISTINCT 	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE([Claim Number],''))),':',
				RTRIM(LTRIM(COALESCE([Member ID#],''))),':',
				RTRIM(LTRIM(COALESCE(CCI,''))))
		)),2)), [Claim Number], [Member ID#], CCI, LoadDate, RecordSource
		FROM 
			CHSStaging..Claims_Stage_Raw with(nolock)
		WHERE
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE([Claim Number],''))),':',
				RTRIM(LTRIM(COALESCE([Member ID#],''))),':',
				RTRIM(LTRIM(COALESCE(CCI,''))))
		)),2))
			 not in (Select H_Claim_RK from H_Claim)	
END
GO
