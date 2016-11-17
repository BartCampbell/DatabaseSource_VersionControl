SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 1/14/2016
-- Description:	LOAD HUBS ASSOCIATED WITH THE MMR
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MMR_LoadHubs]
-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO H_MMR
		SELECT 
			DISTINCT 	
			upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(MMR_RK_Hash,''))),':',
				RTRIM(LTRIM(COALESCE(SeqNum,''))),':',
				RTRIM(LTRIM(COALESCE(CCI,''))))
		)),2)),
			MMR_RK_Hash, SeqNum, CCI, LoadDate, RecordSource
		FROM 
			CHSStaging..MMR_Stage rw with(nolock)
		WHERE
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(MMR_RK_Hash,''))),':',
				RTRIM(LTRIM(COALESCE(SeqNum,''))),':',
				RTRIM(LTRIM(COALESCE(CCI,''))))
		)),2))
			 not in (Select H_MMR_RK from H_MMR)	

			 -- truncate table H_MMR
END
GO
