SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	prExecuteProfiles
Author:		Dennis S. Deming
Copyright:	© 2008
Date:		2008.02.28
Purpose:	To run a specific set or requested data profiles
Parameters:	@iLoadInstanceID	int....................etl_profile_result_hdr.LoadInstanceID
		@dRunDate		datetime.........OPT...etl_profile_result_hdr.RunDate
		@iProfileID		int..............OPT...etl_profile_hdr.ProfileID
		@vcClient		varchar( 100 )...OPT...etl_client_build.client_name
		@vcSourceTable		varchar( 100 )...OPT...etl_targ_info.targ_source_table_db + 
						      .........etl_targ_info.targ_source_table_schema + 
						      .........etl_targ_info.targ_source_table
		@vcProfileCategory	varchar( 100 )...OPT...etl_profile_hdr.ProfileCategory
		@vcProfileSubjectArea	varchar( 100 )...OPT...etl_profile_hdr.ProfileSubjectArea
		@vcProfileTable		varchar( 200 )...OPT...etl_profile_hdr.ProfileTable
		@vcProfileField		varchar( 100 )...OPT...etl_profile_hdr.ProfileField
		@bitDebug		bit..............OPT...1 = provide visual output
Depends On:	dbo.etl_profile_hdr
		dbo.etl_profile_result_detail
		dbo.etl_profile_result_hdr
Calls:		IMIAdmin..fxSetStatus
Called By:	
Returns:	0 = success
Notes:		This procedure is a heavily modified version of an earlier procedure
		written by Leon Dowling.  If it works, give hime the credit.  If it blows
		chunks, blame me.
		Any profile that generates more than 1K rows of detail data will 
		automatically be rewritten to return the top 10 relevant values by
		rowcount.
Process:	1.	Declare/initialize variables
		2.	Cursor through profiles, executing as required
Test Script:	EXECUTE prExecuteProfiles @iLoadInstanceID = 1, @vcClient= 'mssp'
@vcProfileTable = 'Member', @bitDebug = 1
, 
			@vcProfileField = 'CustomerMemberID', @bitDebug = 1
		EXECUTE prExecuteProfiles @iLoadInstanceID = 1, @vcProfileTable = 'ClaimLineItem', 
			@vcProfileField = 'CPTProcedureCode', @bitDebug = 1
		EXECUTE prExecuteProfiles @iLoadInstanceID = 1, @bitDebug = 1
ToDo:		Add filtering code for Client and DataSource

Report: 

EXECUTE prExecuteProfiles @iLoadInstanceID = 1, @bitDebug = 1


*************************************************************************************/
--/*
CREATE PROC [dbo].[prExecuteProfiles]
	@iLoadInstanceID	int,				-- etl_profile_result_hdr.LoadInstanceID
	@dRunDate		datetime = NULL,		-- etl_profile_result_hdr.RunDate
	@iProfileID		int = NULL,			-- etl_profile_hdr.ProfileID
	@vcClient		varchar( 100 ) = NULL,		-- etl_client_build.client_name
	@vcSourceTable		varchar( 100 ) = NULL,		-- etl_targ_info.targ_source_table_db + 
								-- etl_targ_info.targ_source_table_schema + 
								-- etl_targ_info.targ_source_table
	@vcProfileCategory	varchar( 100 ) = NULL,		-- etl_profile_hdr.ProfileCategory
	@vcProfileSubjectArea	varchar( 100 ) = NULL,		-- etl_profile_hdr.ProfileSubjectArea
	@vcProfileTable		varchar( 200 ) = NULL,		-- etl_profile_hdr.ProfileTable
	@vcProfileField		varchar( 100 ) = NULL,		-- etl_profile_hdr.ProfileField
	@bitDebug		bit = 0,				-- 1 = provide visual output
	@bitByClient BIT = 1,
	@bitProfileDetail BIT = 0
AS
--BEGIN TRY
--	SET NOCOUNT ON
--*/
	/*---------------------------------------------------------------------------------------------------------------
	DECLARE @iLoadInstanceID	INT				= 1				-- etl_profile_result_hdr.LoadInstanceID
	DECLARE @dRunDate		datetime			= NULL		-- etl_profile_result_hdr.RunDate
	DECLARE @iProfileID		int					= NULL		-- etl_profile_hdr.ProfileID
	DECLARE @vcClient		varchar( 100 )		= NULL		-- etl_client_build.client_name
	DECLARE @vcSourceTable		varchar( 100 )  = NULL		-- etl_targ_info.targ_source_table_db + etl_targ_info.targ_source_table_schema + etl_targ_info.targ_source_table
	DECLARE @vcProfileCategory	varchar( 100 )  = NULL		-- etl_profile_hdr.ProfileCategory
	DECLARE @vcProfileSubjectArea	varchar( 100 ) = NULL		-- etl_profile_hdr.ProfileSubjectArea
	DECLARE @vcProfileTable		varchar( 200 )  = NULL		-- etl_profile_hdr.ProfileTable
	DECLARE @vcProfileField		varchar( 100 )  = NULL		-- etl_profile_hdr.ProfileField
	DECLARE @bitDebug		bit					= 1				-- 1 = provide visual output
	DECLARE @bitByClient BIT					= 1
	DECLARE @bitProfileDetail BIT				= 0
	*/----------------------------------------------------------------------------------------------------------------

	DECLARE @sysProcedureName sysname
	SET @sysProcedureName = OBJECT_NAME( @@PROCID )

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysProcedureName, 'Started'

/*************************************************************************************
	1.	Declare/initialize variables
*************************************************************************************/
	DECLARE @bitGroupBy		bit,
		@bitPopulateDetailTable	bit,
		@iProfile		int,
		@iProfileResultHdrKey	int,
		@numExpectedLow		numeric( 18 , 4 ),
		@numExpectedHigh	numeric( 18 , 4 ),
		@siTopN			smallint,
		@vcDetailSQL		varchar( 8000 ),
		@vcField		varchar( 128 ),
		@vcFrom			varchar( 1000 ),
		@vcGroupBy		varchar( 255 ),
		@vcHeaderSQL		varchar( 8000 ),
		@vcOrderBy		varchar( 255 ),
		@vcValue1Description	varchar( 100 ),
		@vcValue2Description	varchar( 100 ),
		@vcWhere		varchar( 2000 ),
		@vcCmd VARCHAR(4000),
		@vcBaseTableAlias VARCHAR(20)
		
	DECLARE @tblRowCounts TABLE( TotalRows int, AffectedRows int, HeaderKey int )
		    
	SET @dRunDate = ISNULL( @dRunDate, GETDATE() )
	    
/*************************************************************************************
	2.	Cursor through profiles, executing as required
*************************************************************************************/
	IF @bitDebug = 1 
	BEGIN
		PRINT 'Client Filter:       ' + ISNULL( @vcClient, 'N/A' )
		PRINT 'Source Table Filter: ' + ISNULL( @vcSourceTable, 'N/A' )
		PRINT 'Category Filter:     ' + ISNULL( @vcProfileCategory, 'N/A' )
		PRINT 'SubjectArea Filter:  ' + ISNULL( @vcProfileSubjectArea, 'N/A' )
		PRINT 'Table Filter:        ' + ISNULL( @vcProfileTable, 'N/A' )
		PRINT 'Field Filter:        ' + ISNULL( @vcProfileField, 'N/A' )
		PRINT ''
	END

	DECLARE @tRunner TABLE 
	([ProfileID] INT,
	[ProfileCategory] [varchar](100) ,
	[ProfileSubjectArea] [varchar](100) ,
	[ProfileName] [varchar](255) ,
	[ProfileTable] [varchar](100) ,
	[ProfileField] [varchar](100) ,
	[ProfileDesc] [varchar](1000) ,
	[ProfileType] [varchar](20) ,
	[ProfileSQL] [varchar](8000) ,
	[ProfileDTLSql] [varchar](8000) ,
	[ExpectedLowValue] [numeric](18, 4) ,
	[ExpectedHighValue] [numeric](18, 4) ,
	[ExpectedValueType] [varchar](20) ,
	[ProfileValue1Desc] [varchar](100) ,
	[ProfileValue2Desc] [varchar](100) ,
	[PopulateDetailTable] [bit] ,
	[PopulateDetailWithTopN] [smallint] ,
	[FromClause] [varchar](2000) ,
	[WhereClause] [varchar](8000) ,
	[IsGroupByRequired] [bit] ,
	[GroupByClause] [varchar](255) ,
	[HavingClause] [varchar](255) ,
	[OrderByClause] [varchar](255) ,
	[BaseTableAlias] [varchar](20) )

	
	INSERT INTO @tRunner
	(ProfileID,
		ProfileSQL, 
		ProfileValue1Desc, 
		ProfileValue2Desc, 
		ExpectedLowValue, 
		ExpectedHighValue, 
		ProfileDTLSQL,
		PopulateDetailTable,
		PopulateDetailWithTopN,
		OrderByClause, 
		FromClause, 
		WhereClause, 
		ProfileField,
		IsGroupByRequired,
		GroupByClause,
		ProfileTable,
		BaseTableAlias)
	SELECT	ProfileID,
		ProfileSQL, 
		ProfileValue1Desc, 
		ProfileValue2Desc, 
		ExpectedLowValue, 
		ExpectedHighValue, 
		ProfileDTLSQL,
		PopulateDetailTable,
		PopulateDetailWithTopN,
		ISNULL( OrderByClause, '' ),
		ISNULL( FromClause, 'FROM ' + ProfileTable ),
		ISNULL( WhereClause, '' ),
		ProfileField,
		IsGroupByRequired,
		GroupByClause,
		ProfileTable,
		BaseTableAlias
	FROM	etl_profile_hdr
	WHERE	ProfileID = ISNULL( @iProfileID, ProfileID )
		AND ProfileCategory = ISNULL( @vcProfileCategory, ProfileCategory )
		AND ProfileSubjectArea = ISNULL( @vcProfileSubjectArea, ProfileSubjectArea )
		AND ProfileTable = ISNULL( @vcProfileTable, ProfileTable )
		AND ProfileField = ISNULL( @vcProfileField, ProfileField )

	SELECT @iProfile = ProfileID, 
			@vcHeaderSQL = ProfileSQL, 
			@vcValue1Description = ProfileValue1Desc, 
			@vcValue2Description = ProfileValue2Desc, 
			@numExpectedLow = ExpectedLowValue, 
			@numExpectedHigh = ExpectedHighValue, 
			@vcDetailSQL = ProfileDTLSql, 
			@bitPopulateDetailTable = PopulateDetailTable, 
			@siTopN = PopulateDetailWithTopN, 
			@vcOrderBy = OrderByClause, 
			@vcFrom = FromClause, 
			@vcWhere = WhereClause, 
			@vcField = ProfileField, 
			@bitGroupBy = IsGroupByRequired, 
			@vcGroupBy = GroupByClause, 
			@vcProfileTable = ProfileTable, 
			@vcBaseTableAlias = BaseTableAlias
		from @tRunner
		WHERE ProfileID = (SELECT MIN(ProfileID) FROM @tRunner)
		
	WHILE @iProfile IS NOT NULL 
	BEGIN
		DELETE FROM @tblRowCounts
		
		IF @bitDebug = 1 PRINT 'ProfileID ' + CAST( @iProfile AS varchar( 12 )) + ' Header Load: ' + @vcHeaderSQL
		
		INSERT INTO etl_profile_result_hdr( ProfileValue1, ProfileValue2, ProfilePercent )
		EXECUTE( @vcHeaderSQL )
		
		UPDATE	etl_profile_result_hdr
		SET	ProfileID = @iProfile,
			ProfileValue1Desc = @vcValue1Description,
			ProfileValue2Desc = @vcValue2Description,
			ExpectedValueFlag = CASE WHEN ProfilePercent BETWEEN @numExpectedLow AND @numExpectedHigh THEN 1 ELSE 0 END,
			LoadInstanceID = @iLoadInstanceID,
			ProfileRunDate = @dRunDate
		OUTPUT	DELETED.ProfileValue1,
			DELETED.ProfileValue2,
			DELETED.ProfileResultHdrKey
		INTO	@tblRowCounts
		WHERE	ProfileID IS NULL

		IF @bitByClient = 1 
			AND EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
							WHERE TABLE_NAME = @vcProfileTable
								AND Column_name = 'Client'
							)
		BEGIN
		 
			SELECT  @vcCmd = 'select ProfileID = ' + CONVERT(VARCHAR(10),@iProfile) 
							+ ', LoadInstanceID = ' + CONVERT(VARCHAR(10),@iLoadInstanceID)
							+ ', ProfileRunDate = ''' + CONVERT(VARCHAR(30),@dRunDate, 109) + ''''
							+ ', ' + CASE WHEN @vcBaseTableAlias IS NOT NULL THEN @vcBaseTableAlias+'.' ELSE '' END+ 'client '
							+ ', RecCnt = count(*) '+ CHAR(13)
							+  CASE WHEN @vcFrom IS NULL THEN ' FROM ' + @vcProfileTable ELSE @vcFrom END
							+ ' ' + CHAR(13)
							+ @vcWhere + CHAR(13)
							+ ' GROUP BY ' + CASE WHEN @vcBaseTableAlias IS NOT NULL THEN @vcBaseTableAlias+'.' ELSE '' END+ 'Client; ' + CHAR(13)
				
			IF @bitDebug = 1 PRINT 'ProfileID ' + CAST( @iProfile AS varchar( 12 )) + ' Client SQL: ' + @vcCmd
		
			INSERT INTO etl_profile_result_hdr_client
			EXECUTE( @vcCmd )
  
		END      


		IF @bitPopulateDetailTable = 0
			OR @bitProfileDetail = 0
		BEGIN
			PRINT '----- PopulateDetailTable = 0 for ProfileID ' + CAST( @iProfile AS varchar( 12 )) + '. -----'
		END
		ELSE
		BEGIN
			-- if more than 1000 rows are affected, we just want the top 10 values and their counts
			IF EXISTS( SELECT * FROM @tblRowCounts WHERE AffectedRows > 1000 )
				SET @siTopN = 10

			IF @siTopN IS NOT NULL
				SET @vcDetailSQL = 'SELECT TOP ' + CAST( @siTopN AS varchar( 5 )) + ' ' + SUBSTRING( @vcDetailSQL, 8, 8000 )

			-- add in the population of TargetFieldCount, and tweak the ORDER BY clause if excessive rowcount casued us to aggregate
			IF EXISTS( SELECT * FROM @tblRowCounts WHERE AffectedRows > 1000 )
			BEGIN
				SET @vcDetailSQL = @vcDetailSQL + ', TargetFieldCount = COUNT(*)'
				SET @vcOrderBy = 'ORDER BY COUNT(*) DESC'
			END
			ELSE
				SET @vcDetailSQL = @vcDetailSQL + ', TargetFieldCount = NULL'

			SET @vcDetailSQL = @vcDetailSQL + ' ' + @vcFrom + ' ' + @vcWhere + ' ' 

			-- if we're building a GROUP BY clause, remove references to RowID from the SELECT clause
			IF EXISTS( SELECT * FROM @tblRowCounts WHERE AffectedRows > 1000 ) OR @bitGroupBy = 1
				SET @vcDetailSQL = REPLACE( @vcDetailSQL, 'RowID = RowID,', 'NULL,' ) + ISNULL( @vcGroupBy, 'GROUP BY ' + @vcField ) + ' '	

			SET @vcDetailSQL = @vcDetailSQL + @vcOrderBy				

			IF @bitDebug = 1 PRINT 'ProfileID ' + CAST( @iProfile AS varchar( 12 )) + ' Detail Load: ' + @vcDetailSQL

			INSERT INTO etl_profile_result_detail( RowID, TargetField, TargetFieldValue, TargetFieldCount )
			EXECUTE( @vcDetailSQL )
			
			UPDATE	etl_profile_result_detail
			SET	ProfileResultHdrKey = ( SELECT HeaderKey FROM @tblRowCounts )
			WHERE	ProfileResultHdrKey IS NULL
		END
				
		SELECT @iProfile = MIN(ProfileID) 
			FROM @tRunner 
			WHERE ProfileID > @iProfile

		SELECT @vcHeaderSQL = ProfileSQL, 
				@vcValue1Description = ProfileValue1Desc, 
				@vcValue2Description = ProfileValue2Desc, 
				@numExpectedLow = ExpectedLowValue, 
				@numExpectedHigh = ExpectedHighValue, 
				@vcDetailSQL = ProfileDTLSql, 
				@bitPopulateDetailTable = PopulateDetailTable, 
				@siTopN = PopulateDetailWithTopN, 
				@vcOrderBy = OrderByClause, 
				@vcFrom = FromClause, 
				@vcWhere = WhereClause, 
				@vcField = ProfileField, 
				@bitGroupBy = IsGroupByRequired, 
				@vcGroupBy = GroupByClause, 
				@vcProfileTable = ProfileTable, 
				@vcBaseTableAlias = BaseTableAlias
			from @tRunner
			WHERE ProfileID = @iProfile
		

	END

	IF @bitDebug = 1
	BEGIN
		SELECT	* 
		FROM	etl_profile_result_hdr
		WHERE	ProfileRunDate = @dRunDate

		SELECT *
		FROM dbo.etl_profile_result_hdr_client
		WHERE ProfileRunDate = @dRunDate

	END

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysProcedureName, 'Completed'
/*
END TRY

BEGIN CATCH
	DECLARE	@iErrorLine		int, 
		@iErrorNumber		int,
		@iErrorSeverity		int,
		@iErrorState		int,
		@nvcErrorMessage	nvarchar(  2048 ), 
		@nvcErrorProcedure	nvarchar(  126 )

	-- capture error info so we can fail it up the line
	SELECT	@iErrorLine = ERROR_LINE(),
		@iErrorNumber = ERROR_NUMBER(),
		@iErrorSeverity = ERROR_SEVERITY(),
		@iErrorState = ERROR_STATE(),
		@nvcErrorMessage = ERROR_MESSAGE(),
		@nvcErrorProcedure = ERROR_PROCEDURE()
		
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, InstanceID, UserName )
	SELECT	@iErrorLine, @nvcErrorMessage, @iErrorNumber, @nvcErrorProcedure, @iErrorSeverity,
		@iErrorState, GETDATE(), InstanceID, SUSER_SNAME()
	FROM	IMIAdmin..ClientProcessInstance
	WHERE	LoadInstanceID = @iLoadInstanceID
	
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysProcedureName, 'Failed'
	
	RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH



*/


GO
