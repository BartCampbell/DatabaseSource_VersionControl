SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dv].[HEDIS_Provider]
AS
     SELECT
          i.HEDIS_ImportID,
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.Client_BK,''))),':',RTRIM(LTRIM(COALESCE(i.[PRODUCT_ROLLUP_ID],''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,'')))))),2)) AS [H_HEDIS_RK],
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))))), 2)) AS H_Provider_RK,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(i.[PHO ID], ''))), ':', RTRIM(LTRIM(COALESCE(c.Client_BK, '')))))), 2)) AS L_ProviderNetworkClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.Client_BK,''))),':',RTRIM(LTRIM(COALESCE(i.PRODUCT_ROLLUP_ID,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(p.CentauriProviderID,'')))))),2)) AS L_ProviderHEDIS_RK,
          c.Client_BK,
          c.H_Client_RK,
          p.CentauriProviderID AS Provider_BK,
          i.RecordSource,
          i.LoadDate,
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(i.[PHO ID],''))),':',RTRIM(LTRIM(COALESCE(i.[PHO Name],'')))))),2)) AS H_Network_RK,
          i.[PHO ID],
          i.[PHO Name],
          i.[PCP Name],
		dbo.ufn_parsefind(REPLACE(i.[PCP Name],', ',':'),':',1) AS ProviderLastName,
		dbo.ufn_parsefind(REPLACE(i.[PCP Name],', ',':'),':',2) AS ProviderFirstName,
          i.[PCP ID],
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.[PCP Name],', ',':'),':',1), ''))), ':', RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.[PCP Name],', ',':'),':',2), '')))))), 2)) AS S_ProviderDemo_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.[PCP Name],', ',':'),':',1), ''))), ':', RTRIM(LTRIM(COALESCE(dbo.ufn_parsefind(REPLACE(i.[PCP Name],', ',':'),':',2), '')))))), 2)) AS ProviderDemoHashDiff,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(i.[PHO ID], ''))), ':', RTRIM(LTRIM(COALESCE(c.Client_BK, ''))), ':', RTRIM(LTRIM(COALESCE(i.[PCP ID], '')))))), 2)) AS LS_ProviderNetworkClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(i.[PCP ID], ''))))), 2)) AS ProviderNetworkClientHashDiff
     FROM stage.HEDIS_Import AS i
          INNER JOIN CHSDV.dbo.H_Client AS c ON dbo.ufn_parsefind(REPLACE(i.RecordSource, '_', ':'), ':', 1) = c.ClientName
          INNER JOIN CHSDV.dbo.R_Provider AS p ON c.Client_BK = p.ClientID
                                                      AND i.[PCP ID] = p.ClientProviderID
		LEFT JOIN CHSDV.dbo.R_Member AS m ON c.Client_BK = m.ClientID
                                                    AND i.MEM_NBR = m.ClientMemberID										    ;
GO
