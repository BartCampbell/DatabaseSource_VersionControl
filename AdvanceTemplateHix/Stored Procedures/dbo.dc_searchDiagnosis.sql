SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-19-2014
-- Description:	RA Coder will use this sp to pull provider for auto complete
-- =============================================
--	dc_searchDiagnosis 'A'
CREATE PROCEDURE [dbo].[dc_searchDiagnosis] 
	@Diagnosis varchar(100),
	@dos date
AS
BEGIN
	SELECT TOP 10 DiagnosisCode+' ('+Code_Description+')' Diagnosis, IsICD10
		FROM tblModelCode WITH (NOLOCK) 
	WHERE (DiagnosisCode Like @Diagnosis+'%'
		OR Code_Description Like '%'+@Diagnosis+'%')
		 AND start_date<=@dos and end_date>=@dos
	ORDER BY DiagnosisCode
END
GO
