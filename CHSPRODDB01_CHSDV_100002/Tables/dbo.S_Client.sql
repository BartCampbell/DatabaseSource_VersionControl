CREATE TABLE [dbo].[S_Client]
(
[S_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FederalTaxID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Client] ADD CONSTRAINT [PK_S_Client] PRIMARY KEY CLUSTERED  ([S_Client_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Client] ADD CONSTRAINT [FK_S_Client_H_Client] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK])
GO
