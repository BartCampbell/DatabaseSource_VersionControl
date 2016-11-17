SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
-- Description:	Load all Link Tables from the tblCodedDataStage table.  BAsed on CHSDV.dbo.prDV_CodedData_LoadLinks
-- =============================================
CREATE  PROCEDURE [dbo].[spDV_CodedData_LoadLinks]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** Load L_CodedDataSuspect
	Insert into L_CodedDataSuspect
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.SuspectHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblCodedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblSuspectStage b with(nolock) 
	 ON b.Suspect_PK = rw.Suspect_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataSuspect_RK from L_CodedDataSuspect where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.SuspectHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource

--*LOAD L_CodedDataProvider

	Insert into L_CodedDataProvider
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.ProviderHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblCodedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblProviderStage b with(nolock) 
	 ON b.Provider_PK = rw.Provider_PK AND b.CCI = rw.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataProvider_RK from L_CodedDataProvider where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.ProviderHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource

		--** Load L_CodedDataCodedSource
	Insert into L_CodedDataCodedSource
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.CodedSourceHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblCodedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblCodedSourceStage b with(nolock) 
	 ON b.CodedSource_PK = rw.CodedSource_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataCodedSource_RK from L_CodedDataCodedSource where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.CodedSourceHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource

		--** Load L_CodedDataUser
	Insert into L_CodedDataUser
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.UserHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblCodedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblUserStage b with(nolock) 
	 ON b.User_PK = rw.Coded_User_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataUser_RK from L_CodedDataUser where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.UserHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource


		--** Load L_CodedDataScannedData
	Insert into L_CodedDataScannedData
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.ScannedDataHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblCodedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblScannedDataStage b with(nolock) 
	 ON b.ScannedData_PK = rw.ScannedData_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataScannedData_RK from L_CodedDataScannedData where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.ScannedDataHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource


--** Load L_CodedDataNoteText
	Insert into L_CodedDataNoteText
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.NoteTextHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 NULL
	 from CHSStaging.adv.tblCodedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblCodedDataNoteStage a with(nolock) 
	 ON a.CodedData_PK = rw.CodedData_PK AND rw.CCi = a.CCI
	 INNER JOIN CHSStaging.adv.tblNoteTextStage b with(nolock) 
	 ON b.NoteText_PK = a.NoteText_PK AND a.CCi = b.CCI

	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataNoteText_RK from L_CodedDataNoteText where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.NoteTextHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource

		--** Load L_CodedDataUser
	Insert into L_CodedDataQAUser
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)),
		rw.CodedDataHashKey,
		b.UserHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblCodedDataQAStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblUserStage b with(nolock) 
	 ON b.User_PK = rw.QA_User_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
			))
			),2)) not in (Select L_CodedDataUserQA_RK from L_CodedDataQAUser where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CDI,'')))
						))
			),2)),
		rw.CodedDataHashKey,
		b.UserHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource



END
GO
