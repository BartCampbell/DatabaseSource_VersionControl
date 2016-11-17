CREATE TABLE [dbo].[H_Location]
(
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Location_BK] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Location] ADD CONSTRAINT [PK_H_Location] PRIMARY KEY CLUSTERED  ([H_Location_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Plain Text Concantination of Address 1, Address 2, City, State, Zip, Couny, Phone and Fax. ', 'SCHEMA', N'dbo', 'TABLE', N'H_Location', 'COLUMN', N'Location_BK'
GO
