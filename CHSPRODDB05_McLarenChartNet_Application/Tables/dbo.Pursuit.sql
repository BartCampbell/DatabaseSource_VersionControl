CREATE TABLE [dbo].[Pursuit]
(
[PursuitID] [int] NOT NULL IDENTITY(1, 1),
[PursuitNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [int] NULL,
[ProviderID] [int] NULL,
[ProviderSiteID] [int] NULL,
[AbstractorID] [int] NULL,
[AbstractionDate] [datetime] NULL,
[AppointmentID] [int] NULL,
[ReviewerID] [int] NULL,
[NoteID] [int] NULL,
[AttachmentID] [int] NULL,
[PriorityOrder] [int] NULL,
[PursuitCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Pursuit] ADD CONSTRAINT [PK_Pursuit] PRIMARY KEY CLUSTERED  ([PursuitID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Pursuit_MemberID] ON [dbo].[Pursuit] ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Pursuit_ProviderID] ON [dbo].[Pursuit] ([ProviderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Pursuit] ADD CONSTRAINT [FK_Pursuit_Abstractor] FOREIGN KEY ([AbstractorID]) REFERENCES [dbo].[Abstractor] ([AbstractorID])
GO
ALTER TABLE [dbo].[Pursuit] ADD CONSTRAINT [FK_Pursuit_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[Pursuit] ADD CONSTRAINT [FK_Pursuit_Providers] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Providers] ([ProviderID])
GO
ALTER TABLE [dbo].[Pursuit] ADD CONSTRAINT [FK_Pursuit_ProviderSite] FOREIGN KEY ([ProviderSiteID]) REFERENCES [dbo].[ProviderSite] ([ProviderSiteID])
GO
ALTER TABLE [dbo].[Pursuit] ADD CONSTRAINT [FK_Pursuit_Reviewer] FOREIGN KEY ([ReviewerID]) REFERENCES [dbo].[Reviewer] ([ReviewerID])
GO
