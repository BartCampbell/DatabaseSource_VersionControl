SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Transforms member data from dbo.Member into the Member.Members table, as well as setting up member attributes.
-- =============================================
CREATE PROCEDURE [Import].[TransformMembers]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;

		DECLARE @RaceCategory tinyint
		DECLARE @EthnicityCategory tinyint
		DECLARE @RaceSrcCategory tinyint
		DECLARE @EthnSrcCategory tinyint
		DECLARE @SpokenLangCategory tinyint
		DECLARE @SpokenLangSrcCategory tinyint
		DECLARE @WrittenLangCategory tinyint
		DECLARE @WrittenLangSrcCategory tinyint
		DECLARE @OtherLangCategory tinyint
		DECLARE @OtherLangSrcCategory tinyint
		DECLARE @StateCategory tinyint
		
		DECLARE @RaceCategoryDefault smallint
		DECLARE @EthnicityCategoryDefault smallint
		DECLARE @RaceSrcCategoryDefault smallint
		DECLARE @EthnSrcCategoryDefault smallint
		DECLARE @SpokenLangCategoryDefault smallint
		DECLARE @SpokenLangSrcCategoryDefault smallint
		DECLARE @WrittenLangCategoryDefault smallint
		DECLARE @WrittenLangSrcCategoryDefault smallint
		DECLARE @OtherLangCategoryDefault smallint
		DECLARE @OtherLangSrcCategoryDefault smallint
		DECLARE @StateCategoryDefault smallint
		
		SELECT @RaceCategory = MbrAttribCtgyID, @RaceCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'Race'
		SELECT @EthnicityCategory = MbrAttribCtgyID, @EthnicityCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'Ethnicity'
		SELECT @RaceSrcCategory = MbrAttribCtgyID, @RaceSrcCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'RaceSrc'
		SELECT @EthnSrcCategory = MbrAttribCtgyID, @EthnSrcCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'EthnSrc'
		SELECT @SpokenLangCategory = MbrAttribCtgyID, @SpokenLangCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'SpokenLang'
		SELECT @SpokenLangSrcCategory = MbrAttribCtgyID, @SpokenLangSrcCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'SpokenLangSrc'
		SELECT @WrittenLangCategory = MbrAttribCtgyID, @WrittenLangCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'WrittenLang'
		SELECT @WrittenLangSrcCategory = MbrAttribCtgyID, @WrittenLangSrcCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'WrittenLangSrc'
		SELECT @OtherLangCategory = MbrAttribCtgyID, @OtherLangCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'OtherLang'
		SELECT @OtherLangSrcCategory = MbrAttribCtgyID, @OtherLangSrcCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'OtherLangSrc'
		SELECT @StateCategory = MbrAttribCtgyID, @StateCategoryDefault = DefaultMbrAttribID FROM Member.AttributeCategories WHERE Abbrev = 'State'

		--Purge Existing Member Attribute records for the specified DataSet, if any
		DELETE MA FROM Member.MemberAttributes AS MA WHERE DataSetID = @DataSetID;
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Member.MemberAttributes AS MA)
			TRUNCATE TABLE Member.MemberAttributes;
	
		--Purge Existing Member records for the specified DataSet, if any
		DELETE FROM Member.Members WHERE DataSetID = @DataSetID;
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Member.Members AS M)
			TRUNCATE TABLE Member.Members;
		
		
		DECLARE @DefaultDOB datetime;
		SET @DefaultDOB = '1/1/1753';  --Minimum allowed value for datetime
		
		--Populate Members
		INSERT INTO Member.Members 
				(CustomerMemberID, DOB, DataSetID, DataSourceID, Gender, IhdsMemberID, MemberID, NameFirst, NameLast)
		SELECT	M.CustomerMemberID, 
				CASE WHEN ISNULL(M.DateOfBirth, @DefaultDOB) < '1/1/1800' THEN '1/1/1800' ELSE ISNULL(M.DateOfBirth, @DefaultDOB) END AS DOB, 
				@DataSetID, 
				BDSS.DataSourceID,
				CASE M.Gender WHEN 'F' THEN 0 WHEN 'M' THEN 1 ELSE 2 END,
				M.ihds_member_id,
				M.MemberID,
				M.NameFirst,
				M.NameLast
		FROM	dbo.Member AS M
				INNER JOIN Batch.DataSetSources AS BDSS
						ON M.DataSource = BDSS.DataSource AND
							BDSS.IsSupplemental = 0 AND               
							BDSS.DataSetID = @DataSetID AND
							BDSS.SourceSchema = 'dbo' AND
							BDSS.SourceTable = 'Member'                          
		WHERE	((@HedisMeasureID IS NULL) OR (M.HedisMeasureID = @HedisMeasureID))
		ORDER BY M.DateOfBirth, M.MemberID;
		
		--Populate MemberAttributes
		WITH MemberRaces AS --Race
		(
			SELECT	M.DSMemberID, t.Race 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		Races AS
		(
			SELECT	Abbrev AS Race, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @RaceCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @RaceCategoryDefault) AS MbrAttrib
		FROM	MemberRaces AS MR
				LEFT OUTER JOIN Races AS R
						ON MR.Race = R.Race
		ORDER BY DSMemberID;
						
		WITH MemberEthnicities AS --Ethnicity
		(
			SELECT	M.DSMemberID, t.Ethnicity  
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		Ethnicities AS
		(
			SELECT	Abbrev AS Ethnicity, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @EthnicityCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @EthnicityCategoryDefault) AS MbrAttrib
		FROM	MemberEthnicities AS MR
				LEFT OUTER JOIN Ethnicities AS R
						ON MR.Ethnicity = R.Ethnicity
		ORDER BY DSMemberID;
		
		WITH MemberRaceEthnSrcs AS --RaceSrc
		(
			SELECT	M.DSMemberID, t.RaceSource AS RaceEthnSrc 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		RaceEthnSrcs AS
		(
			SELECT	Abbrev AS RaceEthnSrc, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @RaceSrcCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @RaceSrcCategoryDefault) AS MbrAttrib
		FROM	MemberRaceEthnSrcs AS MR
				LEFT OUTER JOIN RaceEthnSrcs AS R
						ON MR.RaceEthnSrc = R.RaceEthnSrc
		ORDER BY DSMemberID;
		
		WITH MemberRaceEthnSrcs AS --EthnSrc
		(
			SELECT	M.DSMemberID, t.EthnicitySource AS RaceEthnSrc 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		RaceEthnSrcs AS
		(
			SELECT	Abbrev AS RaceEthnSrc, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @EthnSrcCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @EthnSrcCategoryDefault) AS MbrAttrib
		FROM	MemberRaceEthnSrcs AS MR
				LEFT OUTER JOIN RaceEthnSrcs AS R
						ON MR.RaceEthnSrc = R.RaceEthnSrc
		ORDER BY DSMemberID;
		
		WITH MemberSpokenLangs AS --SpokenLang
		(
			SELECT	M.DSMemberID, t.SpokenLanguage AS SpokenLang 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		SpokenLangs AS
		(
			SELECT	Abbrev AS SpokenLang, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @SpokenLangCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @SpokenLangCategoryDefault) AS MbrAttrib
		FROM	MemberSpokenLangs AS MR
				LEFT OUTER JOIN SpokenLangs AS R
						ON MR.SpokenLang = R.SpokenLang
		ORDER BY DSMemberID;
		
		WITH MemberSpokenLangSrcs AS --SpokenLangSrc
		(
			SELECT	M.DSMemberID, t.SpokenLanguageSource AS SpokenLangSrc 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		SpokenLangSrcs AS
		(
			SELECT	Abbrev AS SpokenLangSrc, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @SpokenLangSrcCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @SpokenLangSrcCategoryDefault) AS MbrAttrib
		FROM	MemberSpokenLangSrcs AS MR
				LEFT OUTER JOIN SpokenLangSrcs AS R
						ON MR.SpokenLangSrc = R.SpokenLangSrc
		ORDER BY DSMemberID;
		
		WITH MemberWrittenLangs AS --WrittenLang
		(
			SELECT	M.DSMemberID, t.WrittenLanguage AS WrittenLang
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		WrittenLangs AS
		(
			SELECT	Abbrev AS WrittenLang, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @WrittenLangCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @WrittenLangCategoryDefault) AS MbrAttrib
		FROM	MemberWrittenLangs AS MR
				LEFT OUTER JOIN WrittenLangs AS R
						ON MR.WrittenLang = R.WrittenLang
		ORDER BY DSMemberID;
		
		WITH MemberWrittenLangSrcs AS --WrittenLangSrc
		(
			SELECT	M.DSMemberID, t.WrittenLanguageSource AS WrittenLangSrc 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		WrittenLangSrcs AS
		(
			SELECT	Abbrev AS WrittenLangSrc, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @WrittenLangSrcCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @WrittenLangSrcCategoryDefault) AS MbrAttrib
		FROM	MemberWrittenLangSrcs AS MR
				LEFT OUTER JOIN WrittenLangSrcs AS R
						ON MR.WrittenLangSrc = R.WrittenLangSrc
		ORDER BY DSMemberID;
		
		WITH MemberOtherLangs AS --OtherLang
		(
			SELECT	M.DSMemberID, t.OtherLanguage AS OtherLang 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		OtherLangs AS
		(
			SELECT	Abbrev AS OtherLang, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @OtherLangCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @OtherLangCategoryDefault) AS MbrAttrib
		FROM	MemberOtherLangs AS MR
				LEFT OUTER JOIN OtherLangs AS R
						ON MR.OtherLang = R.OtherLang
		ORDER BY DSMemberID;	
		
		WITH MemberOtherLangSrcs AS --OtherLangSrc
		(
			SELECT	M.DSMemberID, t.OtherLanguageSource AS OtherLangSrc 
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		OtherLangSrcs AS
		(
			SELECT	Abbrev AS OtherLangSrc, MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @OtherLangSrcCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @OtherLangSrcCategoryDefault) AS MbrAttrib
		FROM	MemberOtherLangSrcs AS MR
				LEFT OUTER JOIN OtherLangSrcs AS R
						ON MR.OtherLangSrc = R.OtherLangSrc
		ORDER BY DSMemberID;
						
		WITH MemberStates AS --State
		(
			SELECT	M.DSMemberID, t.[State]  
			FROM	Member.Members AS M
					INNER JOIN dbo.Member AS t
							ON M.MemberID = t.MemberID AND
								M.IhdsMemberID = t.ihds_member_id AND
								M.DataSetID = @DataSetID
		),
		States AS
		(
			SELECT	Abbrev AS [State], MbrAttribID 
			FROM	Member.Attributes
			WHERE	(MbrAttribCtgyID = @StateCategory)
		)
		INSERT INTO Member.MemberAttributes 
				(DataSetID, DSMemberID, MbrAttribID)
		SELECT	@DataSetID, MR.DSMemberID, ISNULL(R.MbrAttribID, @StateCategoryDefault) AS MbrAttrib
		FROM	MemberStates AS MR
				LEFT OUTER JOIN States AS R
						ON MR.[State] = R.[State]
		ORDER BY DSMemberID;

		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END


GO
GRANT VIEW DEFINITION ON  [Import].[TransformMembers] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformMembers] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformMembers] TO [Processor]
GO
