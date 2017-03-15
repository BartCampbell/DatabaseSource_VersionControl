SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Load the XML data parsed from the X12_ConsoleImport.exe into the Temp table for further processing
Use:
	
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spStageXMLInsert] (
	@XMLData XML
	,@TableName VARCHAR(100) -- Not Used
	,@OptionalStr VARCHAR(100)
	)
AS
BEGIN
	TRUNCATE TABLE dbo.TempXML837

	SET NOCOUNT ON;

	DECLARE @XML XML
	SET @XML = ( SELECT @XMLData )

	INSERT INTO	x12.StageXML (
		FileLogID
		,XMLData
		)
	VALUES ( 
		CAST(@OptionalStr AS INT)
		,@XML 
		)

END
GO
