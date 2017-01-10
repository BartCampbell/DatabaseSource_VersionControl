CREATE SCHEMA [stage]
AUTHORIZATION [dbo]
GO
GRANT ALTER ON SCHEMA:: [stage] TO [ModifyTable]
GO
GRANT VIEW DEFINITION ON SCHEMA:: [stage] TO [ModifyTable]
GO
GRANT INSERT ON SCHEMA:: [stage] TO [ModifyTable]
GO
GRANT DELETE ON SCHEMA:: [stage] TO [ModifyTable]
GO
GRANT UPDATE ON SCHEMA:: [stage] TO [ModifyTable]
GO
