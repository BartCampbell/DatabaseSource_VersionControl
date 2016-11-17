SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/07/2016
-- Description:	Gets provider office detail from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProviderOfficeDetail]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT DISTINCT
                m.ProviderOffice_BK AS CentauriProviderOfficeID ,
                [EMR_Type] ,
                [EMR_Type_PK] ,
                [GroupName] ,
                @CCI AS ClientID ,
                m.LoadDate AS LoadDate ,
                m.RecordSource AS RecordSource
        FROM    dbo.H_ProviderOffice m
                INNER JOIN dbo.S_ProviderOfficeDetail s ON s.H_ProviderOffice_RK = m.H_ProviderOffice_RK
        WHERE   s.LoadDate > @LoadDate;

    END;

GO
