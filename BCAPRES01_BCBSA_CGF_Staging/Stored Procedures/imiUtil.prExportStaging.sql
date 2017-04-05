SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:

Test Script: 

*/

--/*
CREATE PROC [imiUtil].[prExportStaging]

	@iLoadInstanceID INT = 1,
	@bDebug BIT = 0

AS
--*/
/*--------------------------------
DECLARE @iLoadInstanceID INT = 1,
	@bDebug BIT = 1

--*/------------------------------


DECLARE @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@nvCmd NVARCHAR(4000),
	@nvCmd2 NVARCHAR(4000),
	@i INT


DECLARE @vcExportPath VARCHAR(1000) = '\\fs01\filestore\Accordion\BCBSAZ\20170310\',
	@vcTabname VARCHAR(50),
	@vcTargetFileName VARCHAR(100)

DECLARE @TabList TABLE (RowID INT IDENTITY(1,1), TabName VARCHAR(50))

INSERT INTO @TabList
SELECT 'Member'
UNION SELECT 'Eligibility'
UNION SELECT 'Provider'
UNION SELECT 'Claim'
UNION SELECT 'ClaimLineItem'
UNION SELECT 'PharmacyClaim'
UNION SELECT 'LabResult'


SELECT @i = MIN(rowid)
	FROM @TabList

WHILE @i IS NOT NULL 
BEGIN
	
	SELECT @vcTabname = 'dbo.' + TabName,
			@vcTargetFileName = 'BCBSAZ_' + TabName + '.txt'
		FROM @TabList
		WHERE RowID = @i


	EXEC imiUtil.prExportExtract 
		@vcInputTab1 = @vcTabname,
		@vcInputTab2 = NULL,
		@vcInputTab3 = NULL,
		@vcInputTab4 = NULL,
		@vcInputTab5 = NULL,

		@bOutputFileDelimted = 1,
		@vcFileDelimiter	= '|',

		@vcTargetPath 		= @vcExportPath,
		@vcTargetFileName 	= @vcTargetFileName,
		@bTop10				= 0,
		@bDebug				= 0,
		@bExec				= 1,
		@bCreateOutFile		= 1,
		@bIncludeColumnNames = 1,
		@bZipFile = 1

	SELECT @i = MIN(rowid)
		FROM @TabList
		WHERE Rowid > @i

END

GO
