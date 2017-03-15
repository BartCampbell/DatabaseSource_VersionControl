SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevDTP]
AS
select *
from [dbo].[DTP] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[DTP] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
