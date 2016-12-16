SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
--Update 09/27/2016 Adding LoadDate to Primary Key PJ
-- Description:	Data Vault ScannedData Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScannedData_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		

	--**S_ScannedDataDetail LOAD

INSERT INTO [dbo].[S_ScannedDataDetail]
           ([S_ScannedDataDetail_RK]
           ,[LoadDate]
           ,[H_ScannedData_RK]
           ,[FileName]
           ,[dtInsert]
           ,[is_deleted]
           ,[CodedStatus]
           ,[HashDiff]
           ,[RecordSource]
)
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[FileName],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[is_deleted],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedStatus],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ScannedDataHashKey ,
                        [FileName]
           ,[dtInsert]
           ,[is_deleted]
           ,[CodedStatus],
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[FileName],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[is_deleted],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedStatus],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[FileName],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[is_deleted],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedStatus],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ScannedDataDetail
                        WHERE   H_ScannedData_RK = rw.ScannedDataHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[FileName],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[is_deleted],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedStatus],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ScannedDataHashKey ,
                        [FileName]
           ,[dtInsert]
           ,[is_deleted]
           ,[CodedStatus],
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[FileName],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[is_deleted],
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[CodedStatus],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ScannedDataDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ScannedDataDetail z
                                  WHERE     z.H_ScannedData_RK = a.H_ScannedData_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ScannedDataDetail a
        WHERE   RecordEndDate IS NULL; 

    
    END;
    
	

GO
