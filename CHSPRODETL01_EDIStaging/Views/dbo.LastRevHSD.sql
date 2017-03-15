SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevHSD]
AS
select *
from [dbo].[HSD] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[HSD] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
