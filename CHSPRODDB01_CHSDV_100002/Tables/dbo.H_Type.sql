CREATE TABLE [dbo].[H_Type]
(
[H_Type_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TypeCode_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Type] ADD CONSTRAINT [PK_H_Type] PRIMARY KEY CLUSTERED  ([H_Type_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
