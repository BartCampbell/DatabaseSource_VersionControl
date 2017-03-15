SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	09/01/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateEnrolleeStratum_112548
-- =============================================
CREATE PROC [oec].[spUpdateEnrolleeStratum_112548]
    @FileName VARCHAR(255),
    @ProjectID VARCHAR(20)
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
                                                                                             RTRIM(LTRIM(COALESCE(@FileName, ''))), ':',
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
            FileName = @FileName
    FROM    oec.EnrolleeStratum_112548 h
            INNER JOIN CHSDV.dbo.R_Member m ON h.Client_ID = m.ClientID
                                               AND h.Member_ID = m.ClientMemberID
		  INNER JOIN CHSDV.dbo.R_OECProject p ON h.Client_ID = p.CentauriClientID AND p.ProjectID = @ProjectID; 





GO
