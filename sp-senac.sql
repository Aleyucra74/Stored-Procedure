
/********* PROCEDIMENTOS   **********/
-------------------------------------------
 ---Criar procedimentos para incluir usuarios 
 ---O codigo do usuario sera definido pelo procedimento;
 ---Não sera permitido duplicidade de usuarios;
 ---A senha sera Criptografada;
  
create procedure sp_IncluirUsuarios
@nomeusuario varchar(15),
@senhausuario varchar(30),
@email varchar(30),
@nivel varchar(15)

as
Begin
Declare @codusuario int, @nome varchar(100)
 set @codusuario = (select top(1)Cod_Usuario from TbUsuarios order by Cod_Usuario desc)+1;
 
 if @codusuario is null 
	begin
		set @codusuario = 1; 
	end
	
 set @nome = (select Nome_Usuario from TbUsuarios where Nome_Usuario = @nomeusuario);
 
 if @nome is null
	begin
		insert into TbUsuarios(Cod_Usuario,Nome_Usuario,Senha_Usuario,Email_Usuario,Logado,Nivel)
                values(@codusuario,@nomeusuario,SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senhausuario)),3,999),@email,'0',@nivel) 		
	end
 
 
 
 select @codusuario as 'codigo', @nome as 'usuario';
 
 
End 
go
 	--Fazendo testes Incluindo na tabela 
	sp_IncluirUsuarios 'Gustavo','1234','gusta@gusta','Admin'
	drop procedure sp_IncluirUsuarios
	update TbUsuarios set Logado=0 where Logado = 1
select * from TbUsuarios 
insert into TbUsuarios(Cod_Usuario,Nome_Usuario,Senha_Usuario,Email_Usuario,Nivel) values ('2','Gustavo',SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', '123')),3,999),'gustavo@gustavo','Administrador')
delete from TbUsuarios where Nome_Usuario = 'Gustavo'
---------------------------------------------------------------------------

----------------------------------------------------------------------------
---criando procedimento para incluir os produtos a tabela 

create procedure sp_IncluirProdutos
@nomeproduto varchar(50),
@qntproduto int,
@precoproduto money,
@movimento varchar(7)

as
Begin
Declare @codproduto int, @codestoque int, @codpreco int, @preco int

set @codproduto = (select Cod_Produto from TbProdutos where Nome_Produto = @nomeproduto);
if @codproduto is null 
	begin
		set @codproduto = (select top(1)Cod_Produto from TbProdutos order by Cod_Produto desc)+1;
		
		if @codproduto is null 
			begin
				set @codproduto = 1; 
			end
	
	
		set @codpreco = (select top(1)Cod_Preco from TbPrecoProdutos order by Cod_Preco desc)+1;
		  
		if @codpreco is null 
			begin
				set @codpreco = 1; 
			end
	
		set @codestoque = (select top(1)Cod_Estoque from TbEstoque order by Cod_Estoque desc)+1;
		  
		if @codestoque is null 
			begin
				set @codestoque = 1; 
			end
	
	insert into TbProdutos(Cod_Produto,Nome_Produto)
                values(@codproduto,@nomeproduto);
        insert into TbPrecoProdutos(Cod_Preco,Preco_Produto,Data_Preco,Cod_Produto)
                values(@codpreco,@precoproduto,GETDATE(),@codproduto);
			insert into TbEstoque(Cod_Produto,Cod_Estoque,Quantidade_Estoque,Tipo_De_Movimento,Data_De_Movimento)
				values (@codproduto,@codestoque,@qntproduto,@movimento,GETDATE());
	
	
	
	
	end


select @codproduto as 'codigo do produto',@nomeproduto as 'Nome do produto' ,@codpreco as 'codigo do preco', @precoproduto as 'Preco do produto', @qntproduto as 'quantidade do produto', @movimento as 'tipo de movimento';
 
 
End 
go
select * from TbEstoque
 
 /*
 set @qnt = (select Nome_Produto from TbProdutos where Nome_Produto = @nomeproduto);
 set @preco = (select Preco_Produto from TbPrecoProdutos where Preco_Produto = @precoproduto);
 
 if @qnt is null and @preco is null
	begin
		
	end
 
 
 */
drop procedure sp_IncluirProdutos
 sp_IncluirProdutos 'Pizza de 3 queijos','50',27.99,'E';
	 delete from TbProdutos where Cod_Produto = 29 
---------------------------------------------------

/******** selects *********/
--select/help de todas as tabelas
select * from TbProdutos
 select * from TbPrecoProdutos
 select * from TbEstoque
 select * from TbCaixa
 select * from tbComandas
 select * from TbConta
 select * from TbProdutoComanda
 select * from TbSaldoEstoque
 select * from TbUsuarios
 -----------------------------
 sp_help TbProdutos
 sp_help TbPrecoProdutos
 sp_help TbEstoque
 sp_help TbCaixa
 sp_help tbComandas
 sp_help TbConta
 sp_help TbProdutoComanda
 sp_help TbSaldoEstoque
 sp_help TbUsuarios
 ------------------------------
 ------------------------------
	
---------------------------------------------------------	
--criando procedimento para incluir os precos para tabela

create procedure sp_IncluirPrecosProdutos
@precoproduto varchar(15),
@data datetime,
@codproduto int
as
Begin
Declare @codpreco int, @preco int
 set @codpreco = (select top(1)Cod_Preco from TbPrecoProdutos order by Cod_Preco desc)+1;
 
 if @codpreco is null 
	begin
		set @codpreco = 1; 
	end
	
 set @preco = (select Preco_Produto from TbPrecoProdutos where Preco_Produto = @precoproduto);
 
 if @preco is null
	begin
		insert into TbPrecoProdutos(Cod_Preco,Preco_Produto,Data_Preco,Cod_Produto)
                values(@codpreco,@precoproduto,GETDATE(),@codproduto) 		
	end
 
 
 
 select @codpreco as 'codigo do preco',@precoproduto as 'Preco do produto';
 
 
End 
go
drop procedure sp_IncluirPrecosProdutos
select * from TbPrecoProdutos
 sp_IncluirPrecosProdutos '1','','2';
--------------------------------------------------------------------
 
 ---------------------------------------------------------------------
 --validar o usuario
--para que seja reconhecido no sistema
create procedure sp_VerificarUsuario
@nomeusuario varchar(15),
@senhausuario varchar(30)

as 
Begin
	Declare 
		@logado int, @nivel varchar(15)
		set @logado =( select COUNT(*) from TbUsuarios
			where Nome_Usuario = @nomeusuario and 
				  Senha_Usuario = SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senhausuario)),3,999)
				      );
	
	if(@logado =0)
		begin
			set @logado =2;
		end
	else
		begin
			set @logado =( select COUNT(*) from TbUsuarios
			where Nome_Usuario = @nomeusuario and Logado='1' and
				  Senha_Usuario = SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senhausuario)),3,999)
				      );
			
			if(@logado =1)
				begin
					set @logado =3;
				end
			else
				begin
					set @logado=4;
				end
			
		end
		set @nivel =( select Nivel from TbUsuarios
		where Nome_Usuario = @nomeusuario and 
			  Senha_Usuario = SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senhausuario)),3,999)
			      );				      
	select @logado as 'Logado', @nomeusuario as 'NomeUsuario', @nivel as 'Nivel'

	if(@logado=4)
		begin
			update TbUsuarios 
				set Logado='1' 
					where Nome_Usuario = @nomeusuario and 
					Senha_Usuario = SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senhausuario)),3,999);
		end
	


End
GO
sp_VerificarUsuario 'Gustavo','1623'
select * from TbUsuarios
delete from TbUsuarios where Cod_Usuario = 3
update tbUsuarios set Logado=0 where Logado=1
drop procedure sp_VerificarUsuario
-----------------------------------------------------------

-------------------------------------------------------------
--procedure para pegar o nivel

CREATE PROCEDURE sp_ConsultaUsuario
@nomeusuario varchar(100)

AS
BEGIN
	DECLARE
		@ID int,
		@Usuario varchar(100),
		@Nivel varchar(15)
		SET @ID = (select Cod_Usuario from TbUsuarios where Nome_Usuario = @nomeusuario)
		SET @Usuario = (select Nome_Usuario from TbUsuarios where Nome_Usuario = @nomeusuario)
		SET @nivel = (select Nivel from TbUsuarios where Nome_Usuario = @nomeusuario)
		
	
	SELECT @Nivel as 'Nivel',@ID as 'ID',@Usuario as 'Usuário'
	
	
END
GO
drop procedure 
sp_ConsultaUsuario 'Gustavo'
---------------------------------------------------------------

-----------------------------------------------------------------
-- codproduto, nome produto, preco, qnt do estoque, movimento
--SELECT Orders.OrderID, Customers.CustomerName, Shippers.ShipperName
--FROM ((Orders
--INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID)
--INNER JOIN Shippers ON Orders.ShipperID = Shippers.ShipperID); 
SELECT TbProdutos.Cod_Produto, TbProdutos.Nome_Produto, TbPrecoProdutos.Preco_Produto, TbEstoque.Quantidade_Estoque, TbEstoque.Tipo_De_Movimento FROM TbProdutos 
	INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Produto = TbProdutos.Cod_Produto
	INNER JOIN TbEstoque ON TbEstoque.Cod_Produto = TbPrecoProdutos.Cod_Produto ORDER BY TbProdutos.Cod_Produto;
	
SELECT TbProdutos.Cod_Produto, TbProdutos.Nome_Produto, TbPrecoProdutos.Preco_Produto, TbPrecoProdutos.Data_Preco, TbEstoque.Tipo_De_Movimento, TbEstoque.Data_De_Movimento FROM TbProdutos
	INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Produto = TbProdutos.Cod_Produto
	INNER JOIN TbEstoque ON TbEstoque.Cod_Produto = TbPrecoProdutos.Cod_Produto order by TbEstoque.Data_De_Movimento;
	---------------------------------------------------------------------------
	
-------------------------------------------------------------------
--procedimento para consultar o historico
create procedure sp_ConsultarHistorico
@datainicio datetime,
@datafim datetime

as
Begin
	SELECT TbProdutos.Cod_Produto, TbProdutos.Nome_Produto, TbPrecoProdutos.Preco_Produto, TbPrecoProdutos.Data_Preco, TbEstoque.Tipo_De_Movimento, TbEstoque.Data_De_Movimento FROM TbProdutos
		INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Produto = TbProdutos.Cod_Produto
		INNER JOIN TbEstoque ON TbEstoque.Cod_Produto = TbPrecoProdutos.Cod_Produto where TbPrecoProdutos.Data_Preco > @datainicio and TbPrecoProdutos.Data_Preco < @datafim order by TbPrecoProdutos.Data_Preco;
End 
go

drop procedure
sp_ConsultarHistorico '26/08/2019', '03/09/2019' 
--, TbEstoque.Tipo_De_Movimento, TbEstoque.Data_De_Movimento 
---------------------------------------------------------------------

-----------------------------------------------
select * from TbPrecoProdutos
SELECT TbProdutos.Cod_Produto, TbProdutos.Nome_Produto, TbPrecoProdutos.Preco_Produto, TbPrecoProdutos.Data_Preco, TbEstoque.Tipo_De_Movimento, TbEstoque.Data_De_Movimento FROM TbProdutos 
		INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Produto = TbProdutos.Cod_Produto
		INNER JOIN TbEstoque ON TbEstoque.Cod_Produto = TbPrecoProdutos.Cod_Produto where TbPrecoProdutos.Data_Preco between 2019/08/22 and 2019/08/26 order by TbPrecoProdutos.Data_Preco;
		
select * from TbPrecoProdutos where Data_preco  between 2019/08/22 and 2019/08/26 order by Data_Preco;
select * from TbEstoque
select * 
from TbPrecoProdutos
where Data_preco  > '26/08/2019' and Data_Preco < '03/09/2019'
-----------------------------------------------------------------------

----------------
SELECT TbProdutos.Cod_Produto, TbProdutos.Nome_Produto, TbPrecoProdutos.Preco_Produto, TbPrecoProdutos.Data_Preco, TbEstoque.Tipo_De_Movimento, TbEstoque.Data_De_Movimento FROM TbProdutos
		INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Produto = TbProdutos.Cod_Produto
		INNER JOIN TbEstoque ON TbEstoque.Cod_Produto = TbPrecoProdutos.Cod_Produto where TbEstoque.Data_De_Movimento > '09/09/2019' and TbEstoque.Data_De_Movimento < '11/09/2019' order by TbEstoque.Tipo_De_Movimento;
--------------------nome e unidade
SELECT TbProdutos.Nome_Produto, TbEstoque.Quantidade_Estoque FROM TbProdutos
		INNER JOIN TbEstoque ON TbProdutos.Cod_Produto = TbEstoque.Cod_Estoque
-----------------------
UPDATE TbProdutos SET TbProdutos.Nome_Produto = 'Bolo de Chocolate', TbPrecoProdutos.Preco_Produto = 12 , TbEstoque.Quantidade_Estoque = '45' FROM TbProdutos
	INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Produto = TbProdutos.Cod_Produto
	INNER JOIN TbEstoque ON TbEstoque.Cod_Produto = TbPrecoProdutos.Cod_Produto
		WHERE TbProdutos.Cod_Produto = 56
-------------------------

---------------------------------------------------
--procedimento para o logout do usuario
--Stored Procedure sp_LogoutUsuario

CREATE PROCEDURE sp_LogoutUsuario
@nomeusuario varchar(100)

AS
BEGIN
	
	UPDATE TbUsuarios	
			SET Logado = '0'
			WHERE Nome_Usuario = @nomeusuario 
	
END
GO

exec sp_LogoutUsuario 'Gustavo' 
----------------------------------------------------

select * from TbUsuarios
select * from TbPrecoProdutos where Nome_Produto like '%Chocolate'
drop procedure sp_LogoutUsuario
sp_help TbPrecoProdutos

-----------------------------------------------------
--procedimento para editar o produto
create procedure sp_EditarProduto
/*@nomeproduto varchar(50),*/
/*@qntproduto int,*/
@precoproduto money,
/*@movimento varchar(7),*/
@codproduto int

as
Begin
Declare /*@codestoque int,*/ @codpreco int, @preco int

/*set @codproduto = (select Cod_Produto from TbProdutos where Nome_Produto = @nomeproduto);
if @codproduto is null 
	begin
		set @codproduto = (select top(1)Cod_Produto from TbProdutos order by Cod_Produto desc)+1;
		
		if @codproduto is null 
			begin
				set @codproduto = 1; 
			end*/
	
	
		set @codpreco = (select top(1)Cod_Preco from TbPrecoProdutos order by Cod_Preco desc)+1;
		  
		if @codpreco is null 
			begin
				set @codpreco = 1; 
			end
	
		/*set @codestoque = (select top(1)Cod_Estoque from TbEstoque order by Cod_Estoque desc)+1;
		  
		if @codestoque is null 
			begin
				set @codestoque = 1; 
			end*/
	
	/*insert into TbProdutos(Cod_Produto,Nome_Produto)
                values(@codproduto,@nomeproduto);*/
        insert into TbPrecoProdutos(Cod_Preco,Preco_Produto,Data_Preco,Cod_Produto)
                values(@codpreco,@precoproduto,GETDATE(),@codproduto);
			/*insert into TbEstoque(Cod_Produto,Cod_Estoque,Quantidade_Estoque,Tipo_De_Movimento,Data_De_Movimento)
				values (@codproduto,@codestoque,@qntproduto,@movimento,GETDATE());*/
	
select @codpreco as 'codigo do preco', @precoproduto as 'Preco do produto', @codproduto as 'codigo'
End
go
drop procedure
sp_EditarProduto 11.00 ,56
----------------------------------------------------------------

----------------------------------------------------------------
--procedimento para ativar o status da comanda

create procedure sp_AtivarComanda
@codigo int

as 
Begin
	Declare @codigoC int, @status int, @codconta int
	
		set @status = (select Status from tbComandas where Cod_Comanda = @codigo);
		set @codigoC = (select Cod_Comanda from  tbComandas where Cod_Comanda = @codigo);
		set @codconta = (select top(1)Cod_Conta from TbConta order by Cod_Conta desc)+1;
		
			
		 if @codconta is null 
			begin
				set @codconta = 1; 	
			end	
				
		if(@status=0)
			begin
				update tbComandas 
					set status=1 
						where Cod_Comanda = @codigoC;
			end

		insert into TbConta(Cod_Conta,Cod_Comanda,Data_Conta)
			values(@codconta,@codigoC,GETDATE());	
		
select @codigoC as 'cod comanda', @codconta as 'codconta'
End
GO
select status from tbComandas where Cod_Comanda = 1
drop procedure
sp_AtivarComanda 99
select * from tbComandas
---------------------------------------------------------------
--ctrl+k+d para identar no visual studio
---------------------------------------------------------------
-- procedimento para puxar os dados e fazer as contas
/* cod// produto // preco // X qntd */
create procedure sp_InserirProdutosComanda
@codigo int,
@quantidade int,
@produto varchar(50)

as 
Begin
	declare @qntd int, @cod int, @codconta int, @status int, @codproduto int, @codpreco decimal
	set @cod = (select Cod_Comanda from tbComandas where Cod_Comanda = @codigo);
	set @codproduto = (select Cod_Produto from TbProdutos where Nome_Produto = @produto);
	set @codpreco = (select top(1)Preco_Produto from TbPrecoProdutos where Cod_Produto = @codproduto order by Data_Preco desc);
	set @status = (select Status from tbComandas where Cod_Comanda = @codigo);
	set @codconta = (select top(1)Cod_Conta from TbConta where Cod_Comanda = @cod order by Cod_Conta desc);
 
	
	
	if(@status=1)
		begin
			insert into TbProdutoComanda(Cod_Produto,Cod_Preco,Cod_Conta,Quantidade,status)
				values(@codproduto,@codpreco,@codconta,@quantidade,1);
		end
	select @produto as 'produto', @codproduto as 'codP', @codpreco as 'preco'
end
go
drop procedure			/* cmd // qnt // nomeP*/
sp_InserirProdutosComanda 99,11,'Pão de metro Italiano'
--ERRO, COMO SABER SE UMA CONTA JA FOI DESATIVADA E A COMANDA FOR ATIVAR NOVAMENTE
select * from TbProdutoComanda
select * from TbConta
-------------------------------------------------------------

-------------------------------------------------------------

--Procedimento para consultar os produtos na comanda ativa
create procedure sp_ConsultarProdutosComanda
@codigo int /* cod comanda*/
as
Begin
	declare @status int, @codconta int
	--set @codcomanda = (select Cod_Comanda from tbComandas where Cod_Comanda = @codigo);
	set @status = (select Status from tbComandas where Cod_Comanda = @codigo);
	set @codconta = (select top(1)Cod_Conta from TbConta where Cod_Comanda = @codigo order by Cod_Conta desc);

	if(@status=1)
		begin
			select TbProdutos.Cod_Produto, TbProdutos.Nome_Produto, TbPrecoProdutos.Preco_Produto, TbConta.Cod_conta, Quantidade from TbProdutoComanda
				INNER JOIN TbProdutos ON TbProdutos.Cod_Produto = TbProdutoComanda.Cod_Produto
				INNER JOIN TbPrecoProdutos ON TbPrecoProdutos.Cod_Preco = TbProdutoComanda.Cod_Preco
				INNER JOIN TbConta ON TbConta.Cod_Conta = TbProdutoComanda.Cod_Conta
					where TbProdutoComanda.Cod_Conta = @codconta			 
		end
	
End
Go
drop procedure
sp_ConsultarProdutosComanda 99






-----------------------------------------------------------------

-----------------------------------------------------------------

--Procedimento para finalizar a comanda
create procedure sp_FinalizaComanda
@codusuario int,
@codcomanda int,
@pagamento varchar(15)

as
Begin
	Declare @codU int, @codC int, @status int, @codCMD int
	set @codU = (select Cod_Usuario from TbUsuarios where Cod_Usuario = @codusuario);
	set @codC = (select top(1)Cod_Conta from TbConta where Cod_Comanda=@codcomanda order by Data_Conta desc);
	set @status = (select Status from tbComandas where Cod_Comanda = @codcomanda);
	set @codCMD = (select Cod_Comanda from tbComandas where Cod_Comanda = @codcomanda);
		
	
	if(@status=1)
			begin
				update tbComandas
					set status=0 
						where Cod_Comanda = @codCMD;
				update TbProdutoComanda 
					set status=0
						where Cod_Conta=@codC;
				insert into TbCaixa(Cod_Usuario,Cod_Conta,Data_Caixa,Forma_Pagamento)
					values(@codU,@codC,GETDATE(),@pagamento);
			
			end
	select @codU as 'usuario', @codC as 'codconta', @codCMD as 'codcomanda', @pagamento as 'pagamento'
End
Go
drop procedure    /*user //cmd // pag  */
sp_FinalizaComanda 2,99,'VR'
