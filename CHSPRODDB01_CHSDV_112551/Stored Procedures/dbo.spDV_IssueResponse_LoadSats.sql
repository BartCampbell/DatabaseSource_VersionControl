SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Data Vault IssueResponse Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_IssueResponse_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_IssueResponseDEMO LOAD

INSERT INTO [dbo].[S_IssueResponseDetail]
           ([S_IssueResponseDetail_RK]
           ,[LoadDate]
           ,[H_IssueResponse_RK]
           ,[IssueResponse]
           ,[HashDiff]
           ,[RecordSource])
    
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IssueResponse],
                                                              
                                                              
                                                              '')))))), 2)) ,
                        LoadDate ,
                        IssueResponseHashKey ,
                          RTRIM(LTRIM(rw.[IssueResponse])),
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(
                                                              RTRIM(LTRIM(COALESCE(rw.[IssueResponse],
                                                              
                                                              
                                                              ''))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblIssueResponseStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(
                                                              RTRIM(LTRIM(COALESCE(rw.[IssueResponse],
                                                              
                                                              
                                                              ''))))), 2))  NOT IN (
                        SELECT  HashDiff
                        FROM    S_IssueResponseDetail
                        WHERE   H_IssueResponse_RK = rw.IssueResponseHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CRI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IssueResponse],
                                                              
                                                              
                                                              '')))))), 2)) ,
                        LoadDate ,
                        IssueResponseHashKey ,
                          RTRIM(LTRIM(rw.[IssueResponse])),
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(
                                                              RTRIM(LTRIM(COALESCE(rw.[IssueResponse],
                                                              
                                                              
                                                              ''))))), 2)) ,
                        RecordSource

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_IssueResponseDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_IssueResponseDetail z
                                  WHERE     z.H_IssueResponse_RK = a.H_IssueResponse_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_IssueResponseDetail a
        WHERE   a.RecordEndDate IS NULL; 







    END;



GO
