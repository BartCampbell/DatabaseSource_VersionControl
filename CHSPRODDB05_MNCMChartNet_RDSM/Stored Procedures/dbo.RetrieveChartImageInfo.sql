SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/11/2012
-- Description:	Retrieves the specified file information.
-- =============================================
CREATE PROCEDURE [dbo].[RetrieveChartImageInfo]
(
	@CreatedDate datetime = NULL,
	@OriginalPath nvarchar(2048) = NULL,
	@Path nvarchar(2048) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	CreatedDate,
            FileID,
            [FileName],
            Name,
            NotifyDate,
            OriginalPath,
            [Path],
            Size,
            Xref
    FROM	dbo.ChartImageFileImport
    WHERE	(@CreatedDate IS NULL OR CreatedDate BETWEEN DATEADD(second, -1, @CreatedDate) AND DATEADD(second, 1, @CreatedDate)) AND
			(@Path IS NULL OR [Path] = @Path) AND
			(@OriginalPath IS NULL OR [OriginalPath] = @OriginalPath)
	ORDER BY Name, OriginalPath, CreatedDate;
    
    
END
GO
GRANT EXECUTE ON  [dbo].[RetrieveChartImageInfo] TO [FileImportReporting]
GO
