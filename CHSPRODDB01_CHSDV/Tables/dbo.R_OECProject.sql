CREATE TABLE [dbo].[R_OECProject]
(
[CentauriOECProjectID] [int] NOT NULL IDENTITY(1, 1),
[CentauriClientID] [int] NOT NULL,
[ProjectID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_R_OECProject_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL,
[OECProjectHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriOECProjectID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_OECProject] ADD CONSTRAINT [PK_R_OECProject] PRIMARY KEY CLUSTERED  ([CentauriOECProjectID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_OECProject] ADD CONSTRAINT [FK_R_OECProject_R_Client] FOREIGN KEY ([CentauriClientID]) REFERENCES [dbo].[R_Client] ([CentauriClientID])
GO
