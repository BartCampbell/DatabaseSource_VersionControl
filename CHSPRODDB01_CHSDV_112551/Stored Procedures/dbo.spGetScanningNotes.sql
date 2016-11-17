SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Description:	Gets ScanningNotes details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetScanningNotes]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20),
	@LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ScanningNotes_BK AS CentauriScanningNotesID ,
                s.[Note_Text] ,
	s.[IsCNA] ,
	s.[LastUpdated]

        FROM    [dbo].[H_ScanningNotes] h
                LEFT OUTER JOIN [dbo].[S_ScanningNotesDetails] s ON s.H_ScanningNotes_RK = h.H_ScanningNotes_RK
		WHERE s.LoadDate> @LoadDate				
				;

    END;
GO
