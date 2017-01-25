SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/10/2012
-- Description:	Imports chart images from RDSM.
-- =============================================
CREATE PROCEDURE [dbo].[ImportChartImagesFromRDSM]
AS
BEGIN
	SET NOCOUNT ON;

    EXEC RDSM.ImportChartImagesFromFTPS;
    EXEC RDSM.UpdateChartImagesXref;
    
    INSERT INTO dbo.PursuitEventChartImage
			(PursuitEventID,
			ImageOrdinal,
			ImageName,
			MimeType,
			ImageData)
	SELECT	RV.PursuitEventID AS PursuitEventID,
			1 AS ImageOrdinal,
			CASE WHEN NC.ImageName IS NOT NULL THEN CONVERT(varchar(32), CIFI.FileID) + '_' ELSE '' END + CIFI.Name AS ImageName,
			REPLACE(LOWER(CASE 
				WHEN RIGHT(RTRIM(CIFI.NAME), 3) = 'pdf' 
				THEN 'application/pdf' 
				WHEN RIGHT(RTRIM(CIFI.NAME), 4) IN ('jpeg', 'tiff')
				THEN 'image/' + RIGHT(RTRIM(CIFI.Name), 4)
				ELSE 'image/' + RIGHT(RTRIM(CIFI.Name), 3) END), 'image/jpg', 'image/jpeg') AS MimeType,
			CIFI.FileData AS ImageData
	FROM	RDSM.ChartImageFileImport AS CIFI
			INNER JOIN dbo.Pursuit AS R
					ON CIFI.Xref = R.PursuitNumber
			INNER JOIN dbo.PursuitEvent AS RV
					ON R.PursuitID = RV.PursuitID
			LEFT OUTER JOIN dbo.PursuitEventChartImage AS RVCI
					ON RV.PursuitEventID = RVCI.PursuitEventID AND
						CIFI.Name = RVCI.ImageName AND
						BINARY_CHECKSUM(CIFI.FileData) = BINARY_CHECKSUM(RVCI.ImageData) AND
						DATALENGTH(CIFI.FileData) = DATALENGTH(RVCI.ImageData)               
			LEFT OUTER JOIN dbo.PursuitEventChartImage AS NC --NameCheck
					ON RV.PursuitEventID = RVCI.PursuitEventID AND
						CIFI.Name = RVCI.ImageName
	WHERE	(CIFI.Xref IS NOT NULL) AND
			(RVCI.PursuitEventChartImageID IS NULL) AND
			(CIFI.Ignore = 0);
    
END

GO
