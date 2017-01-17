SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets providers details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProvider]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20) , 
	   @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  DISTINCT h.Provider_BK AS CentauriproviderID ,
		                s.[LastName] ,
				s.[FirstName],
				s.[NPI],
				s.TIN ,
				s.PIN ,
				s.LastUpdated 
      FROM    [dbo].[H_Provider] h
		     Inner JOIN  [dbo].[S_ProviderMasterDemo] s ON s.H_Provider_RK = h.H_Provider_RK AND s.RecordEndDate IS NULL
	 WHERE   s.LoadDate > @LoadDate;

    END;

--GO

GO
