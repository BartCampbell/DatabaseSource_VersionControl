CREATE TABLE [Batch].[DataOwnerDefaults]
(
[EnrollGroupID] [int] NULL,
[InFileFormatID] [int] NULL,
[OutFileFormatID] [int] NULL,
[OwnerID] [int] NOT NULL,
[PopulationID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataOwnerDefaults] ADD CONSTRAINT [PK_DataOwnerDefaults] PRIMARY KEY CLUSTERED  ([OwnerID]) ON [PRIMARY]
GO
