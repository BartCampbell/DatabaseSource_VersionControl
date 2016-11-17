SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dv].[HEDIS_Member]
AS
     SELECT
          i.HEDIS_ImportID,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.Client_BK,''))),':',RTRIM(LTRIM(COALESCE(i.PRODUCT_ROLLUP_ID,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,'')))))),2)) AS H_HEDIS_RK,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))))), 2)) AS H_Member_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))))), 2)) AS H_Provider_RK,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriProviderID, '')))))), 2)) AS L_MemberProvider_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.Client_BK,''))),':',RTRIM(LTRIM(COALESCE(i.PRODUCT_ROLLUP_ID,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,'')))))),2)) AS L_MemberHEDIS_RK,
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(i.[PHO ID],''))),':',RTRIM(LTRIM(COALESCE(i.[PHO Name],'')))))),2)) AS H_Network_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(c.Client_BK, '')))))), 2)) AS L_MemberClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(c.Client_BK, ''))), ':', RTRIM(LTRIM(COALESCE(i.MEM_NBR, '')))))), 2)) AS LS_MemberClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(i.MEM_NBR, ''))))), 2)) AS MemberClientHashDiff,
          c.Client_BK,
          c.H_Client_RK,
          m.CentauriMemberID AS Member_BK,
		p.CentauriProviderID AS Provider_BK,
          i.MEM_NBR AS ClientMemberID,
          i.RecordSource,
          i.LoadDate
     FROM stage.HEDIS_Import AS i
          INNER JOIN CHSDV.dbo.H_Client AS c ON dbo.ufn_parsefind(REPLACE(i.RecordSource, '_', ':'), ':', 1) = c.
          ClientName
          INNER JOIN CHSDV.dbo.R_Member AS m ON c.Client_BK = m.ClientID
                                                    AND i.MEM_NBR = m.ClientMemberID
		LEFT JOIN CHSDV.dbo.R_Provider AS p ON c.Client_BK = p.ClientID
                                                      AND i.[PCP ID] = p.ClientProviderID
GO
