SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	09/13/2016
-- Description:	updates the reference keys for the OEC staging data
-- Usage:			
--		  EXECUTE oec.spUpdateDoNotChase_112548
-- =============================================
CREATE PROC [oec].[spUpdateDoNotChase_112548]
    @FileName VARCHAR(255),
    @ProjectID VARCHAR(20)
AS
    DECLARE @CurrentDate DATETIME = GETDATE(); 

    SET NOCOUNT ON;
    
    UPDATE  h
    SET     h.H_OEC_RK = o.H_OEC_RK ,
            h.S_OEC_DNC_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@CurrentDate, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(@FileName, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(o.OEC_ProjectID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(h.Issuer, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(h.Claim_ID, '')))))), 2)) ,
            h.HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(o.OEC_ProjectID, ''))), ':', 
														  RTRIM(LTRIM(COALESCE(h.Issuer, ''))), ':', 
														  RTRIM(LTRIM(COALESCE(h.Claim_ID, '')))))), 2)) ,
            LoadDate = @CurrentDate ,
            FileName = @FileName
    FROM    oec.DoNotChase_112548 h --2679
		  INNER JOIN (SELECT DISTINCT ClaimID, H_OEC_RK, OEC_ProjectID FROM oec.AdvanceOECRaw_112548 WHERE Duplicate = 0) o ON h.Claim_ID = o.ClaimID--2679



GO
