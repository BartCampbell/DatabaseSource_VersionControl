SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevSE]
AS
select *
from [dbo].[SE] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[SE] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
