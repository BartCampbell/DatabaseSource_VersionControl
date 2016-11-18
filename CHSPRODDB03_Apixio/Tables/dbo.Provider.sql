CREATE TABLE [dbo].[Provider]
(
[Prov_NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[First_Name] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Last_Name] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CentauriProviderID] [bigint] NOT NULL,
[Taxonomy] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Date_Refreshed] [datetime] NOT NULL,
[Date_Retreived] [datetime] NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Provider] ADD CONSTRAINT [PK_Provider_RecID] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
