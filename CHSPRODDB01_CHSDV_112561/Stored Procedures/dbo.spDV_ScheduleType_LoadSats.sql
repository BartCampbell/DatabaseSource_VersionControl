SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
 --Update 09/27/2016 Adding LoadDate to Primary Key PJ
-- Description:	Data Vault ScheduleType Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScheduleType_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_ScheduleTypeDEMO LOAD

        INSERT  INTO [dbo].[S_ScheduleTypeDetail]
                ( [S_ScheduleTypeDetail_RK] ,
                  [LoadDate] ,
                  [H_ScheduleType_RK] ,
                  [ScheduleType] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ScheduleType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ScheduleTypeHashKey ,
                        RTRIM(LTRIM(rw.[ScheduleType])) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(RTRIM(LTRIM(COALESCE(rw.[ScheduleType],
                                                              ''))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblScheduleTypeStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(RTRIM(LTRIM(COALESCE(rw.[ScheduleType],
                                                              ''))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ScheduleTypeDetail
                        WHERE   H_ScheduleType_RK = rw.ScheduleTypeHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.cci = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ScheduleType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ScheduleTypeHashKey ,
                        RTRIM(LTRIM(rw.[ScheduleType])) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(RTRIM(LTRIM(COALESCE(rw.[ScheduleType],
                                                              ''))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ScheduleTypeDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ScheduleTypeDetail z
                                  WHERE     z.H_ScheduleType_RK = a.H_ScheduleType_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ScheduleTypeDetail a
        WHERE   a.RecordEndDate IS NULL; 



    END;




GO
