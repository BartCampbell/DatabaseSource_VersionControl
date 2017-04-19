SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	prInitializeInstanceFile
Purpose:	To initialize a new file instance so we can process inbound data

Change Log:
2007-11-06	David Buckingham- Create
2016-12-20	Michael Vlk		- Add DateReceived to INSERT

Test Script:	DECLARE @iLoadInstanceFileID int
		EXECUTE dbo.prInitializeInstanceFile 1, 'C:\Temp\SomeDataFile.dat', 'MyMachine', @iLoadInstanceFileID OUTPUT
		SELECT * FROM dbo.ClientProcessInstanceFile WHERE LoadInstanceFileID = @iLoadInstanceFileID
ToDo:		
*************************************************************************************/
CREATE PROCEDURE [dbo].[zzzprInitializeInstanceFile]
	@iLoadInstanceID	int,	-- ClientProcessInstanceFile.LoadInstanceID
	@vcFilePath	varchar( 510 ),	-- ClientProcessInstanceFile.InboundFileName/InboundFilePath
	@vcSystem	varchar( 255 ),	-- ClientProcessInstanceFile.InboundMachine
	@iLoadInstanceFileID	int	OUTPUT	-- ClientProcessInstanceFile.LoadInstanceFileID
AS

BEGIN TRY
	/*************************************************************************************
		1.	Declare/initialize variables
	*************************************************************************************/
	DECLARE @vcInboundFilePath varchar( 255 )
	DECLARE @vcInboundFileName varchar( 255 )
	
	SELECT 
		@vcInboundFilePath = LEFT( @vcFilePath, LEN( @vcFilePath ) - CHARINDEX( '\', REVERSE( @vcFilePath ) ) + 1 ),
		@vcInboundFileName = SUBSTRING( @vcFilePath, LEN( @vcFilePath ) - CHARINDEX( '\', REVERSE( @vcFilePath ) ) + 2, 510 )
	
	/*************************************************************************************
		2.	Insert data into ClientProcessInstance
	*************************************************************************************/
	SET NOCOUNT ON

	INSERT INTO dbo.ClientProcessInstanceFile( LoadInstanceID, InboundFileName, InboundFilePath, InboundMachine,DateReceived ) 
	VALUES( @iLoadInstanceID, @vcInboundFileName, @vcInboundFilePath, @vcSystem,GETDATE() )
		
	SET @iLoadInstanceFileID = SCOPE_IDENTITY()
END TRY

BEGIN CATCH
	-- We're not logging to IMIAdmin..StatusLog because until the very last step, we have no LoadInstanceID.
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, LoadInstanceID, UserName )
	SELECT	ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_SEVERITY(),
		ERROR_STATE(), GETDATE(), 0, SUSER_SNAME()
END CATCH

GO
