SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevFSA]
AS
select *
from [dbo].[FSA] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[FSA] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
