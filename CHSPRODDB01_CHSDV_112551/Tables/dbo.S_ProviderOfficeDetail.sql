CREATE TABLE [dbo].[S_ProviderOfficeDetail]
(
[S_ProviderOfficeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMR_Type_PK] [smallint] NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderOfficeDetail] ADD CONSTRAINT [PK_S_ProviderOfficeDetail] PRIMARY KEY CLUSTERED  ([S_ProviderOfficeDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderOfficeDetail] ADD CONSTRAINT [FK_H_ProviderOffice_RK5] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO