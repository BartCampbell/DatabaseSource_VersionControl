SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dv].[vwMember]
AS
     SELECT DISTINCT
          CONVERT(VARCHAR(80),v.SubscriberLastName) AS MemberLastName,
          CONVERT(VARCHAR(80),v.SubscriberFirstName) AS MemberFirstName,
          CONVERT(VARCHAR(80),v.SubscriberMiddleName) AS MemberMiddleName,
          CONVERT(VARCHAR(10),v.SubscriberNamePrefix) AS MemberNamePrefix,
          CONVERT(VARCHAR(10),v.SubscriberNameSuffix) AS MemberNameSuffix,
          CONVERT(VARCHAR(80),v.SubscriberID) AS MemberID,
          RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		i.CreatedDate AS LoadDate,
          UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(v.SubscriberID, ''))))), 2)) AS
          MemberHashKey
     FROM  dbo.vwSubscriberName AS v
           INNER JOIN dbo.Interchange AS i ON v.InterchangeID = i.Id
     WHERE v.Subscriber = 'Insured or Subscriber';

GO
