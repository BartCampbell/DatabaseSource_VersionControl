SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[prLoadSupplementalMedicalRecordLocations]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: SupplementalMedicalRecordLocations 
from Client Import table: SupplementalMedicalRecordLocations
*/
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO SupplementalMedicalRecordLocations
        (MemberID,
         ProviderID,
         ProviderSiteID,
         SupplementalMedicalRecordPursuitTypeID,
         SupplementalMedicalRecordSpecialtyID,
         LocationPriority,
         VisitCount
			
        )
        SELECT		DISTINCT
                MemberID = b.MemberID,
                ProviderID = ISNULL(c.ProviderID,
                                    (SELECT TOP 1
                                            ProviderID
                                     FROM   Providers
                                     WHERE  CustomerProviderID = ''
                                    )),
                ProviderSiteID = ISNULL(d.ProviderSiteID,
                                        (SELECT TOP 1
                                                ProviderSiteID
                                         FROM   ProviderSite
                                         WHERE  CustomerProviderSiteID = ''
                                        )),
                SupplementalMedicalRecordPursuitTypeID = ISNULL(e.SupplementalMedicalRecordPursuitTypeID,
                                                              (SELECT TOP 1
                                                              SupplementalMedicalRecordPursuitTypeID
                                                              FROM
                                                              SupplementalMedicalRecordPursuitType
                                                              WHERE
                                                              PursuitTypeName = 'Other'
                                                              )),
                SupplementalMedicalRecordSpecialtyID = ISNULL(f.SupplementalMedicalRecordSpecialtyID,
                                                              (SELECT TOP 1
                                                              SupplementalMedicalRecordSpecialtyID
                                                              FROM
                                                              SupplementalMedicalRecordSpecialty
                                                              WHERE
                                                              SpecialtyName = 'Other'
                                                              )),
                LocationPriority = a.LocationPriority,
                VisitCount = a.VisitCount
        FROM    RDSM.SupplementalMedicalRecordLocations a
                LEFT JOIN Member b ON a.CustomerMemberID = b.CustomerMemberID AND
                                      a.ProductLine = b.ProductLine AND
                                      a.Product = b.Product
                LEFT JOIN Providers c ON a.CustomerProviderID = c.CustomerProviderID
                LEFT JOIN ProviderSite d ON a.ProviderSiteID = d.CustomerProviderSiteID
                LEFT JOIN SupplementalMedicalRecordPursuitType e ON a.PursuitType = e.PursuitTypeName
                LEFT JOIN SupplementalMedicalRecordSpecialty f ON a.PursuitProviderSpecialty = f.SpecialtyName


/*
INSERT  INTO SupplementalMedicalRecordPursuitType
        SELECT  'Other'
        UNION ALL
        SELECT  'Servicing Provider'
        UNION ALL
        SELECT  'Prior PCP' 


INSERT  INTO SupplementalMedicalRecordSpecialty
        SELECT  'Other'
        UNION ALL
        SELECT  'Urology'
        UNION ALL
        SELECT  'Primary Care'
        UNION ALL
        SELECT  'Eye Care'
        UNION ALL
        SELECT  'Ob/Gyn' 
*/
GO
