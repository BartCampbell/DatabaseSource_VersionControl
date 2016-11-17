CREATE TABLE [dbo].[R_CodedData]
(
[CentauriCodedDataID] [int] NOT NULL IDENTITY(101, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientCodedDataID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedDataHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriCodedDataID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_CodedData] ADD CONSTRAINT [PK_R_CodedData] PRIMARY KEY CLUSTERED  ([CentauriCodedDataID]) ON [PRIMARY]
GO
