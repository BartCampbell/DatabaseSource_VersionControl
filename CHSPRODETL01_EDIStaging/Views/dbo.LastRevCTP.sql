SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCTP]
AS
select *
from [dbo].[CTP] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CTP] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
