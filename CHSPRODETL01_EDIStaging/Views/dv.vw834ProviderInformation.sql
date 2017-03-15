SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dv].[vw834ProviderInformation]
AS
    SELECT DISTINCT
	    h.CentauriClientID,
	    RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
	    i.CreatedDate AS LoadDate,
	    p.CentauriProviderID AS Provider_BK, 
	    UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))))), 2)) AS H_Provider_RK,
	    UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(p.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(n.[03], ''))), ':', RTRIM(LTRIM(COALESCE(n.[04], '')))))), 2)) AS ProviderDemoHashDiff,
	    UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1), ''))), ':', RTRIM(LTRIM(COALESCE(i.CreatedDate, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(p.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(n.[03], ''))), ':', RTRIM(LTRIM(COALESCE(n.[04], '')))))), 2)) AS S_ProviderDemo_RK,
	    dbo.ufn_parsefind(REPLACE(n.[09], ' ', ':'), ':', 1) AS ProviderID,
	    UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(RIGHT(RTRIM(n.[09]),LEN(RTRIM(n.[09])) - CHARINDEX(' ',RTRIM(n.[09]))), ''))))), 2)) AS H_Network_RK,
	    CONVERT(VARCHAR(80),RIGHT(RTRIM(n.[09]),LEN(RTRIM(n.[09])) - CHARINDEX(' ',RTRIM(n.[09])))) AS NetworkID,
	    '' AS NetworkName,
	    CONVERT(VARCHAR(80),n.[03]) AS ProviderLastName,
	    CONVERT(VARCHAR(80),n.[04]) AS ProviderFirstName,
	    CONVERT(VARCHAR(80),n.[05]) AS ProviderMiddleName,
	    CONVERT(VARCHAR(10),n.[06]) AS ProviderPrefix,
	    CONVERT(VARCHAR(10),n.[07]) AS ProviderSuffix,
	    p.NPI	    
    FROM  dbo.NM1 AS n
		INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		INNER JOIN CHSDV.dbo.R_Provider p ON h.CentauriClientID = p.ClientID AND dbo.ufn_parsefind(REPLACE(n.[09], ' ', ':'), ':', 1) = p.ClientProviderID
		LEFT JOIN dbo.X12CodeList AS nx1 ON n.[01] = nx1.Code
								  AND nx1.ElementId = 98
    WHERE nx1.Definition = 'Primary Care Provider' AND n.[03] <> ''





GO
