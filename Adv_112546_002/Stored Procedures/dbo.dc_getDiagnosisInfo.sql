SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-19-2014
-- Description:	RA Coder will use this sp to pull diagnosis code description
-- =============================================
--	dc_getDiagnosisInfo '25000'
CREATE PROCEDURE [dbo].[dc_getDiagnosisInfo] 
	@Code varchar(10),
	@dos date
AS
BEGIN
	SELECT * FROM tblModelCode WITH (NOLOCK) WHERE DiagnosisCode=@Code AND start_date<=@dos and end_date>=@dos
END
GO
