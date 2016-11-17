SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/31/2016
-- Description:	Data Vault ZipCode Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ZipCode_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_ZipCodeDEMO LOAD

        INSERT  INTO [dbo].[S_ZipCodeDetail]
                ( [S_ZipCodeDetail_RK] ,
                  [LoadDate] ,
                  [H_ZipCode_RK] ,
                  [ZipCode] ,
                  [City] ,
                  [State] ,
                  [County] ,
                  [Latitude] ,
                  [Longitude] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CZI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ZipCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[City],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[State],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[County],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Latitude],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Longitude],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ZipCodeHashKey ,
                        [ZipCode] ,
                        [City] ,
                        [State] ,
                        [County] ,
                        [Latitude] ,
                        [Longitude] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ZipCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[City],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[State],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[County],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Latitude],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Longitude],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblZipCodeStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ZipCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[City],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[State],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[County],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Latitude],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Longitude],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ZipCodeDetail
                        WHERE   H_ZipCode_RK = rw.ZipCodeHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.cci = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CZI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ZipCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[City],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[State],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[County],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Latitude],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Longitude],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ZipCodeHashKey ,
                        [ZipCode] ,
                        [City] ,
                        [State] ,
                        [County] ,
                        [Latitude] ,
                        [Longitude] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ZipCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[City],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[State],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[County],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Latitude],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Longitude],
                                                              '')))))), 2)) ,
                        RecordSource;
	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ZipCodeDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ZipCodeDetail z
                                  WHERE     z.H_ZipCode_RK = a.H_ZipCode_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ZipCodeDetail a
        WHERE   a.RecordEndDate IS NULL; 



    END;




GO
