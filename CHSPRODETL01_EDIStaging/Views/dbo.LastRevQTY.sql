SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevQTY]
AS
select *
from [dbo].[QTY] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[QTY] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
