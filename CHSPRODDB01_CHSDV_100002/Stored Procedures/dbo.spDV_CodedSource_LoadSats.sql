SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Data Vault CodedSource Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_CodedSource_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		

	--**S_CodedSourceDetail LOAD
INSERT INTO [dbo].[S_CodedSourceDetail]
           ([S_CodedSourceDetail_RK]
           ,[LoadDate]
           ,[H_CodedSource_RK]
           ,[CodedSource]
           ,[sortOrder]
           ,[HashDiff]
           ,[RecordSource]
)

           SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedSource],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                LoadDate ,
                CodedSourceHashKey ,
                [CodedSource] ,
				[sortOrder],
               UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[CodedSource],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              '')))))), 2)),
                RecordSource
        FROM    CHSStaging.adv.tblCodedSourceStage rw WITH ( NOLOCK )
        WHERE     UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[CodedSource],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              '')))))), 2)) NOT IN (
                SELECT  HashDiff
                FROM    S_CodedSourceDetail
                WHERE   H_CodedSource_RK = rw.CodedSourceHashKey
                        AND RecordEndDate IS NULL )
                AND rw.CCI = @CCI
        GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedSource],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                LoadDate ,
                CodedSourceHashKey ,
                [CodedSource] ,
				[sortOrder],
               UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[CodedSource],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              '')))))), 2)),
                RecordSource;

	--RECORD END DATE CLEANUP
UPDATE  dbo.S_CodedSourceDetail
SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                          FROM      dbo.S_CodedSourceDetail z
                          WHERE     z.H_CodedSource_RK = a.H_CodedSource_RK
                                    AND z.LoadDate > a.LoadDate
                        )
FROM    dbo.S_CodedSourceDetail a
WHERE   RecordEndDate IS NULL; 

    
    END;
    

GO
