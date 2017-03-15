SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Insert into table: FileLog and return the resulting FileLogID
Use:

	EXEC dbo.spFileProcessStepLog
		@FileLogID = 1000007 -- INT
		,@FileProcessStepID = 100002

	SELECT TOP 100 * FROM dbo.FileProcessStepLog
	WHERE 1=1 
		AND FileLogID = 1000007


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-09-12	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spFileProcessStepLog] (
	@FileLogID INT
	,@FileProcessStepID INT
	,@StatusID INT = 1
	,@RecordCount INT = NULL
	,@ErrorDesc VARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

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
		@FileLogID
		,(SELECT FileProcessID FROM dbo.FileProcessStep WHERE FileProcessStepID = @FileProcessStepID)
		,@FileProcessStepID
		,GETDATE()
		,@StatusID
		,@RecordCount
		,@ErrorDesc
	FROM
		dbo.FileLog fl
	WHERE
		fl.FileLogID = @FileLogID
	;

END -- Procedure


GO
