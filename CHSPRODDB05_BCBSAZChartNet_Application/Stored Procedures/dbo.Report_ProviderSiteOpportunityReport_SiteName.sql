SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Report_ProviderSiteOpportunityReport_SiteName]
    @ProviderSiteName varchar(75) = NULL
AS 
SELECT	DISTINCT
        PS.ProviderSiteName AS 'NameEntityFullName',		--Report Header
        PS.Phone,					--Report Header
        M.CustomerMemberID,			--Report Body
        M.NameLast,					--Report Body
        M.NameFirst,				--Report Body
        M.DateOfBirth,				--Report Body
        Me.HEDISMeasure,			--Report Body
        HSM.HEDISSubMetricDescription,	--Report Body
        AbstractionStatus = ASTAT.Description,
        AbstractorName,
        PS.CustomerProviderSiteID AS 'CustomerProviderID',
        PS.ProviderSiteID AS 'ProviderID'
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
        PS.ProviderSiteName = ISNULL(@ProviderSiteName, PS.ProviderSiteName)
ORDER BY M.NameLast,
        M.NameFirst,
        M.DateOfBirth,
        Me.HEDISMeasure,
        HSM.HEDISSubMetricDescription

GO
