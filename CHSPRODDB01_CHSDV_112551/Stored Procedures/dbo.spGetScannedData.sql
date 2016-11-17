SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
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
                INNER JOIN dbo.S_ScannedDataDetail s ON s.H_ScannedData_RK = h.H_ScannedData_RK
                LEFT OUTER JOIN dbo.L_ScannedDataDocumentType ld ON ld.H_ScannedData_RK = h.H_ScannedData_RK
                LEFT OUTER JOIN dbo.H_DocumentType d ON d.H_DocumentType_RK = ld.H_DocumentType_RK
                LEFT OUTER JOIN dbo.L_ScannedDataUser su ON su.H_ScannedData_RK = h.H_ScannedData_RK
                LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = su.H_User_RK
                LEFT OUTER JOIN dbo.L_ScannedDataSuspect ls ON ls.H_ScannedData_RK = h.H_ScannedData_RK
                LEFT OUTER JOIN dbo.H_Suspect hs ON hs.H_Suspect_RK = ls.H_Suspect_RK
        WHERE   s.LoadDate > @LoadDate;

    END;

--GO
GO
