CREATE TABLE [ref].[ValueCode]
(
[ValueCodeID] [int] NOT NULL IDENTITY(1, 1),
[ValueCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueCodeDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[ValueCode] ADD CONSTRAINT [PK_ValueCode] PRIMARY KEY CLUSTERED  ([ValueCodeID]) ON [PRIMARY]
GO
