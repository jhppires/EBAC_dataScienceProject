-- 
--***Criação de Tabela Transação ***
---

create table constru_bem_vendas_final(
CodCliente		int,
Categoria		varchar(50),
SuCategoria		varchar(50),
Produto			varchar(50),
Ano				int,
Mes				int,
Cidade			varchar(50),
Valor			float,
Volume			float)

select * from constru_bem_vendas_final

--Carga de dados via bulk insert, otimiza o upload de dados 

truncate table constru_bem_vendas_final

BULK INSERT constru_bem_vendas_final
	FROM 'C:\Users\pires\Downloads\constru_bem_vendas_final.csv'
	WITH
	(
	FIRSTROW =2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0X0A' --esse é o delimitador de linha do padrão do databricks
	)



create table constru_bem_potencial_final(
CodCliente			int,
Ano					int,
Area_Comercial		float,
Area_Hibrida		float,
Area_Residencial	float,
Area_Industrial		float,
ValorPotencial		float
)

DROP TABLE constru_bem_potencial_final --Deletar tabela inteira

select * from constru_bem_potencial_final

truncate table constru_bem_potencial_final

BULK INSERT constru_bem_potencial_final
	FROM 'C:\Users\pires\Downloads\constru_bem_potencial_final.csv'
	WITH
	(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0X0A' --esse é o delimitador de linha do padrão do databricks
	)


CREATE INDEX index_vendas ON constru_bem_vendas_final (CodCliente);
CREATE INDEX index_potencial ON constru_bem_potencial_final (CodCliente);

