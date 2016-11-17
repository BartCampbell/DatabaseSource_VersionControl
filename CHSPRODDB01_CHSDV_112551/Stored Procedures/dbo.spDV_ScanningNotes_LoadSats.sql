SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Data Vault ScanningNotes Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScanningNotes_LoadSats]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_ScanningNotesDEMO LOAD
INSERT INTO [dbo].[S_ScanningNotesDetails]
           ([S_ScanningNotesDetails_RK]
           ,[LoadDate]
           ,[H_ScanningNotes_RK]
           ,[Note_Text]
           ,[IsCNA]
           ,[LastUpdated]
           ,[HashDiff]
           ,[RecordSource]
)
    SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Note_Text],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[IsCNA],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
			))
			),2)),
	 LoadDate, 
	 ScanningNotesHashKey,
	 			RTRIM(LTRIM(rw.[Note_Text])),
			rw.[IsCNA],
			rw.[LastUpdated],
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Note_Text],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[IsCNA],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))	))
			),2)),
	RecordSource
	FROM CHSStaging.adv.tblScanningNotesStage rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(		RTRIM(LTRIM(COALESCE(rw.[Note_Text],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[IsCNA],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_ScanningNotesDetails WHERE 
					H_ScanningNotes_RK = rw.ScanningNotesHashKey and RecordEndDate is null )
	--				AND rw.cci = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Note_Text],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[IsCNA],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
									))
			),2)),
	 LoadDate, 
	 ScanningNotesHashKey,
	 			RTRIM(LTRIM(rw.[Note_Text])),
			rw.[IsCNA],
			rw.[LastUpdated],
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Note_Text],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[IsCNA],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))	))
			),2)),
	RecordSource

	--RECORD END DATE CLEANUP
		UPDATE dbo.S_ScanningNotesDetails set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_ScanningNotesDetails z
			 Where
			  z.H_ScanningNotes_RK = a.H_ScanningNotes_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ScanningNotesDetails a
			Where a.RecordEndDate Is Null 



END



GO
