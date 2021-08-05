unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.ConsoleUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.DApt, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, Rest.Json, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef;

type
  TServerMethods1 = class(TDSServerModule)
    FDConnection1: TFDConnection;
    tblEmp: TFDTable;
    tblServicos: TFDTable;
    tblServicosEMPRESA: TIntegerField;
    tblServicosID: TIntegerField;
    tblServicosCLIENTE_ID: TIntegerField;
    tblServicosVALOR: TFMTBCDField;
    tblServicosINICIO_SERVICO: TSQLTimeStampField;
    tblServicosFIM_SERVICO: TSQLTimeStampField;
    tblClientes: TFDTable;
    tblClientesEMPRESA: TIntegerField;
    tblClientesID: TIntegerField;
    tblClientesNOME: TStringField;
    tblClientesCNPJ: TStringField;
    tblClientesFONE: TStringField;
    tblClientesVEICULO_MODELO: TStringField;
    tblClientesPLACA_CARRO: TStringField;
    fdphysmysqldrvrlnk1: TFDPhysMySQLDriverLink;
    tblEmpEMPRESA: TIntegerField;
    tblEmpNOME: TStringField;
    tblEmpENDERECO: TStringField;
    tblEmpNUMERO: TStringField;
    tblEmpBAIRRO: TStringField;
    tblEmpCIDADE: TStringField;
    tblEmpUF: TStringField;
    tblEmpCOMPLEMENTO: TStringField;
    tblEmpCNPJ: TStringField;
    tblEmpCEP: TStringField;
    tblEmpFONE: TStringField;
    tblEmpCELULAR: TStringField;
    tblEmpEMAIL: TStringField;
    tblEmpPIX: TStringField;
    tblServicosNOME_SERVICO: TStringField;
    procedure FDConnection1BeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function AtualizaBD(Value: string): string;

    //Empresas
    function Empresa(cnpj : string): TJSONObject;  //GET
    function updateEmpresa(objEmpresa : TJSONObject): string; //POST
    function getNewIDEmpresa : Integer;
    function getEmpresaByCnpj(cnpj : string) : integer;

    //Clientes
    function Cliente(cpf : string): TJSONObject;  //GET
    function updateCliente(objCliente : TJSONObject): string; //POST
    function getNewIDCliente(idEmp : Integer) : Integer;
    function getClienteByCpf(cpf : string) : integer;
    function getClienteCpfByID(id : integer) : string;

    //Servi�os
    function Servico(id : string): TJSONObject;  //GET
    function updateServico(objServico : TJSONObject): string; //POST
    function getNewIDServico : Integer;

    procedure AtualizaTabelas;
    procedure criaTabelaOuAltera(tipo, nomeTabela, nomeColuna, sql: String);
    function LimpaStringNumerica(cStr: string): string;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils;

procedure TServerMethods1.AtualizaTabelas;
begin

  criaTabelaOuAltera('CREATE', 'EMPRESA', '', 'CREATE TABLE EMPRESA ( ' +
                                        '    EMPRESA     INT(11) NOT NULL AUTO_INCREMENT, ' +
                                        '    NOME        VARCHAR(255) NOT NULL, ' +
                                        '    ENDERECO    VARCHAR(255), ' +
                                        '    NUMERO      VARCHAR(10), ' +
                                        '    BAIRRO      VARCHAR(255), ' +
                                        '    CIDADE      VARCHAR(255), ' +
                                        '    UF          VARCHAR(2), ' +
                                        '    COMPLEMENTO VARCHAR(255), ' +
                                        '    CNPJ        VARCHAR(20), ' +
                                        '    CEP         VARCHAR(20), ' +
                                        '    FONE        VARCHAR(20), ' +
                                        '    CELULAR     VARCHAR(20), ' +
                                        '    EMAIL       VARCHAR(255), ' +
                                        '    PIX         VARCHAR(255), ' +
                                        '    PRIMARY KEY (EMPRESA) ' +
                                        '); '
                    );

  criaTabelaOuAltera('CREATE', 'SERVICOS', '', 'CREATE TABLE SERVICOS ( ' +
                                                 ' EMPRESA        INT(11), ' +
                                                 ' ID             INT(11) NOT NULL AUTO_INCREMENT, ' +
                                                 ' CLIENTE_ID     INTEGER, ' +
                                                 ' VALOR          DECIMAL(10,5), ' +
                                                 ' NOME_SERVICO   VARCHAR(255), ' +
                                                 ' INICIO_SERVICO TIMESTAMP DEFAULT CURRENT_TIMESTAMP, ' +
                                                 ' FIM_SERVICO    TIMESTAMP DEFAULT CURRENT_TIMESTAMP, ' +
                                                 ' PRIMARY KEY (ID) ' +
                                                 '); '
                    );

  criaTabelaOuAltera('CREATE', 'CLIENTES', '', 'CREATE TABLE CLIENTES ( ' +
                                                 ' EMPRESA        INT(11), ' +
                                                 ' ID             INT(11) NOT NULL AUTO_INCREMENT, ' +
                                                 ' NOME           VARCHAR(255), ' +
                                                 ' CNPJ           VARCHAR(20), ' +
                                                 ' FONE           VARCHAR(20), ' +
                                                 ' VEICULO_MODELO VARCHAR(255), ' +
                                                 ' PLACA_CARRO    VARCHAR(255), ' +
                                                 ' PRIMARY KEY (ID) ' +
                                                 '); '
                    );


end;

function TServerMethods1.Cliente(cpf: string): TJSONObject;
var
  jsonObject : TJSONObject;
begin

  tblClientes.Open;

  cpf := LimpaStringNumerica(cpf);

  if tblClientes.Locate('cnpj', cpf, []) then
  begin
    jsonObject := TJSONObject.Create;
    jsonObject.AddPair(TJSONPair.Create('empresa', tblClientesEMPRESA.AsString));
    jsonObject.AddPair(TJSONPair.Create('id', tblClientesID.AsString));
    jsonObject.AddPair(TJSONPair.Create('nome', tblClientesNOME.AsString));
    jsonObject.AddPair(TJSONPair.Create('cpf', tblClientesCNPJ.AsString));
    jsonObject.AddPair(TJSONPair.Create('fone', tblClientesFONE.AsString));
    jsonObject.AddPair(TJSONPair.Create('veiculo', tblClientesVEICULO_MODELO.AsString));
    jsonObject.AddPair(TJSONPair.Create('placa', tblClientesPLACA_CARRO.AsString));
    
    Result := jsonObject;
  end
  else
    Result := nil;

end;

function TServerMethods1.Empresa(cnpj: string): TJSONObject;
var
  jsonObject: TJSONObject;
begin
{
	"id": "1",
	"cnpj": "24.240.871/0001-40",
	"nome": "MERCADO ENVIOS SERVICOS DE LOGISTICA LTDA",
	"endereco": "RUA MATO GROSSO",
        "numero": "1873",
	"bairro": "CENTRO",
	"cidade": "LONDRINA",
	"uf": "PR",
	"complemento": "",
	"cep": "86010000",
	"fone": "3320-6999",
	"celular": "43 96252-6699",
	"pix": null,
	"email": null
}
  tblEmp.Open;

  cnpj := LimpaStringNumerica(cnpj);

  if tblEmp.Locate('cnpj', cnpj, []) then
  begin
    jsonObject := TJSONObject.Create;
    jsonObject.AddPair(TJSONPair.Create('id', tblEmpEMPRESA.AsString));
    jsonObject.AddPair(TJSONPair.Create('cnpj', tblEmpCNPJ.AsString));
    jsonObject.AddPair(TJSONPair.Create('nome', tblEmpNOME.AsString));
    jsonObject.AddPair(TJSONPair.Create('endereco', tblEmpENDERECO.AsString));
    jsonObject.AddPair(TJSONPair.Create('numero', tblEmpNUMERO.AsString));
    jsonObject.AddPair(TJSONPair.Create('bairro', tblEmpBAIRRO.AsString));
    jsonObject.AddPair(TJSONPair.Create('cidade', tblEmpCIDADE.AsString));
    jsonObject.AddPair(TJSONPair.Create('uf', tblEmpUF.AsString));
    jsonObject.AddPair(TJSONPair.Create('complemento', tblEmpCOMPLEMENTO.AsString));
    jsonObject.AddPair(TJSONPair.Create('cep', tblEmpCEP.AsString));
    jsonObject.AddPair(TJSONPair.Create('fone', tblEmpFONE.AsString));
    jsonObject.AddPair(TJSONPair.Create('celular', tblEmpCELULAR.AsString));
    jsonObject.AddPair(TJSONPair.Create('pix', tblEmpPIX.AsString));
    jsonObject.AddPair(TJSONPair.Create('email', tblEmpEMAIL.AsString));

    Result := jsonObject;
  end
  else
    Result := nil;

end;

procedure TServerMethods1.criaTabelaOuAltera(tipo, nomeTabela, nomeColuna,
  sql: String);
var                                                   {Exemplo:}
  sqlQuery : TFDQuery;                                {Tipo = CREATE ou ALTER}
begin                                                 {nomeTabela = Ex: BANCO}
  sqlQuery := TFDQuery.Create(nil);                   {nomeColuna = Ex: NOME}
                                                      {sql = ALTER TABLE BANCO ADD NOME VARCHAR(10)}
  try

    if tipo = 'CREATE'then
    begin

      sqlQuery.Close;
      sqlQuery.Connection := FDConnection1;
      sql := StringReplace(sql, 'CREATE TABLE', 'CREATE TABLE IF NOT EXISTS', []);
      sqlQuery.SQL.Text := sql;
      sqlQuery.ExecSQL;

    end
    else
    if tipo = 'ALTER'then
    begin
      sqlQuery.Close;
      sqlQuery.Connection := FDConnection1;
      sqlQuery.SQL.Text := sql;
      try
        sqlQuery.ExecSQL;
      except
      end;
    end;

  finally
    sqlQuery.Free;
  end;

end;

procedure TServerMethods1.FDConnection1BeforeConnect(Sender: TObject);
begin

  FDConnection1.Params.Values['database'] := 'app';
  FDConnection1.ConnectionName := 'MySQL';

end;

function TServerMethods1.getNewIDEmpresa: Integer;
var
  sqlQuery : TFDQuery;
begin
  sqlQuery := TFDQuery.Create(nil);

  sqlQuery.Close;
  sqlQuery.Connection := FDConnection1;
  sqlQuery.SQL.Text := 'SELECT MAX(EMPRESA) FROM EMPRESA';
  sqlQuery.Open;

  Result := sqlQuery.Fields[0].AsInteger + 1;
  if Result = 0 then
    Result := 1;

  sqlQuery.DisposeOf;
end;

function TServerMethods1.getNewIDServico: Integer;
var
  sqlQuery : TFDQuery;
begin

  sqlQuery.Close;
  sqlQuery.Connection := FDConnection1;
  sqlQuery.SQL.Text := 'SELECT MAX(ID) FROM SERVICOS';
  sqlQuery.Open;

  Result := sqlQuery.FieldByName('MAX').AsInteger + 1;

  sqlQuery.DisposeOf;
end;

function TServerMethods1.getClienteByCpf(cpf: string): integer;
var
  sqlQuery : TFDQuery;
begin
  cpf := LimpaStringNumerica(cpf);

  sqlQuery := TFDQuery.Create(nil);

  sqlQuery.Close;
  sqlQuery.Connection := FDConnection1;
  sqlQuery.SQL.Text := 'SELECT ID FROM CLIENTES WHERE CNPJ = ' + QuotedStr(cpf);
  sqlQuery.Open;

  Result := sqlQuery.FieldByName('ID').AsInteger;

  sqlQuery.DisposeOf;
end;

function TServerMethods1.getClienteCpfByID(id: integer): string;
var
  sqlQuery : TFDQuery;
begin

  sqlQuery.Close;
  sqlQuery.Connection := FDConnection1;
  sqlQuery.SQL.Text := 'SELECT CNPJ FROM CLIENTES WHERE ID = ' + IntToStr(id);
  sqlQuery.Open;

  Result := sqlQuery.FieldByName('CNPJ').AsString;

  sqlQuery.DisposeOf;
end;

function TServerMethods1.getEmpresaByCnpj(cnpj: string): integer;
var
  sqlQuery : TFDQuery;
begin
  cnpj := LimpaStringNumerica(cnpj);

  sqlQuery := TFDQuery.Create(nil);

  sqlQuery.Close;
  sqlQuery.Connection := FDConnection1;
  sqlQuery.SQL.Text := 'SELECT EMPRESA FROM EMPRESA WHERE CNPJ = ' + QuotedStr(cnpj);
  sqlQuery.Open;

  Result := sqlQuery.FieldByName('EMPRESA').AsInteger;

  sqlQuery.DisposeOf;
end;

function TServerMethods1.getNewIDCliente(idEmp : Integer) : Integer;
var
  sqlQuery : TFDQuery;
begin
  sqlQuery := TFDQuery.Create(nil);

  sqlQuery.Close;
  sqlQuery.Connection := FDConnection1;
  sqlQuery.SQL.Text := 'SELECT MAX(ID) FROM CLIENTES WHERE EMPRESA = ' + IntToStr(idEmp);
  sqlQuery.Open;

  Result := sqlQuery.Fields[0].AsInteger + 1;
  if Result = 0 then
    Result := 1;

  sqlQuery.DisposeOf;
end;

function TServerMethods1.AtualizaBD(Value: string): string;
begin
  //http://localhost:8080/datasnap/rest/TServerMethods1/AtualizaBD
  AtualizaTabelas;
  Result := 'OK';
end;

function TServerMethods1.updateCliente(objCliente: TJSONObject): string;
var
  cpf, cnpj : string;
begin

  try
    tblEmp.Open();
    tblClientes.Open();

    cpf := objCliente.Values['cpf'].Value;
    cpf := LimpaStringNumerica(cpf);

    if tblClientes.Locate('cnpj', cpf, []) then   //ta cnpj mas vale cpf tbm
      tblClientes.Edit
    else
      tblClientes.Insert;

    cnpj := objCliente.Values['cnpj'].Value;
    cnpj := LimpaStringNumerica(cnpj);
    tblClientesEMPRESA.AsInteger := getEmpresaByCnpj(cnpj);
    tblClientesID.AsInteger := getNewIDCliente(tblClientesEMPRESA.AsInteger);

    if objCliente.Values['nome'] <> nil  then
      tblClientesNOME.AsString := objCliente.Values['nome'].Value;
    if objCliente.Values['cpf'] <> nil  then
      tblClientesCNPJ.AsString := objCliente.Values['cpf'].Value;
    if objCliente.Values['fone'] <> nil  then
      tblClientesFONE.AsString := objCliente.Values['fone'].Value;
    if objCliente.Values['veiculo'] <> nil  then
      tblClientesVEICULO_MODELO.AsString := objCliente.Values['veiculo'].Value;
    if objCliente.Values['placa'] <> nil  then
      tblClientesPLACA_CARRO.AsString := objCliente.Values['placa'].Value;

    tblClientes.Post;
    tblClientes.ApplyUpdates(0);

  except on E : Exception do
    Result := 'Erro: ' + E.Message;
  end;


  Result := 'Sucesso';

end;

function TServerMethods1.updateEmpresa(objEmpresa : TJSONObject): string;
var
  cnpj : string;
begin
{
	"cnpj": "24.240.871/0001-40",
	"nome": "MERCADO ENVIOS SERVICOS DE LOGISTICA LTDA",
	"endereco": "RUA MATO GROSSO",
  "numero": "1873",
	"bairro": "CENTRO",
	"cidade": "LONDRINA",
	"uf": "PR",
	"complemento": "",
	"cep": "86010000",
	"fone": "3320-6999",
	"celular": "43 96252-6699",
	"pix": null,
	"email": null
}

  try
    tblEmp.Open();

    cnpj := objEmpresa.Values['cnpj'].Value;
    cnpj := LimpaStringNumerica(cnpj);

    if tblEmp.Locate('cnpj', cnpj, []) then
      tblEmp.Edit
    else
    begin
      tblEmp.Insert;
      tblEmpEMPRESA.AsInteger := getNewIDEmpresa;
    end;

    if objEmpresa.Values['cnpj'] <> nil  then
      tblEmpCNPJ.AsString := objEmpresa.Values['cnpj'].Value;
    if objEmpresa.Values['nome'] <> nil  then
      tblEmpNOME.AsString := objEmpresa.Values['nome'].Value;
    if objEmpresa.Values['endereco'] <> nil  then
      tblEmpENDERECO.AsString := objEmpresa.Values['endereco'].Value;
    if objEmpresa.Values['bairro'] <> nil  then
      tblEmpBAIRRO.AsString := objEmpresa.Values['bairro'].Value;
    if objEmpresa.Values['cidade'] <> nil  then
      tblEmpCIDADE.AsString := objEmpresa.Values['cidade'].Value;
    if objEmpresa.Values['numero'] <> nil  then
      tblEmpNUMERO.AsString := objEmpresa.Values['numero'].Value;
    if objEmpresa.Values['uf'] <> nil  then
      tblEmpUF.AsString := objEmpresa.Values['uf'].Value;
    if objEmpresa.Values['complemento'] <> nil  then
      tblEmpCOMPLEMENTO.AsString := objEmpresa.Values['complemento'].Value;
    if objEmpresa.Values['cep'] <> nil  then
      tblEmpCEP.AsString := objEmpresa.Values['cep'].Value;
    if objEmpresa.Values['fone'] <> nil  then
      tblEmpFONE.AsString := objEmpresa.Values['fone'].Value;
    if objEmpresa.Values['celular'] <> nil  then
      tblEmpCELULAR.AsString := objEmpresa.Values['celular'].Value;
    if objEmpresa.Values['pix'] <> nil  then
      tblEmpPIX.AsString := objEmpresa.Values['pix'].Value;
    if objEmpresa.Values['email'] <> nil  then
      tblEmpEMAIL.AsString := objEmpresa.Values['email'].Value;

    tblEmp.Post;
    tblEmp.ApplyUpdates(0);

  except on E : Exception do
    Result := 'Erro: ' + E.Message;
  end;


  Result := 'Sucesso';

end;

function TServerMethods1.updateServico(objServico: TJSONObject): string;
var
  id, cpf, cnpj : string;
begin

  try
    tblServicos.Open();

    cpf := objServico.Values['cpf'].Value;
    cpf := LimpaStringNumerica(cpf);

    cnpj := objServico.Values['cnpj'].Value;
    cnpj := LimpaStringNumerica(cnpj);

    if objServico.Values['id'] <> nil  then
    begin
      id := objServico.Values['id'].Value;

      if tblServicos.Locate('ID', id, []) then
        tblServicos.Edit
      else
      begin
        tblServicos.Insert;
        //tblServicosID.AsInteger := getNewIDServico;
      end;

    end
    else
    begin
      tblServicos.Insert;
      //tblServicosID.AsInteger := getNewIDServico;
    end;

    tblServicosEMPRESA.AsInteger := getEmpresaByCnpj(cnpj);
    tblServicosCLIENTE_ID.AsInteger := getClienteByCpf(cpf);

    if objServico.Values['valor'] <> nil  then
      tblServicosVALOR.AsString := objServico.Values['valor'].Value;
    if objServico.Values['nome'] <> nil  then
      tblServicosNOME_SERVICO.AsString := objServico.Values['nome'].Value;
    if objServico.Values['data_inicio'] <> nil  then
      tblServicosINICIO_SERVICO.AsString := objServico.Values['data_inicio'].Value;
    if objServico.Values['data_fim'] <> nil  then
      tblServicosFIM_SERVICO.AsString := objServico.Values['data_fim'].Value;

    tblServicos.Post;
    tblServicos.ApplyUpdates(0);

  except on E : Exception do
    Result := 'Erro: ' + E.Message;
  end;


  Result := 'Sucesso-'+tblServicosID.AsString;

end;

function TServerMethods1.Servico(id: string): TJSONObject;
var
  jsonObject : TJSONObject;
begin

  tblServicos.Open;

  if tblServicos.Locate('ID', id, []) then
  begin
    jsonObject := TJSONObject.Create;
    jsonObject.AddPair(TJSONPair.Create('empresa', tblServicosEMPRESA.AsString));
    jsonObject.AddPair(TJSONPair.Create('id', tblServicosID.AsString));
    jsonObject.AddPair(TJSONPair.Create('cpf',  getClienteCpfByID(tblServicosCLIENTE_ID.AsInteger)));
    jsonObject.AddPair(TJSONPair.Create('valor', tblServicosVALOR.AsString));
    jsonObject.AddPair(TJSONPair.Create('data_inicio', tblServicosINICIO_SERVICO.AsString));
    jsonObject.AddPair(TJSONPair.Create('data_fim', tblServicosFIM_SERVICO.AsString));

    Result := jsonObject;
  end
  else
    Result := nil;

end;
function TServerMethods1.LimpaStringNumerica(cStr: string): string;
var nC, i : integer;
    cString, cStringValida : string;
begin
  cString := '';

  cStringValida :=  '1234567890';
  for nC := 1 to length( cStr ) do
  begin
    for i := 0 to length(cStringValida) do
    begin
      if cStr[nC] = cStringValida[i] then
      begin
        cString := cString + Copy( cStr, nC, 1 );
        break;
      end;
    end;
  end;
  result := cString;
end;

end.

