CREATE TABLE [dbo].[PursuitEventSupplementalInformation]
(
[SupplementalInfoID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEventSupplementalInformation_CreateDate] DEFAULT (getdate()),
[Character] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventSupplementalInformation] ADD CONSTRAINT [PK_PursuitEventSupplementalInformation] PRIMARY KEY CLUSTERED  ([SupplementalInfoID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventSupplementalInformation] ADD CONSTRAINT [FK_PursuitEventSupplementalInformation_PursuitEventSupplementalInformation] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
