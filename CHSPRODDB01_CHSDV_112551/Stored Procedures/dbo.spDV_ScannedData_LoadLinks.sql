SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
-- Description:	Load all Link Tables from the tblScannedDataStage table.  BAsed on CHSDV.dbo.prDV_ScannedData_LoadLinks
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScannedData_LoadLinks]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** Load L_ScannedDataUser
	Insert into L_ScannedDataUser
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
			))
			),2)),
		rw.ScannedDataHashKey,
		b.UserHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblScannedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblUserStage b with(nolock) 
	 ON b.User_PK = rw.User_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
			))
			),2)) not in (Select L_ScannedDataUser_RK from L_ScannedDataUser where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CUI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
						))
			),2)),
		rw.ScannedDataHashKey,
		b.UserHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource

--*LOAD L_ScannedDataSuspect

	Insert into L_ScannedDataSuspect
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
			))
			),2)),
		rw.ScannedDataHashKey,
		b.SuspectHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblScannedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblSuspectStage b with(nolock) 
	 ON b.Suspect_PK = rw.Suspect_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
			))
			),2)) not in (Select L_ScannedDataSuspect_RK from L_ScannedDataSuspect where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CSI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
						))
			),2)),
		rw.ScannedDataHashKey,
		b.SuspectHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource


		
--** Load L_ScannedDataDocumentType
	Insert into L_ScannedDataDocumentType
	
Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CDI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
			))
			),2)),
		rw.ScannedDataHashKey,
		b.DocumentTypeHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblScannedDataStage rw with(nolock)
	 INNER JOIN CHSStaging.adv.tblDocumentTypeStage b with(nolock) 
	 ON b.DocumentType_PK = rw.DocumentType_PK AND rw.CCi = b.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CDI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
			))
			),2)) not in (Select L_ScannedDataDocumentType_RK from L_ScannedDataDocumentType where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(b.CDI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CSI,'')))
						))
			),2)),
		rw.ScannedDataHashKey,
		b.DocumentTypeHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource


END
GO
