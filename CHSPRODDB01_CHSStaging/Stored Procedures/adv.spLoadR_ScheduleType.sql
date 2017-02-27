SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
-- Description:	Load the R_AdvanceScheduleType reference table and pull back the hashScheduleTypekey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_ScheduleType] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_AdvanceScheduleType]
           ([ClientID]
           ,[ClientScheduleTypeID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[ScheduleType_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblScheduleTypeStage a
		LEFT OUTER JOIN CHSDV.dbo.R_AdvanceScheduleType b 
		ON a.ScheduleType_PK = b.ClientScheduleTypeID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
		WHERE a.CCI = @CCI AND b.ClientScheduleTypeID IS NULL;

UPDATE  CHSStaging.adv.tblScheduleTypeStage
SET     ScheduleTypeHashKey = b.ScheduleTypeHashKey
FROM    CHSStaging.adv.tblScheduleTypeStage a
        INNER JOIN CHSDV.dbo.R_AdvanceScheduleType b ON a.ScheduleType_PK = b.ClientScheduleTypeID AND b.RecordSource = a.RecordSource
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblScheduleTypeStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblScheduleTypeStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblScheduleTypeStage
SET  CSI = b.CentauriScheduleTypeID
FROM    CHSStaging.adv.tblScheduleTypeStage a
        INNER JOIN CHSDV.dbo.R_AdvanceScheduleType b ON a.ScheduleType_PK = b.ClientScheduleTypeID AND b.RecordSource = a.RecordSource
                                           AND a.CCI = b.ClientID;
END



GO
