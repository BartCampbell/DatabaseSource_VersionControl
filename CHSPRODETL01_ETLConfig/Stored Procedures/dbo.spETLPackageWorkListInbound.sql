SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Given a ETLPackageID, return a list of all FileLogID's with work for the given package. 
				THis is a special version for the first/inbound steps. For these, there are no existin logs.
Use:
	
	SELECT * FROM dbo.FileProcessStep WHERE FileProcessID = 100000; SELECT * FROM dbo.FileProcessStepLog WHERE FileProcessID = 100000;

	EXEC dbo.spETLPackageWorkListInbound
		@ETLPackageID = 2
	;


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-09-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spETLPackageWorkListInbound] (
	@ETLPackageID INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		fc.FileConfigID
		,fc.FilePathInbound		
		,fc.FilePathStage
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
