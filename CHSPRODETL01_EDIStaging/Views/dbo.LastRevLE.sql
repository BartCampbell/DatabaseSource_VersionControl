SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevLE]
AS
select *
from [dbo].[LE] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[LE] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
