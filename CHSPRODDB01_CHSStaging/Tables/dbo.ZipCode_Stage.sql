CREATE TABLE [dbo].[ZipCode_Stage]
(
[ZipCodeID] [int] NOT NULL IDENTITY(1, 1),
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ZipCode_Stage] ADD CONSTRAINT [PK_ZipCode_Stage] PRIMARY KEY CLUSTERED  ([ZipCodeID]) ON [PRIMARY]
GO
