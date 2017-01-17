SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 10/04/2016 Reploacing RecordEndDate with Link Satellite PJ
-- Description:	Gets ScannedData details from DV
-- =============================================

CREATE PROCEDURE [dbo].[spGetScannedData]
-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ScannedData_BK AS [CentauriScannedDataID] ,
                hs.Suspect_BK AS [CentauriSuspectID] ,
                d.DocumentType_BK AS [CentauriDocumentTypeID] ,
                u.User_PK AS CentauriUserID ,
                s.[FileName] ,
                s.[dtInsert] ,
                s.[is_deleted] ,
                s.[CodedStatus] ,
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_ScannedData] h
                INNER JOIN dbo.S_ScannedDataDetail s ON s.H_ScannedData_RK = h.H_ScannedData_RK AND s.RecordEndDate IS NULL
                LEFT OUTER JOIN (SELECT lld.H_ScannedData_RK,lld.H_DocumentType_RK,lsd.LoadDate FROM  dbo.L_ScannedDataDocumentType lld 
							INNER JOIN LS_ScannedDataDocumentType lsd ON lsd.L_ScannedDataDocumentType_RK=lld.L_ScannedDataDocumentType_RK AND lsd.RecordEndDate IS NULL)  ld
				ON ld.H_ScannedData_RK = h.H_ScannedData_RK 
                LEFT OUTER JOIN dbo.H_DocumentType d ON d.H_DocumentType_RK = ld.H_DocumentType_RK
                LEFT OUTER JOIN (SELECT lsu.H_ScannedData_RK,lsu.H_User_RK, ssu.LoadDate FROM dbo.L_ScannedDataUser lsu 
								INNER JOIN dbo.LS_ScannedDataUser ssu ON ssu.L_ScannedDataUser_RK = lsu.L_ScannedDataUser_RK  AND ssu.RecordEndDate IS NULL) su 
						ON su.H_ScannedData_RK = h.H_ScannedData_RK
                LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = su.H_User_RK
                LEFT OUTER JOIN (SELECT lls.H_ScannedData_RK, lls.H_Suspect_RK, lss.LoadDate FROM dbo.L_ScannedDataSuspect lls
					INNER JOIN dbo.LS_ScannedDataSuspect lss ON lss.L_ScannedDataSuspect_RK = lls.L_ScannedDataSuspect_RK AND lss.RecordEndDate IS NULL) ls
							 ON ls.H_ScannedData_RK = h.H_ScannedData_RK 
                LEFT OUTER JOIN dbo.H_Suspect hs ON hs.H_Suspect_RK = ls.H_Suspect_RK 
        WHERE   s.LoadDate > @LoadDate OR ld.LoadDate>@LoadDate OR su.LoadDate>@LoadDate OR ls.LoadDate>@LoadDate;

    END;

--GO


GO
