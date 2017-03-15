SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCUR]
AS
select *
from [dbo].[CUR] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CUR] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
