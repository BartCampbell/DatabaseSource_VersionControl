SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_load_ncqa_datasets]
as
/*
	- Created:   1/10/2008 by Randy Wilson to load NCQA Decks
	- Modified:  12/8/2010 by Mike Kriz for 2011 HEDIS Season
	- Tweaked:   10/10/2011 by Mike Kriz for 2012 HEDIS Season

***********************************************************************************************************************
*** INSTRUCTIONS ******************************************************************************************************
***********************************************************************************************************************

-By Randy Wilson

In order to run this proc, downloaded zip files from NCQA need to be placed in the 
IMISQL10\E:\dataware\ncqa10\decks\to_be_uploaded\
folder.

Sometimes NCQA re-posts a deck that IMI has already fully loaded (and doesn't advance from A to B.
The nature of this script being a delete/insert means that only the most recent deck will be 
reflected.  However, this script isn't addressing the archiving of the load folder, and deleteing of it.
Therefore this script will hiccup.  I'm currently going in and archiving the old "to be uploaded" folder
when I get a "replacement" deck.


make sure naming conventions haven't changed (they sometimes do during the season).
The current code handlese this type of scenarios:

--CAP_A_SAMPLEDeck		CAP_Sample
--CAP_A_TESTDeck		CAP_A
--CAP_A_SAMPLEDeck1		CAP_Sample
--CAP_A_TESTDeck1		CAP_A
--CAP_A_SAMPLEDeck2		CAP_Samp2x
--CAP_A_TESTDeck2		CAP_A2x

New Scenarios:
--CHL-NDC_A_TESTDeck	CHL_A
--CHL-NDC_A_SAMPLEDeck	CHL_Sample

***********************************************************************************************************************
***********************************************************************************************************************
***********************************************************************************************************************/

SET NOCOUNT ON;

--- SET IMPORT INSTRUCTIONS ---------------------------------------
DECLARE @CreateBCPFormatFiles bit;
DECLARE @dbName nvarchar(128);

DECLARE @finishedPath nvarchar(512);
DECLARE @formatPath nvarchar(512);
DECLARE @temppath varchar(512);
DECLARE @tempformatpath varchar(512);
DECLARE @lcPath nvarchar(512);
DECLARE @winzipPath nvarchar(512);
DECLARE @zipPath nvarchar(512);

DECLARE @lccmd varchar(2000);
DECLARE @liLogSeq int;

DECLARE @OutputDebugInfo bit;

SET @CreateBCPFormatFiles = 1;
SET @dbName = 'NCQA_QI17_RDSM';

SET @finishedPath = '\\FS01\Reference\ncqa\2017\decks\imported_files\';	--The folder under which the unzipped files are stored
SET @formatPath = '\\FS01\Reference\ncqa\2017\decks\format_files\';		--The folder containing the bulk import file specifications
SET @lcPath = '\\FS01\Reference\ncqa\2017\decks\zip_files\';				--The folder containing new ZIP files to import
SET @winzipPath = 'C:\"Program Files (x86)"\WinZip\wzunzip.exe -o';				--The base command line method for unzipping .ZIP files
SET @zipPath = '\\FS01\Reference\ncqa\2017\decks\imported_zip_files\';		--The folder to store ZIP files that have been imported
SET @temppath = 'C:\temp\ncqa\';												--Added 11/14/2013, the local temp folder to which network share files are moved for bulk import to avoid "Access Denied" errors
SET @OutputDebugInfo = 0;

-----------------------------------------------------
SET @tempformatpath = @temppath;

PRINT '*** BCP Formats Path: "' + UPPER(@formatPath) + '" ***';
PRINT '*** Zip File Path: "' + UPPER(@lcPath) + '" ***';
PRINT '*** Imported File Path: "' + UPPER(@finishedPath) + '" ***';
PRINT '*** Imported Zip File Path: "' + UPPER(@zipPath) + '" ***';
PRINT '*** Imported Temp File Path: "' + UPPER(@temppath) + '" ***';
PRINT '';
PRINT '';

DECLARE @CmdOutput TABLE
(
	ID int IDENTITY(1, 1) NOT NULL,
	OutputLine varchar(max) NULL
);

--- CREATE IMPORT FORMAT FILES, IF NECESSARY
IF @CreateBCPFormatFiles = 1
BEGIN

	PRINT 'Generating Import Formats...'
	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingEnrollment format nul -c -x -f ' + @formatPath + 'member_en-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingMembers format nul -c -x -f ' + @formatPath + 'member_gm-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingVisits format nul -c -x -f ' + @formatPath + 'visit-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingPharmacy format nul -c -x -f ' + @formatPath + 'pharm-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingProviders format nul -x -c -f ' + @formatPath + 'provider-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

		SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingProvidersHAI format nul -x -c -f ' + @formatPath + 'provider-hai-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingLabs format nul -c -x -f ' + @formatPath + 'lab-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingPharmacyClinical format nul -c -x -f ' + @formatPath + 'pharm-c-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingObservation format nul -c -x -f ' + @formatPath + 'obs-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT '...Successfully Executed: ' + @lcCMD

	SET @lcCMD = 'bcp ' + QUOTENAME(@dbName) + '.import.StagingScoreKeys format nul -c -x -f ' + @formatPath + 'scorekey-f-c-x.xml -t -T '
	INSERT INTO @CmdOutput (OutputLine)
	EXEC master..xp_cmdshell @lcCMD
	PRINT 'Successfully Executed: ' + @lcCMD

	SET @lccmd = ''
	PRINT ''
	
	SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @formatPath + '*.*" "' + @tempformatpath + '"''';
	PRINT @lccmd
	INSERT INTO @CmdOutput (OutputLine)
	EXEC (@lccmd)

	DELETE FROM @CmdOutput;
END

IF OBJECT_ID('tempdb..#hold') IS NOT NULL
	DROP TABLE #hold

CREATE TABLE #hold (txt1 VARCHAR(120))

SET @lccmd = 'master..xp_cmdshell ''dir ' + @lcPath + ''''

INSERT INTO #hold
	EXEC (@lccmd)
	
--SELECT	*, 
--		patindex('%.zip%',txt1) AS zipIndex, 
--		LEFT(txt1, patindex('%.zip%',txt1)) AS upTilZip, 
--		substring(txt1,40,patindex('%.zip%',txt1)-40) As onlyFile
--FROM	#hold 
--WHERE	patindex('%.zip%',txt1) > 40

--Purge any decks that did not load due to a previous failure...
DELETE FROM import.DataSets WHERE ISNULL(importdate, '') = ''

--Add new decks to the list...
insert into	import.DataSets 
select	datasetkey		= substring(txt1,40,patindex('%.zip%',txt1)-40),
		dirdate			= getdate(),
		importdate		= NULL,
		setpath			= @lcPath
From	#hold 
where	txt1 IS NOT NULL AND
		patindex('%.zip%',txt1) > 40

--Display the decks that were added to the list to be imported...
select	datasetkey		= substring(txt1,40,patindex('%.zip%',txt1)-40),
		dirdate			= getdate(),
		setpath			= @lcPath
From	#hold 
where	txt1 IS NOT NULL AND
		patindex('%.zip%',txt1) > 40


--**************************************************************************
--**************************************************************************

--Begin deck import...
DECLARE @liDatasetid int, 
		@lcdatasetkey varchar(50), 
		@lcsetpath varchar(256), 
		@lcworkpath varchar(200),
		@lczipfilename varchar(50)

DECLARE setlist CURSOR FOR
    SELECT datasetid, datasetkey, setpath 
        FROM import.DataSets a
			WHERE ISNULL(importdate, '') = ''
--				AND datasetkey = 'CHL_vU'

OPEN setlist

FETCH NEXT FROM setlist
    INTO @lidatasetid, @lczipfilename, @lcSetPath

WHILE @@FETCH_STATUS = 0
    BEGIN
		
		PRINT '';
		PRINT '************************************************';
		PRINT '';
		PRINT '';

--Scenarios:
--CAP_A_SAMPLEDeck		CAP_Sample
--CAP_A_TESTDeck		CAP_A
--CAP_A_SAMPLEDeck1		CAP_Sample
--CAP_A_TESTDeck1		CAP_A
--CAP_A_SAMPLEDeck2		CAP_Samp2x
--CAP_A_TESTDeck2		CAP_A2x
--CHL-NDC_A_TESTDeck	CHL_A
--CHL-NDC_A_SAMPLEDeck	CHL_Sample

--New Scenarios:
--PPC_V1_Sampling		PPC_V1_Sample

		/* PRE HEDIS 2016 METHOD... FILE NAMES CHANGED IN HEDIS 2016 ***********************************************************
		set	@lcDataSetKey =	case	when	substring(@lczipfilename,5,3) = 'NDC'
									then	left(@lczipfilename,3)+'_'
									else	left(@lczipfilename,4)
							end +
							case	when	right(@lczipfilename,8) in ('Sampling') 
									then	substring(@lczipfilename,5,2)												
									when	right(@lczipfilename,4) in ('Deck','eck1','eck2','eck3','eck4') and
											substring(@lczipfilename,5,3) = 'NDC'
									then	case	when	substring(@lczipfilename,11,4) = 'TEST'
													then	substring(@lczipfilename,9,1)
													when	substring(@lczipfilename,11,4) = 'SAMP'
													then	'Sample'
											end													
									when	right(@lczipfilename,4) in ('Deck','eck1','eck2','eck3','eck4')
									then	case	when	substring(@lczipfilename,7,4) = 'TEST'
													then	substring(@lczipfilename,5,1)
													when	substring(@lczipfilename,7,4) = 'SAMP'
													then	'Sample'
											end													
									else	case	when	substring(@lczipfilename,7,4) = 'TEST'
													then	substring(@lczipfilename,5,1)+
															right(@lczipfilename,1)+'x'
													when	substring(@lczipfilename,7,4) = 'SAMP'
													then	'Samp'+
															right(@lczipfilename,1)+'x'
											end	
							end
		************************************************************************************************************************/

		DECLARE @deckParse varchar(32);
		DECLARE @measureParse varchar(32);
		DECLARE @underscorePos int;
		SET @underscorePos = CHARINDEX('_', @lczipfilename);

		IF @underscorePos > 0 
			BEGIN;
				SET @measureParse = SUBSTRING(@lczipfilename, 1, @underscorePos - 1);

				SET @deckParse = CASE WHEN @lczipfilename LIKE '%[_]NDC[_]%' THEN 'NDC_' ELSE '' END +
									CASE WHEN CHARINDEX('SAMPLE', @lczipfilename, @underscorePos + 1) = @underscorePos + 1 THEN 'SAMPLE' + RIGHT(@lczipfilename, LEN(@lczipfilename) - @underscorePos - 6)
										WHEN CHARINDEX('V', @lczipfilename, @underscorePos + 1) = @underscorePos + 1 THEN RIGHT(@lczipfilename, LEN(@lczipfilename) - @underscorePos - 1)
										ELSE 'UNK' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(64), GETDATE(), 121), '-', ''), ':', ''), '.', ' '), ' ', '_')
										END;

				SET @lcdatasetkey = @measureParse + '_' + @deckParse;
			END;
		ELSE	
				SET @lcdatasetkey = NULL;


		PRINT 'Importing Deck... (' + @lczipfilename + '.zip --> ' + @lcdatasetkey + ')';
		PRINT 'Measure: ' + @measureParse;
		PRINT 'Deck: ' + @deckParse;
		PRINT '';

		set @lccmd = 'master..xp_cmdshell ''md ' + @finishedPath + @lcDataSetKey + ''''

		IF @OutputDebugInfo = 1
			PRINT  @lccmd

		INSERT INTO @CmdOutput (OutputLine)
		EXEC (@lccmd)
		
		/*
		set @lccmd = 'master..xp_cmdshell ''copy ' + @lcSetPath + @lczipfilename + '.zip ' +
					 @lcSetPath + @lcDataSetKey + '\'+ @lczipfilename +'.zip ' +''''
		print  @lccmd
		EXEC (@lccmd)*/

		set @lccmd = 'master..xp_cmdshell ''' + @winzipPath + ' ' +
					 @lcSetPath + @lczipfilename +'.zip ' +
					 @finishedPath + @lcDataSetKey +' '''
		
		IF @OutputDebugInfo = 1
			PRINT  @lccmd

		INSERT INTO @CmdOutput (OutputLine)
		EXEC (@lccmd)

		set @lccmd = 'master..xp_cmdshell ''move ' + @lcSetPath + @lczipfilename + '.zip ' +
					 @zippath + @lczipfilename +'.zip ' +''''
		
		IF @OutputDebugInfo = 1
			PRINT  @lccmd

		INSERT INTO @CmdOutput (OutputLine)
		EXEC (@lccmd)

		set @lcworkpath = @finishedPath + @lcDataSetKey + '\'

		IF OBJECT_ID('tempdb..#holddir') IS NOT NULL
		 DROP TABLE #holddir
		CREATE TABLE #holddir (txt1 VARCHAR(120))

		set @lccmd = 'master..xp_cmdshell ''dir ' + @lcworkpath + ''''

		INSERT INTO #holddir
		EXEC (@lccmd)



		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%member-en%')
			BEGIN 
				PRINT ' - Importing Enrollment...';

				delete from import.StagingEnrollment
				
				--Added 11/14/2013 to accommodate to data files on a network share
				DECLARE @filename nvarchar(512);
				DECLARE @formatname nvarchar(512);
				
				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'member-en.txt';
				SET @formatname = 'member_en-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingEnrollment from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.Enrollment WHERE measureset = ''' + @lcDataSetKey + ''''

				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingEnrollment'

				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Enrollment  
					EXEC (@lcCMD)
			END




		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%member-gm%')
			BEGIN
				PRINT ' - Importing Membership...';
				delete from import.StagingMembers 

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'member-gm.txt';
				SET @formatname = 'member_gm-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingMembers from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.Members WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingMembers'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Members 
					EXEC (@lcCMD)
			END

		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%visit%')
			BEGIN
				PRINT ' - Importing Visits...';
				delete from import.StagingVisits 

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'visit.txt';
				SET @formatname = 'visit-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingVisits from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				UPDATE import.StagingVisits SET provid = 'UNK001' WHERE provid IS NULL OR provid = '';
			
				SET @lcCMD = 'DELETE FROM import.Visits WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL, NULL FROM import.StagingVisits'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Visits 
					EXEC (@lcCMD)
			END
--*/
		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%lab%')
			BEGIN
				PRINT ' - Importing Labs...';
				delete from import.StagingLabs 

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'lab.txt';
				SET @formatname = 'lab-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingLabs from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.Labs WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingLabs'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Labs 
					EXEC (@lcCMD)
			END

		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%obs%')
			BEGIN
				PRINT ' - Importing Observation...';
				delete from import.StagingObservation

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'obs.txt';
				SET @formatname = 'obs-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingObservation from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.Observation WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingObservation'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Observation 
					EXEC (@lcCMD)
			END
--/*
		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%provider%' AND txt1 NOT LIKE '%provider-hai%')
			BEGIN
				PRINT ' - Importing Providers...';
				delete from import.StagingProviders 

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'provider.txt';
				SET @formatname = 'provider-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				BEGIN TRY
					SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingProviders from '
							+ '''' + @temppath + @filename + ''' '
							+ 'WITH ( DATAFILETYPE=''char'' , '
							+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
					
					IF @OutputDebugInfo = 1
					PRINT  @lccmd

					EXEC (@lcCMD)
				
				END TRY
				BEGIN CATCH
					SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @finishedPath + @filename + '" "' + @temppath + @filename + '"''';
					
					IF @OutputDebugInfo = 1
					PRINT  @lccmd

					INSERT INTO @CmdOutput (OutputLine)
					EXEC (@lccmd)

					SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingProviders from '
							+ '''' + @temppath + @filename + ''' '
							+ 'WITH ( DATAFILETYPE=''char'' , '
							+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
					IF @OutputDebugInfo = 1
					PRINT  @lccmd

					EXEC (@lcCMD)
				END CATCH

				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------
				SET @lcCMD = 'DELETE FROM import.Providers WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingProviders'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Providers  
					EXEC (@lcCMD)
			END

			IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%provider-hai%')
			BEGIN
				PRINT ' - Importing Providers for HAI...';
				delete from import.StagingProvidersHAI

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'provider-hai.txt';
				SET @formatname = 'provider-hai-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				BEGIN TRY
					SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingProvidersHAI from '
							+ '''' + @temppath + @filename + ''' '
							+ 'WITH ( DATAFILETYPE=''char'' , '
							+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
					
					IF @OutputDebugInfo = 1
					PRINT  @lccmd

					EXEC (@lcCMD)
				
				END TRY
				BEGIN CATCH
					PRINT ''
				END CATCH

				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.ProvidersHAI WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingProvidersHAI'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.ProvidersHAI
					EXEC (@lcCMD)
			END

		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%pharm%' AND txt1 NOT LIKE '%pharm-c%')
			BEGIN
				PRINT ' - Importing Pharmacy...';
				delete from import.StagingPharmacy 

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'pharm.txt';
				SET @formatname = 'pharm-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingPharmacy from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.Pharmacy WHERE measureset = ''' + @lcDataSetKey + ''''
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingPharmacy'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Pharmacy 
					EXEC (@lcCMD)
			END

		IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%pharm-c%')
			BEGIN
				PRINT ' - Importing Pharmacy Clinical...';
				delete from import.StagingPharmacyClinical

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'pharm-c.txt';
				SET @formatname = 'pharm-c-f-c-x.xml';
				
				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @lcworkpath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingPharmacyClinical from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lccmd = 'master..xp_cmdshell ''del /q "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)
				------------------------------------------------------------------------------

				SET @lcCMD = 'DELETE FROM import.PharmacyClinical WHERE measureset = ''' + @lcDataSetKey + ''''
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)

				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingPharmacyClinical'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.PharmacyClinical
					EXEC (@lcCMD)
			END

		--BEGIN TRY 
		--IF 1=1 AND EXISTS (SELECT * from #holddir where txt1 like '%Scorekey%')
		--	BEGIN
		--		delete from import.StagingScoreKeys 

		--		SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingScoreKeys from '
		--				+ ''''+@lcworkpath+ @lcDataSetKey +'_Scorekey.txt'''
		--		PRINT @lcCMD
		--		EXEC (@lcCMD)

		--		SET @lcCMD = 'IF OBJECT_ID(''Scorekey_'+@lcDataSetKey+'_import'') is not null DROP TABLE Scorekey_'+@lcDataSetKey+'_import'
		--		--PRINT @lcCMD
		--		EXEC (@lcCMD)

		--	SET @lcCMD = 'IF OBJECT_ID(''scorekey.Raw' + REPLACE(@lcDataSetKey, '_Sample', '') + ''') is not null DROP TABLE scorekey.Raw' + REPLACE(@lcDataSetKey, '_Sample', '')
		--		--PRINT @lcCMD
		--		EXEC (@lcCMD)

		--		SET @lcCMD = 'select * into scorekey.Raw' + REPLACE(@lcDataSetKey, '_Sample', '') + ' from import.StagingScoreKeys'
		--		PRINT @lcCMD
		--		EXEC (@lcCMD)
		--	END
		--END TRY
		--BEGIN CATCH
		--END CATCH
		

		IF NOT EXISTS(SELECT TOP 1 1 FROM import.Providers WHERE measureset = @lcDataSetKey) AND
			NOT EXISTS(SELECT TOP 1 1 FROM import.ProvidersHAI WHERE measureset = @lcDataSetKey)
			BEGIN
				TRUNCATE TABLE import.StagingProviders;

				--Added/altered 11/14/2013 to accommodate to data files on a network share
				SET @filename = 'provider.txt';
				SET @formatname = 'provider-f-c-x.xml';

				--INSERT INTO import.StagingProviders SELECT * FROM dbo.ProviderDefault;

				SET @lccmd = 'master..xp_cmdshell ''copy /y "' + @finishedPath + @filename + '" "' + @temppath + @filename + '"''';
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO @CmdOutput (OutputLine)
				EXEC (@lccmd)

				SET @lcCMD = 'bulk insert ' + QUOTENAME(@dbName) + '.import.StagingProviders from '
						+ '''' + @temppath + @filename + ''' '
						+ 'WITH ( DATAFILETYPE=''char'' , '
						+ 'FORMATFILE = ''' + @tempformatpath + @formatname + ''' )';
						
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				EXEC (@lcCMD)
				
				SET @lcCMD = 'DELETE FROM import.Providers WHERE measureset = ''' + @lcDataSetKey + ''''
				EXEC (@lcCMD)

				
				SET @lcCMD = 'SELECT *, ''' + @lcDataSetKey + ''', ''' + @measureParse + ''', NULL FROM import.StagingProviders'
				
				IF @OutputDebugInfo = 1
					PRINT  @lccmd

				INSERT INTO import.Providers  
					EXEC (@lcCMD)
				
			END 


		update	import.DataSets 
		set		importdate = getdate()
		where	datasetkey = @lczipfilename

		
		DELETE FROM @CmdOutput;
		
		FETCH NEXT FROM setlist
			INTO @lidatasetid, @lczipfilename, @lcSetPath
    END

CLOSE setlist
DEALLOCATE setlist

SET @lccmd = 'master..xp_cmdshell ''del /q "' + @tempformatpath + '*.*"''';

IF @OutputDebugInfo = 1
	PRINT  @lccmd

INSERT INTO @CmdOutput (OutputLine)
EXEC (@lccmd);


--- Added by Mike Kriz ----------------------------------------------------------------------------------
truncate table dw_xref_ihds_member_id
truncate table dw_xref_ihds_provider_id
truncate table mpi_master_entity

UPDATE import.Enrollment SET ihds_member_id = NULL
UPDATE import.Labs SET ihds_member_id = NULL
UPDATE import.Members SET ihds_member_id = NULL
UPDATE import.Pharmacy SET ihds_member_id = NULL
UPDATE import.Providers SET ihds_provider_id = NULL
UPDATE import.Visits SET ihds_member_id = NULL, ihds_provider_id_servicing = NULL

--- POPULATE IHDS/DW MEMBER AND PROVIDER TABLES
DECLARE @client varchar(255)
DECLARE @enddate char(8)
DECLARE @year int
SET @year = YEAR(GETDATE())

IF MONTH(GETDATE()) < 9
	SET @year = @year - 1

SET @client = 'NCQA' + CAST(@year AS varchar(255))
SET @enddate = CAST(@year AS varchar(4)) + '1231'

--- Moved here by Mike Kriz
EXECUTE dbo.prPopulateMPITables
EXECUTE dbo.prCreateInstanceAndLoadData @client, @enddate










GO
