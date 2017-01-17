SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets ZipCode details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetZipCode]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20),
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ZipCode_BK AS CentauriZipCodeID ,
                s.[ZipCode] ,
                s.[City] ,
                s.[State] ,
                s.[County] ,
                s.[Latitude] ,
                s.[Longitude]
        FROM    [dbo].[H_ZipCode] h
                INNER JOIN [dbo].[S_ZipCodeDetail] s ON s.H_ZipCode_RK = h.H_ZipCode_RK AND s.RecordEndDate IS null
        WHERE   s.LoadDate > @LoadDate;

    END;


GO
