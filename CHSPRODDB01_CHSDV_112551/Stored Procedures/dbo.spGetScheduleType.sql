SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Description:	Gets ScheduleType details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetScheduleType]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20),
	@LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ScheduleType_BK AS CentauriScheduleTypeID ,
                s.ScheduleType

        FROM    [dbo].[H_ScheduleType] h
                Inner Join [dbo].[S_ScheduleTypeDetail] s ON s.H_ScheduleType_RK = h.H_ScheduleType_RK
		WHERE s.LoadDate> @LoadDate				
				;

    END;

GO
