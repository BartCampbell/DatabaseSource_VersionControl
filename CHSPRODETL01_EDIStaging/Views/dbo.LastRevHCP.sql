SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevHCP]
AS
select *
from [dbo].[HCP] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[HCP] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
