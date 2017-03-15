SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	08/19/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateEnrolleeHCC_112550
-- =============================================
CREATE PROC [oec].[spUpdateEnrolleeHCC_112550]
AS
    DECLARE @CurrentDate DATETIME = GETDATE(); 

    SET NOCOUNT ON;
    
    UPDATE  h
    SET     h.CentauriMemberID = m.CentauriMemberID ,
            h.H_Member_RK = m.MemberHashKey ,
            h.OEC_ProjectID = '3' ,
            h.L_MemberOECProject_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                        UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':',
                                                                                     RTRIM(LTRIM(COALESCE('3', '')))))), 2)) ,
            h.LS_MemberOECProjectHCC_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                            UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.LoadDate, ''))), ':',
                                                                                         RTRIM(LTRIM(COALESCE(h.FileName, ''))), ':',
                                                                                         RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':',
                                                                                         RTRIM(LTRIM(COALESCE('3', ''))), ':', RTRIM(LTRIM(COALESCE(h.HCC, '')))))), 2)) ,
            h.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE('3', ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(h.HCC, '')))))), 2)) ,
            LoadDate = @CurrentDate ,
            FileName = 'OEC_112550_001_20160815_ClaimLineData.txt'
    FROM    oec.EnrolleeHCC_112550 h
            INNER JOIN CHSDV.dbo.R_Member m ON h.Client_ID = m.ClientID
                                               AND h.Member_ID = m.ClientMemberID; 



GO
