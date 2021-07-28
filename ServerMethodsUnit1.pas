unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.ConsoleUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.DApt, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, Rest.Json;

type
  TServerMethods1 = class(TDSServerModule)
    FDConnection1: TFDConnection;
    tblEmp: TFDTable;
    tblServicos: TFDTable;
    tblServicosEMPRESA: TIntegerField;
    tblServicosID: TIntegerField;
    tblServicosCLIENTE_ID: TIntegerField;
    tblServicosVALOR: TFMTBCDField;
    tblServicosNOME: TWideStringField;
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
    procedure FDConnection1BeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function AtualizaBD(Value: string): string;

    //Empresas
    function Empresa(cnpj : string): TJSONObject;  //GET
    function updateEmpresa(objEmpresa : TJSONObject): string; //POST

    //Clientes
    function Cliente(cpf : string): TJSONObject;
    function updateCliente(objEmpresa : TJSONObject): string; //POST

    procedure AtualizaTabelas;
    procedure criaTabelaOuAltera(tipo, nomeTabela, nomeColuna, sql: String);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils;

procedure TServerMethods1.AtualizaTabelas;
begin

  criaTabelaOuAltera('CREATE', 'EMPRESA', '', 'CREATE TABLE EMPRESA ( ' +
                                        '    EMPRESA     INTEGER NOT NULL, ' +
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
                                                 ' EMPRESA        INTEGER, ' +
                                                 ' ID             INTEGER, ' +
                                                 ' CLIENTE_ID     INTEGER, ' +
                                                 ' VALOR          DECIMAL(10,5), ' +
                                                 ' NOME SERVICO   VARCHAR(255), ' +
                                                 ' INICIO_SERVICO TIMESTAMP, ' +
                                                 ' FIM_SERVICO    TIMESTAMP, ' +
                                                 ' PRIMARY KEY (EMPRESA, ID) ' +
                                                 '); '
                    );

  criaTabelaOuAltera('CREATE', 'CLIENTES', '', 'CREATE TABLE CLIENTES ( ' +
                                                 ' EMPRESA        INTEGER, ' +
                                                 ' ID             INTEGER, ' +
                                                 ' NOME           VARCHAR(255), ' +
                                                 ' CNPJ           VARCHAR(20), ' +
                                                 ' FONE           VARCHAR(20), ' +
                                                 ' VEICULO_MODELO VARCHAR(255), ' +
                                                 ' PLACA_CARRO    VARCHAR(255), ' +
                                                 ' PRIMARY KEY (EMPRESA, ID) ' +
                                                 '); '
                    );


end;

function TServerMethods1.Cliente(cpf: string): TJSONObject;
var
  jsonObject : TJSONObject;
begin

  tblEmp.Open;

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
  FDConnection1.Params.Values['database'] := 'db';
  FDConnection1.ConnectionName := 'SQLLite';
end;

function TServerMethods1.AtualizaBD(Value: string): string;
begin
  //http://localhost:8080/datasnap/rest/TServerMethods1/AtualizaBD
  AtualizaTabelas;
  Result := 'OK';
end;

function TServerMethods1.updateCliente(objEmpresa: TJSONObject): string;
var
  cpf : string;
begin

  try
    tblClientes.Open();

    cpf := objEmpresa.Values['cpf'].Value;
    cpf := StringReplace(cpf, '/', '', [rfReplaceAll]);
    cpf := StringReplace(cpf, '.', '', [rfReplaceAll]);
    cpf := StringReplace(cpf, '\', '', [rfReplaceAll]);
    cpf := StringReplace(cpf, '-', '', [rfReplaceAll]);

    if tblEmp.Locate('cpf', cpf, []) then
      tblEmp.Edit
    else
      tblEmp.Insert;

    if objEmpresa.Values['empresa'] <> nil  then
      tblClientesEMPRESA.AsString := objEmpresa.Values['empresa'].Value;
    if objEmpresa.Values['id'] <> nil  then
      tblClientesID.AsString := objEmpresa.Values['id'].Value;
    if objEmpresa.Values['nome'] <> nil  then
      tblClientesNOME.AsString := objEmpresa.Values['nome'].Value;
    if objEmpresa.Values['cpf'] <> nil  then
      tblClientesCNPJ.AsString := objEmpresa.Values['cpf'].Value;
    if objEmpresa.Values['fone'] <> nil  then
      tblClientesFONE.AsString := objEmpresa.Values['fone'].Value;
    if objEmpresa.Values['veiculo'] <> nil  then
      tblClientesVEICULO_MODELO.AsString := objEmpresa.Values['veiculo'].Value;
    if objEmpresa.Values['placa'] <> nil  then
      tblClientesPLACA_CARRO.AsString := objEmpresa.Values['placa'].Value;

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

  try
    tblEmp.Open();

    cnpj := objEmpresa.Values['cnpj'].Value;
    cnpj := StringReplace(cnpj, '/', '', [rfReplaceAll]);
    cnpj := StringReplace(cnpj, '.', '', [rfReplaceAll]);
    cnpj := StringReplace(cnpj, '\', '', [rfReplaceAll]);
    cnpj := StringReplace(cnpj, '-', '', [rfReplaceAll]);

    if tblEmp.Locate('cnpj', cnpj, []) then
      tblEmp.Edit
    else
      tblEmp.Insert;

    if objEmpresa.Values['id'] <> nil  then
      tblEmpEMPRESA.AsString := objEmpresa.Values['id'].Value;
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

end.
