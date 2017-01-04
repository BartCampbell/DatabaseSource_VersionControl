CREATE TABLE [ref].[ICDVersion]
(
[ICDVersionID] [int] NOT NULL IDENTITY(1, 1),
[ICDVersionCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICDVersion] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[ICDVersion] ADD CONSTRAINT [PK_ICDVersion] PRIMARY KEY CLUSTERED  ([ICDVersionID]) ON [PRIMARY]
GO
