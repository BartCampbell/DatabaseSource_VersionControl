SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 7/21/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prCopyHistorytotmpExportChases]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--SELECT * FROM tmpExportChases
		INSERT INTO tmpExportChases
		SELECT [Member ID], [Member Individual ID], [REN Provider ID], Member_PK, Suspect_PK, [CHART NAME],ChaseID, InDummy, InNormal, CONVERT(varchar(8), getdate(), 112) FROM [dbo].[tmpExportChartStaging]
END

GO
