SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets Project details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProject]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Project_BK AS CentauriProjectID ,
                s.[Project_Name] ,
                s.[IsScan] ,
                s.[IsCode] ,
                s.[Client_PK] ,
                s.[dtInsert] ,
                s.[IsProspective] ,
                s.[IsRetrospective] ,
                s.[IsHEDIS] ,
                s.[ProjectGroup] ,
                s.[ProjectGroup_PK] ,
                @CCI AS ClientID ,
                s.recordSource ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_Project] h
                Inner Join [dbo].[S_ProjectDetails] s ON s.H_Project_RK = h.H_Project_RK
        WHERE   s.LoadDate > @LoadDate;

    END;

GO
