SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	08/30/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateEnrolleeStratum_112550
-- =============================================
CREATE PROC [oec].[spUpdateEnrolleeStratum_112550]
AS
    DECLARE @CurrentDate DATETIME = GETDATE(); 

    SET NOCOUNT ON;
    
    UPDATE  h
    SET     h.CentauriMemberID = m.CentauriMemberID ,
            h.H_Member_RK = m.MemberHashKey ,
            h.OEC_ProjectID = p.CentauriOECProjectID ,
		  h.H_OECProject_RK = p.OECProjectHashKey,
            h.L_MemberOECProject_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                        UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':',
                                                                                     RTRIM(LTRIM(COALESCE(p.CentauriOECProjectID, '')))))), 2)) ,
            h.LS_MemberOECProjectStratum_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                                                UPPER(CONCAT(RTRIM(LTRIM(COALESCE(h.LoadDate, ''))), ':',
                                                                                             RTRIM(LTRIM(COALESCE('BSW_OEC_112550_001_20160815_Enrollee_Stratum.csv', ''))), ':',
                                                                                             RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':',
                                                                                             RTRIM(LTRIM(COALESCE(p.CentauriOECProjectID, ''))), ':',
                                                                                             RTRIM(LTRIM(COALESCE(h.Issuer, ''))), ':',
                                                                                             RTRIM(LTRIM(COALESCE(h.Stratum, ''))), ':',
                                                                                             RTRIM(LTRIM(COALESCE(h.Stratum_Description, '')))))), 2)) ,
            h.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriOECProjectID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(h.Issuer, ''))), ':', RTRIM(LTRIM(COALESCE(h.Stratum, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(h.Stratum_Description, '')))))), 2)) ,
            LoadDate = @CurrentDate ,
            FileName = 'BSW_OEC_112550_001_20160815_Enrollee_Stratum.csv'
    FROM    oec.EnrolleeStratum_112550 h
            INNER JOIN CHSDV.dbo.R_Member m ON h.Client_ID = m.ClientID
                                               AND h.Member_ID = m.ClientMemberID
		  INNER JOIN CHSDV.dbo.R_OECProject p ON h.Client_ID = p.CentauriClientID AND p.ProjectID = '001'




GO
