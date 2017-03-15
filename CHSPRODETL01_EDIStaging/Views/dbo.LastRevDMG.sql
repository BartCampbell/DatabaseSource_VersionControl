SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevDMG]
AS
select *
from [dbo].[DMG] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[DMG] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
