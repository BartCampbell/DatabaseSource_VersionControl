SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
--Update 09/27/2016 Adding LoadDate to Primary Key PJ
-- Description:	Data Vault AdvanceLocation Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Location_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_AdvanceLocationDEMO LOAD
        INSERT  INTO [dbo].[S_AdvanceLocationDetail]
                ( [S_AdvanceLocationDetail_RK] ,
                  [LoadDate] ,
                  [H_AdvanceLocation_RK] ,
                  [Location] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CLI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Location],
                                                              ''))),':', 
															  RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))
															  ))), 2)) ,
                        LoadDate ,
                        LocationHashKey ,
                        RTRIM(LTRIM(rw.[Location])) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(RTRIM(LTRIM(COALESCE(rw.[Location],
                                                              ''))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblLocationStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(RTRIM(LTRIM(COALESCE(rw.[Location],
                                                              ''))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_AdvanceLocationDetail
                        WHERE   H_AdvanceLocation_RK = rw.LocationHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CLI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Location],
                                                              ''))),':', 
															  RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        LocationHashKey ,
                        RTRIM(LTRIM(rw.[Location])) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(RTRIM(LTRIM(COALESCE(rw.[Location],
                                                              ''))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_AdvanceLocationDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_AdvanceLocationDetail z
                                  WHERE     z.H_AdvanceLocation_RK = a.H_AdvanceLocation_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_AdvanceLocationDetail a
        WHERE   a.RecordEndDate IS NULL; 



    END;


GO
