SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevICM]
AS
select *
from [dbo].[ICM] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[ICM] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
