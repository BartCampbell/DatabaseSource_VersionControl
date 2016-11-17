SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
-- Description:	Load all Link Tables from the tblNoteTextStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Notes_LoadLinks]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** Load L_NoteTextCLIENT
INSERT INTO [dbo].[L_NoteTextClient]
           ([L_NoteTextClient_RK]
           ,[H_NoteText_RK]
           ,[H_Client_RK]
           ,[LoadDate]
           ,[RecordSource]
           ,[RecordEndDate])
	Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)),
		rw.NoteTextHashKey,
		rw.ClientHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblNoteTextStage rw with(nolock)
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)) not in (Select L_NoteTextClient_RK from L_NoteTextClient where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
						))
			),2)),
		rw.NoteTextHashKey,
		rw.ClientHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource
	

	--** Load L_NoteTypeCLIENT
INSERT INTO [dbo].[L_NoteTypeClient]
           ([L_NoteTypeClient_RK]
           ,[H_NoteType_RK]
           ,[H_Client_RK]
           ,[LoadDate]
           ,[RecordSource]
           ,[RecordEndDate])
	Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CTI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)),
		rw.NoteTypeHashKey,
		rw.ClientHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblNoteTypeStage rw with(nolock)
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CTI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)) not in (Select L_NoteTypeClient_RK from L_NoteTypeClient where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CTI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
						))
			),2)),
		rw.NoteTypeHashKey,
		rw.ClientHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource
	

	--** Load L_NoteTextType
INSERT INTO [dbo].[L_NoteTextType]
           ([L_NoteTextType_RK]
           ,[H_NoteText_RK]
           ,[H_NoteType_RK]
           ,[LoadDate]
           ,[RecordSource]
    )
	Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(b.CTI,'')))
			))
			),2)),
		a.NoteTextHashKey,
		b.NoteTypeHashKey,		
	a.LoadDate , 
	 a.RecordSource
	 from CHSStaging.adv.tblNoteTextStage a with(nolock)
	 INNER JOIN CHSStaging.adv.tblNoteTypeStage b with(nolock)
	 ON b.NoteType_PK = a.NoteType_PK AND b.CCI = a.CCI
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(b.CTI,'')))
			))
			),2)) not in (Select L_NoteTextType_RK from L_NoteTextType where RecordEndDate is null)
			AND a.CCI = @CCI
	GROUP BY 
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.CNI,''))),':',
			RTRIM(LTRIM(COALESCE(b.CTI,'')))
			))
			),2)),
		a.NoteTextHashKey,
		b.NoteTypeHashKey,		
	a.LoadDate , 
	 a.RecordSource


END
GO
