CREATE TABLE [dbo].[S_Contact]
(
[S_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL,
[EmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cell] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Contact] ADD CONSTRAINT [PK_S_Contact] PRIMARY KEY CLUSTERED  ([S_Contact_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160916-152708] ON [dbo].[S_Contact] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Contact] ADD CONSTRAINT [FK_S_Contact_H_Contact] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK])
GO
