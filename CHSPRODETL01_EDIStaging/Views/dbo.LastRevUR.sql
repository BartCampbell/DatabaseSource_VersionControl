SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevUR]
AS
select *
from [dbo].[UR] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[UR] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
