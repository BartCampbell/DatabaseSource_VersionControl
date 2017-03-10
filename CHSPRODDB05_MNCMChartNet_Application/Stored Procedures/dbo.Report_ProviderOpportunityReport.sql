SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Report_ProviderOpportunityReport] @ProviderID int = NULL
AS 

SELECT	DISTINCT
        Pr.CustomerProviderID,		--Report Header
        Pr.NameEntityFullName,		--Report Header
        M.CustomerMemberID,			--Report Body
        M.NameLast,					--Report Body
        M.NameFirst,				--Report Body
        M.DateOfBirth,				--Report Body
        Me.HEDISMeasure,			--Report Body
        HEDISSubMetricDescription = HSM.ReportName,	--Report Body
        AbstractionStatus = ASTAT.Description,
        AbstractorName,
        Pr.ProviderID
FROM    PursuitEvent PE
        INNER JOIN Pursuit P ON PE.PursuitID = P.PursuitID
        INNER JOIN Member M ON P.MemberID = M.MemberID
        INNER JOIN Providers Pr ON P.ProviderID = Pr.ProviderID
        INNER JOIN ProviderSite PS ON P.ProviderSiteID = PS.ProviderSiteID
        INNER JOIN Measure Me ON PE.MeasureID = Me.MeasureID
        INNER JOIN MemberMeasureSample MMS ON M.MemberID = MMS.MemberID AND
                                              PE.MeasureID = MMS.MeasureID
        INNER JOIN MemberMeasureMetricScoring MMMS ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric HSM ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID
        LEFT JOIN AbstractionStatus ASTAT ON PE.PursuitEventStatus = ASTAT.AbstractionStatusID
        LEFT JOIN Abstractor A ON P.AbstractorID = A.AbstractorID
WHERE   MMMS.HybridHitCount = 0 AND
        HSM.HEDISSubMetricCode NOT IN ('FPC1', 'FPC2', 'FPC3', 'FPC4') AND
        HSM.HEDISSubMetricCode NOT LIKE 'CISCMB%' AND
        Pr.ProviderID = ISNULL(@ProviderID, Pr.ProviderID)
ORDER BY M.CustomerMemberID,
        M.NameLast,
        M.NameFirst,
        M.DateOfBirth,
        Me.HEDISMeasure,
        HSM.ReportName


GO
