SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Insert into table: FileLog and return the resulting FileLogID
Use:
	
	EXEC dbo.spFileConfigGetFilePathInbound
		@ETLPackageID = 2 -- INT

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-09-12	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[zspFileConfigGetFilePathInbound] (
	@ETLPackageID INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT fc.FileConfigID, fc.FilePathInbound, fc.FilePathStage
	FROM
		dbo.FileProcessStep fps
	INNER JOIN 
		dbo.FileProcess fp
		ON fp.FileProcessID = fps.FileProcessID
	INNER JOIN
		dbo.FileConfig fc
		ON fc.FileProcessID = fps.FileProcessID
	WHERE 1=1
		AND fps.IsActive = 1
		AND fp.IsActive = 1
		AND fc.IsActive = 1
		AND fps.ETLPackageID = @ETLPackageID


END -- Procedure


GO
