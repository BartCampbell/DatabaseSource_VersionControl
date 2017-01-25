SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[AdministrativeEvent_Search]
    @MemberID varchar(50),
    @MeasureID int = NULL,
    @SubMetricID int = NULL
AS 
SELECT  AE.AdministrativeEventID,
        AE.CustomerAdministrativeEventID,
        AE.MeasureID,
        AE.HEDISSubMetricID,
        AE.MemberID,
        AE.ProviderID,
        AE.ServiceDate,
        AE.ProcedureCode,
        AE.DiagnosisCode,
        AE.LOINC,
        AE.LabResult,
        AE.NDCCode,
        AE.NDCDescription,
        AE.CPT_IICode,
        AE.Data_Source
FROM    dbo.AdministrativeEvent AE
        JOIN dbo.Member MEM ON AE.MemberID = MEM.MemberID
WHERE   MEM.CustomerMemberID = @MemberID AND
        AE.MeasureID = ISNULL(@MeasureID, AE.MeasureID) AND
        AE.HEDISSubMetricID = ISNULL(@SubMetricID, AE.HEDISSubMetricID)




GO
