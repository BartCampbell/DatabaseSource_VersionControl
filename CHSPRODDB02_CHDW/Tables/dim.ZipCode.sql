CREATE TABLE [dim].[ZipCode]
(
[ZipCodeID] [int] NOT NULL IDENTITY(1, 1),
[CentauriZipCodeID] [int] NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ZipCode_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ZipCode_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ZipCode] ADD CONSTRAINT [PK_ZipCode] PRIMARY KEY CLUSTERED  ([ZipCodeID]) ON [PRIMARY]
GO
