SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [ReportPortal].[SecurityPrincipalsInherited] AS
SELECT	RSP.ADDomainName,
		RSP.ADEmail,
        RSP.ADGuid,
        RSP.ADInfo,
        RSP.ADName,
		RSP.ADPhone,
        RSP.ADSamAccountName,
        RSP.ADUserPrincipalName,
		RSP.BitNavigationTypes | RSPUG.BitNavigationTypes AS BitNavigationTypes,
        RSP.CreatedDate,
        RSP.CreatedUser,
        RSP.DomainName,
        RSP.IsEnabled,
        ISNULL(NULLIF(RSPUG.IsSysAdmin, 0), RSP.IsSysAdmin) AS IsSysAdmin,
        RSP.LastPortalLogon,
        RSP.LastUpdatedDate,
        RSP.LastUpdatedUser,
        RSP.PortalLogonCount,
        RSP.PrincipalGuid,
        RSP.PrincipalName,
        RSP.PrincipalID,
        RSP.PrincipalTypeID
FROM	ReportPortal.SecurityPrincipals AS RSP WITH(NOLOCK)
		OUTER APPLY (
						SELECT	
								MAX(tRSP.BitNavigationTypes) | MIN(tRSP.BitNavigationTypes) AS BitNavigationTypes, --Needs BitwiseOr CLR aggregate from MeasureEngine, using this as a temporary solution
								CONVERT(bit, MAX(CONVERT(tinyint, tRSP.IsSysAdmin))) AS IsSysAdmin
						FROM	ReportPortal.SecurityPrincipalUserGroups AS tRSPUG
								INNER JOIN ReportPortal.SecurityPrincipals AS tRSP
										ON tRSP.PrincipalID = tRSPUG.PrincipalID
						WHERE	tRSPUG.UserPrincipalID = RSP.PrincipalID
					) AS RSPUG
GO
