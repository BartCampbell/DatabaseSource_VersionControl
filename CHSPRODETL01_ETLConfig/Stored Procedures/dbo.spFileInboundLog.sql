SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Start the ELT process logging by creating entries in FileLog and FileProcessStepLog. While the inital process begins by finding
				physical files, the remianing steps are triggered from log enties that are started here.
Use:

	EXEC dbo.spFileInboundLog
		,ETLPackageID = 2
		,@FileConfigID = 1 -- INT
		,@FileNameInbound = 'TestFile.txt' -- VARCHAR(255)


	SELECT TOP 100 * FROM dbo.FileLog
		WHERE 1=1 -- AND FileConfigID = 1
		ORDER BY FileLogDate DESC

	SELECT TOP 100 * FROM dbo.FileProcessStepLog
		WHERE 1=1 -- AND FileConfigID = 1
		ORDER BY FileProcessStepDate DESC

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-09-12	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spFileInboundLog] (
	@ETLPackageID INT
	,@FileConfigID INT
	,@FileNameInbound VARCHAR(255)
	--,@FileLogID INT OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FileLogID INT;
	DECLARE @MyTableVar TABLE(FileLogID INT);

	INSERT INTO dbo.FileLog (
		FileConfigID
		,CentauriClientID
		,FilePathInbound
		,FilePathArchive
		,FileNameInbound
		,FileNameArchive -- Will be same as FileNameInbound for now. Functionality to rename may be added later if desired.
		-- ,FileLogDate -- Defaulted
		)
	OUTPUT INSERTED.FileLogID INTO @MyTableVar(FileLogID)
	SELECT 
		fc.FileConfigID
		,fc.CentauriClientID
		,fc.FilePathInbound
		,fc.FilePathArchive
		,@FileNameInbound
		,@FileNameInbound 
	FROM dbo.FileConfig fc
	WHERE 1=1
		AND fc.FileConfigID = @FileConfigID
	;


	SELECT @FileLogID = FileLogID FROM @MyTableVar;

	-- 

	INSERT INTO dbo.FileProcessStepLog (
		FileLogID
		,FileProcessID
		,FileProcessStepID
		,FileProcessStepDate
		,StatusID
		,RecordCount
		,ErrorDesc
		)
	SELECT
		fl.FileLogID
		,fps.FileProcessID
		,fps.FileProcessStepID
		,GETDATE()
		,1
		,NULL -- Basic file validation / counts can be added later as needed
		,NULL 
	FROM
		dbo.FileLog fl
	INNER JOIN
		dbo.FileConfig fc
		ON fc.FileConfigID = fl.FileConfigID
	INNER JOIN
		dbo.FileProcessStep fps
		ON fps.FileProcessID = fc.FileProcessID
	WHERE 1 = 1
		AND fl.FileLogID = @FileLogID
		AND fps.ETLPackageID = @ETLPackageID

END -- Procedure


GO
