CREATE TABLE [Qarr].[CountyReferenceNumbers]
(
[County] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RefNbr] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RefYear] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Qarr].[CountyReferenceNumbers] ADD CONSTRAINT [PK_CountyReferenceNumbers] PRIMARY KEY CLUSTERED  ([County], [RefYear]) ON [PRIMARY]
GO
