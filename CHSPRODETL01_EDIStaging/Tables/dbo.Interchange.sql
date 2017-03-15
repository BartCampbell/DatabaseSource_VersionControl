CREATE TABLE [dbo].[Interchange]
(
[Id] [int] NOT NULL,
[SenderId] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiverId] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[SegmentTerminator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ElementSeparator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComponentSeparator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Filename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasError] [bit] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Interchange] ADD CONSTRAINT [PK_Interchange_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
