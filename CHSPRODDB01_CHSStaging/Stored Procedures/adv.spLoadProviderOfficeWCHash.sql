SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
--Update adding/dropping new columns for Advance updates 02282017 PDJ
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderOfficeHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderOfficeWCHash]
    @CCI INT ,
    @Date DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
			DECLARE @recordsource VARCHAR(20)
	SET @recordsource =(SELECT TOP 1 RecordSource FROM adv.AdvanceVariables WHERE  AVKey =(SELECT TOP 1 VariableLoadKey FROM adv.AdvanceVariableLoad))
     
        INSERT  INTO adv.StagingHash
                ( HashDiff ,
                  ClientID ,
                  TableName ,
                  CreateDate,
				  RecordSource
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ZipCode_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactPerson,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.GroupName,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LocationID,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Pool_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedUser_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              --''))), ':',
                                                              --RTRIM(LTRIM(COALESCE(a.hasPriorityNote,
                                                              --''))), ':',
                                                              --RTRIM(LTRIM(COALESCE(a.ProviderOfficeSubBucket_PK,
                                                              '')))
															  ))), 2)) ,
                        @CCI ,
                        'tblProviderOffice' ,
                        @Date,
						@recordsource
                FROM    adv.tblProviderOfficeWCStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ZipCode_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactPerson,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.GroupName,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LocationID,
                                                              ''))), ':',
															    RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Pool_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedUser_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              --''))), ':',
                                                              --RTRIM(LTRIM(COALESCE(a.hasPriorityNote,
                                                              --''))), ':',
                                                              --RTRIM(LTRIM(COALESCE(a.ProviderOfficeSubBucket_PK,
                                                              '')))
															  ))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblProviderOffice'
															 AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;





    END;

GO
