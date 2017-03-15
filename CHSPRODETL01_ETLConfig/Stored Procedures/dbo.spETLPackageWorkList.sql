SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Given a ETLPackageID, return a list of all FileLogID's with work for the given package. 
Use:
	
	SELECT * FROM dbo.FileProcessStep WHERE FileProcessID = 100000; SELECT * FROM dbo.FileProcessStepLog WHERE FileProcessID = 100000;

	EXEC dbo.spETLPackageWorkList
		@ETLPackageID = 100000
	;


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-09-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spETLPackageWorkList] (
	@ETLPackageID INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		fl.CentauriClientID
		,fl.FileLogID
		,fps.FileProcessStepID
		,fl.FilePathInbound		
		,fl.FileNameInbound
		,fc.FilePathStage
		,fl.FilePathArchive
		,fl.FileNameArchive
		,fps.ETLPackageChild1
	FROM
		dbo.FileProcessStep fps
	INNER JOIN 
		dbo.FileProcess fp
		ON fp.FileProcessID = fps.FileProcessID
	INNER JOIN
		dbo.FileConfig fc
		ON fc.FileProcessID = fps.FileProcessID
	INNER JOIN 
		dbo.FileLog fl
		ON fl.FileConfigID = fc.FileConfigID
	-- Only where the prev step for this file was logged as Complete
	INNER JOIN
		dbo.FileProcessStepLog prev_fpsl
		ON prev_fpsl.FileProcessID = fps.FileProcessID
			AND prev_fpsl.FileLogID = fl.FileLogID
			AND prev_fpsl.StatusID = 1
			AND prev_fpsl.FileProcessStepID = (
					SELECT MAX(zfps.FileProcessStepID)
					FROM dbo.FileProcessStep xfps
					INNER JOIN dbo.FileProcessStep zfps ON zfps.FileProcessID = xfps.FileProcessID
					WHERE 1=1
						AND xfps.ETLPackageID = @ETLPackageID
						AND xfps.FileProcessStepOrder > zfps.FileProcessStepOrder
					)
	-- And where the current step in question has not already been completed for the file.
	LEFT OUTER JOIN
		dbo.FileProcessStepLog cur_fpsl
		ON cur_fpsl.FileProcessStepID = fps.FileProcessStepID
			AND cur_fpsl.FileLogID = fl.FileLogID
	WHERE 1=1
		AND fps.IsActive = 1
		AND fp.IsActive = 1
		AND fc.IsActive = 1
		AND fps.ETLPackageID = @ETLPackageID
		AND cur_fpsl.FileLogID IS NULL  -- This can be adjusted in the future to allow for retries rather than delete existing records

END -- Procedure


GO
