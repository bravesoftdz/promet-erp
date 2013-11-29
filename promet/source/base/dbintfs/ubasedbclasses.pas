{*******************************************************************************
  Copyright (C) Christian Ulrich info@cu-tec.de

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or commercial alternative
  contact us for more information

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
Created 01.06.2006
*******************************************************************************}
unit uBaseDbClasses;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, db, uBaseDbDataSet, Variants, uIntfStrConsts, DOM,
  Contnrs,LCLProc;
type
  TBaseDBDataset = class(TComponent)
  private
    fChanged: Boolean;
    FDataSet: TDataSet;
    FDisplayLabelsWasSet : Boolean;
    FDataModule : TComponent;
    FOnChanged: TNotifyEvent;
    FOnRemoved: TNotifyEvent;
    FParent: TBaseDbDataSet;
    FUpdateFloatFields: Boolean;
    FSecModified: Boolean;
    FDoChange:Integer;
    FUseIntegrity : Boolean;
    function GetCanEdit: Boolean;
    function GetCaption: string;
    function GetConnection: TComponent;
    function GetCount: Integer;
    function GetFullCount: Integer;
    function GetID: TField;
    function GetState: TDataSetState;
    function GetTimestamp: TField;
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aUseIntegrity : Boolean;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);virtual;
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);virtual;
    destructor Destroy;override;
    property DataSet : TDataSet read FDataSet write FDataSet;
    property DataModule : TComponent read FDataModule;
    procedure Open;virtual;
    function CreateTable : Boolean;virtual;
    procedure DefineFields(aDataSet : TDataSet);virtual;abstract;
    procedure DefineDefaultFields(aDataSet : TDataSet;HasMasterSource : Boolean);
    procedure DefineUserFields(aDataSet: TDataSet);
    procedure FillDefaults(aDataSet : TDataSet);virtual;
    procedure Select(aID : Variant);virtual;
    procedure SetDisplayLabelName(aDataSet: TDataSet;aField, aName: string);
    procedure SetDisplayLabels(aDataSet : TDataSet);virtual;
    property Id : TField read GetID;
    property TimeStamp : TField read GetTimestamp;
    property Count : Integer read GetCount;
    property FullCount : Integer read GetFullCount;
    function GetBookmark : LargeInt;
    function GotoBookmark(aRec : Variant) : Boolean;
    procedure FreeBookmark(aRec : Variant);
    procedure DuplicateRecord(DoPost : Boolean = False);
    property Connection : TComponent read GetConnection;
    property State : TDataSetState read GetState;
    property Caption : string read GetCaption;
    property Changed : Boolean read FChanged;
    procedure DisableChanges;
    procedure EnableChanges;
    procedure Change;virtual;
    procedure UnChange;virtual;
    procedure CascadicPost;virtual;
    procedure CascadicCancel;virtual;
    procedure Delete;virtual;
    procedure Insert;virtual;
    procedure Append;virtual;
    procedure First;virtual;
    procedure Next;virtual;
    procedure Prior;virtual;
    procedure Post;virtual;
    function EOF : Boolean;
    function FieldByName(aFieldName : string) : TField;
    procedure Assign(Source: TPersistent); override;
    procedure DirectAssign(Source : TPersistent);
    property Parent : TBaseDbDataSet read FParent;
    property UpdateFloatFields : Boolean read FUpdateFloatFields write FUpdateFloatFields;
    property CanEdit : Boolean read GetCanEdit;
    property OnChange : TNotifyEvent read FOnChanged write FOnChanged;
    property OnRemove : TNotifyEvent read FOnRemoved write FOnRemoved;
  end;
  TReplaceFieldFunc = procedure(aField : TField;aOldValue : string;var aNewValue : string);
  TBaseDbList = class(TBaseDBDataSet)
  private
    function GetBookNumber: TField;
    function GetMatchcode: TField;
    function GetBarcode: TField;
    function GetCommission: TField;
    function GetDescription: TField;
    function GetStatus: TField;
    function GetText: TField;
    function GetNumber : TField;
  protected
    FStatusCache: TStringList;
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy; override;
    function GetStatusIcon : Integer;virtual;
    function GetTyp: string;virtual;
    function GetMatchcodeFieldName: string;virtual;
    function GetBarcodeFieldName: string;virtual;
    function GetCommissionFieldName: string;virtual;
    function GetDescriptionFieldName: string;virtual;
    function GetStatusFieldName: string;virtual;
    function GetTextFieldName: string;virtual;abstract;
    function GetNumberFieldName : string;virtual;abstract;
    function GetBookNumberFieldName : string;virtual;
    function Find(aIdent : string;Unsharp : Boolean = False) : Boolean;virtual;
    function  ExportToXML : string;virtual;
    procedure ImportFromXML(XML : string;OverrideFields : Boolean = False;ReplaceFieldFunc : TReplaceFieldFunc = nil);virtual;
//    function  TableToXML(Doc : TXMLDocument;iDataSet : TDataSet) : TDOMElement;
//    function  XMLToTable(iDataSet : TDataSet;Node : TDOMElement) : Boolean;
    property Text : TField read GetText;
    property Number : TField read GetNumber;
    property BookNumber : TField read GetBookNumber;
    property Barcode : TField read GetBarcode;
    property Description : TField read GetDescription;
    property Commission : TField read GetCommission;
    property Status : TField read GetStatus;
    property Typ : string read GetTyp;
    property Matchcode : TField read GetMatchcode;
    procedure SelectFromLink(aLink : string);virtual;
  end;
  TBaseDBDatasetClass = class of TBaseDBDataset;
  TBaseDBListClass = class of TBaseDBList;
  TBaseHistory = class(TBaseDBList)
  private
    FHChanged: Boolean;
    FShouldChange : Boolean;
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    procedure SetDisplayLabels(aDataSet: TDataSet); override;
    property ChangedDuringSession : Boolean read FHChanged write FHChanged;
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure Change; override;
    function AddItem(aObject: TDataSet; aAction: string; aLink: string='';
      aReference: string=''; aRefObject: TDataSet=nil; aIcon: Integer=0;
  aComission: string=''; CheckDouble: Boolean=True; DoPost: Boolean=True;
  DoChange: Boolean=False) : Boolean; virtual;
    procedure AddParentedItem(aObject: TDataSet; aAction: string;aParent : Variant; aLink: string='';
      aReference: string=''; aRefObject: TDataSet=nil; aIcon: Integer=0;
  aComission: string=''; CheckDouble: Boolean=True; DoPost: Boolean=True;
  DoChange: Boolean=False); virtual;
    procedure AddItemWithoutUser(aObject : TDataSet;aAction : string;aLink : string = '';aReference : string = '';aRefObject : TDataSet = nil;aIcon : Integer = 0;aComission : string = '';CheckDouble: Boolean=True;DoPost : Boolean = True;DoChange : Boolean = False);virtual;
    function GetTextFieldName: string;override;
    function GetNumberFieldName : string;override;
  end;
  IBaseHistory = interface['{8BA16E96-1A06-49E2-88B1-301CF9E5C8FC}']
    function GetHistory: TBaseHistory;
    property History : TBaseHistory read GetHistory;
  end;
  TOptions = class;
  TFollowers = class;
  TRights = class;

  { TUser }

  TUser = class(TBaseDbList,IBaseHistory)
  private
    FFollows: TFollowers;
    FOptions: TOptions;
    FRights: TRights;
    FHistory: TBaseHistory;
    function GetLeaved: TField;
    function GetPasswort: TField;
    function GetSalt: TField;
    function GetUser: TField;
    function GetTextFieldName: string;override;
    function GetNumberFieldName : string;override;
    function GetWorktime: Extended;
    function MergeSalt(apasswort,aSalt : string) : string;
    function GetHistory: TBaseHistory;
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    procedure Open; override;
    function GetTyp: string; override;
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure FillDefaults(aDataSet : TDataSet);override;
    procedure SelectByParent(aParent : Variant);
    function CreateTable : Boolean;override;
    property UserName : TField read GetUser;
    property Leaved : TField read GetLeaved;
    property Passwort : TField read GetPasswort;
    property Salt : TField read GetSalt;
    property Rights : TRights read FRights;
    property Options : TOptions read FOptions;
    property Follows : TFollowers read FFollows;
    procedure SetPasswort(aPasswort : string);
    function GetRandomSalt : string;
    function CheckPasswort(aPasswort : string) : Boolean;
    function CheckSHA1Passwort(aPasswort : string) : Boolean;
    procedure SelectByAccountno(aAccountno : string);virtual;
    property History : TBaseHistory read FHistory;
    property WorkTime : Extended read GetWorktime;
  end;
  TActiveUsers = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TUserfielddefs = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TNumbersets = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    function GetNewNumber(Numberset : string) : string;
    function HasNumberSet(Numberset : string) : Boolean;
  end;

  { TPayGroups }

  TPayGroups = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TMandantDetails = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;

  { TRights }

  TRights = class(TBaseDBDataSet)
  private
    FCachedRights : TStringList;
    UserTable: TUser;
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    procedure Open; override;
    procedure DefineFields(aDataSet : TDataSet);override;
    property Users : TUser read UserTable write UserTable;
    function Right(Element: string;Recursive : Boolean = True;UseCache : Boolean = True) : Integer;
  end;
  TPermissions = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;

  { TTree }

  TTree = class(TBaseDBDataSet)
  public
    constructor Create(aOwner: TComponent; DM: TComponent;
     aConnection: TComponent=nil; aMasterdata: TDataSet=nil); override;
    procedure Open;override;
    procedure ImportStandartEntrys;
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TForms = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TReports = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;

  { TOptions }

  TOptions = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure Open; override;
  end;
  TFollowers = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure Open; override;
  end;
  TFilters = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure FillDefaults(aDataSet : TDataSet);override;
  end;
  TLinks = class(TBaseDBDataSet)
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    procedure Open;override;
    procedure DefineFields(aDataSet : TDataSet);override;
    procedure Add(aLink : string);
  end;
  TListEntrys = class(TBaseDBDataSet)
  private
    FList: TBaseDbList;
  public
    procedure DefineFields(aDataSet : TDataSet);override;
    property List : TBaseDbList read FList write FList;
  end;
  TLists = class(TBaseDBList)
  private
    FEntrys: TListEntrys;
  public
    constructor Create(aOwner : TComponent;DM : TComponent;aConnection : TComponent = nil;aMasterdata : TDataSet = nil);override;
    destructor Destroy;override;
    procedure DefineFields(aDataSet : TDataSet);override;
    function CreateTable : Boolean;override;
    function GetTextFieldName: string;override;
    function GetNumberFieldName : string;override;
    property Entrys : TListEntrys read FEntrys;
  end;
  TImages = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
  TDeletedItems = class(TBaseDBDataSet)
  public
    procedure DefineFields(aDataSet : TDataSet);override;
  end;
var ImportAble : TClassList;
implementation
uses uBaseDBInterface, uBaseApplication, uBaseSearch,XMLRead,XMLWrite,Utils,
  md5,sha1,uData;
resourcestring
  strNumbersetDontExists        = 'Nummernkreis "%s" existiert nicht !';
  strDeletedmessages            = 'gelöschte Narichten';
  strlogmessages                = 'Logs';
  strSendMessages               = 'gesendete Narichten';
  strArchive                    = 'Archiv';
  strUnknownMessages            = 'Unbekannte Narichten';
  strSpam                       = 'Spam';
  strUnsorted                   = 'Unsortiert';
  strCheckingtable              = 'Prüfe Tabelle '+lineending+'%s';
  strPasteToanWrongDataSet      = 'Diese Daten können nicht in diese Art Eintrag eingefügt werden';
  strOpeningtable               = 'öffne Tabelle '+lineending+'%s';
  strFailedShowingDataFrom      = 'konnten Daten von %s nicht anzeigen';
  strTablename                  = 'Tabellenname';
  strAccountNo                  = 'Kontonummer';
  strPassword                   = 'Passwort';
  strLanguage                   = 'Sprache';
  strStatus                     = 'Status';
  strAction                     = 'Aktion';
  strChangedby                  = 'geändert von';
  strUser                       = 'Benutzer';
  strRead                       = 'gelesen';
  strSender                     = 'Absender';
  strDate                       = 'Datum';
  strTime                       = 'Zeit';
  strSubject                    = 'Betreff';
  strMatchcode                  = 'Suchbegriff';
  strCurrency                   = 'Währung';
  strPaymentTarget              = 'Zahlungsziel';
  strCreatedDate                = 'erstellt am';
  strChangedDate                = 'geändert am';
  strInstitute                  = 'Institut';
  strDescription                = 'Beschreibung';
  strData                       = 'Daten';
  strEmployee                   = 'Mitarbeiter';
  strDepartment                 = 'Abteilung';
  strPosition                   = 'Position';
  strShorttext                  = 'Kurztext';
  strQuantityUnit               = 'Mengeneinheit';
  strVat                        = 'MwSt';
  strUnit                       = 'Einheit';
  strPriceType                  = 'Preistyp';
  strPrice                      = 'Preis';
  strMinCount                   = 'Min.Anzahl';
  strMaxCount                   = 'Max.Anzahl';
  strValidfrom                  = 'gültig ab';
  strValidTo                    = 'gültig bis';
  strProblem                    = 'Problem';
  strAssembly                   = 'Baugruppe';
  strPart                       = 'Bauteil';
  strPlace                      = 'Ort';
  strNumber                     = 'Nummer';
  strCustomerNumber             = 'Kundennummer';
  strHalfVat                    = 'Halbe MwSt';
  strFullVat                    = 'Volle MwSt';
  strNetprice                   = 'Nettopreis';
  strDiscount                   = 'Rabatt';
  strGrossPrice                 = 'Bruttopreis';
  strDone                       = 'erledigt';
  strorderNo                    = 'Vorgangsnummer';
  strTitle                      = 'Titel';
  strAdditional                 = 'Zusätzlich';
  strAdress                     = 'Adresse';
  strCity                       = 'Stadt';
  strPostalcode                 = 'Postleitzahl';
  strState                      = 'Bundesland';
  strLand                       = 'Land';
  strPostBox                    = 'Postfach';
  strPosNo                      = 'Pos.Nr.';
  strTenderPosNo                = 'Aus.Nr.';
  strIdent                      = 'Nummer';
  strTexttyp                    = 'Text Typ';
  strText                       = 'Text';
  strReference                  = 'Referenz';
  strStorage                    = 'Lager';
  strReserved                   = 'Reserviert';
  strProperty                   = 'Eigenschaft';
  strValue                      = 'Wert';
  strQuantityDelivered          = 'Menge geliefert';
  strQuantityCalculated         = 'Menge berechnet';
  strPurchasePrice              = 'Einkaufspreis';
  strSellPrice                  = 'Verkaufspreis';
  strCommonprice                = 'Allgemeinpreis';
  strBallance                   = 'Kontostand';
  strPurpose                    = 'Zahlungsgrund';
  strChecked                    = 'geprüft';
  strCategory                   = 'Kategorie';
  strPaid                       = 'bezahlt';
  strDelivered                  = 'geliefert';
  strActive                     = 'Aktiv';
  strLink                       = 'Verknüpfung';
  strTask                       = 'Aufgabe';
  strEnd                        = 'Ende';
  strPause                      = 'Pause';
  strOriginaldate               = 'Originaldatum';
  strNotes                      = 'Notizen';
  strOwner                      = 'Eigentümer';
  strAvalible                   = 'Verfügbar';

procedure TFollowers.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'FOLLOWERS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('LINK',ftString,160,True);
          end;
    end;
end;

procedure TFollowers.Open;
begin
  inherited Open;
end;

procedure TPayGroups.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'PAYGROUPS';
      TableCaption:=strPayGroups;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,60,False);
            Add('COSTS',ftFloat,0,False);
            Add('VALUE',ftFloat,0,False);
          end;
    end;
end;
procedure TListEntrys.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'LISTENTRYS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ACTIVE',ftString,1,False);
            Add('NAME',ftString,60,False);
            Add('LINK',ftString,250,False);
            Add('ICON',ftInteger,0,False);
          end;
    end;
end;
constructor TLists.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner, DM, aConnection, aMasterdata);
  FEntrys := TListEntrys.Create(Owner,DM,aConnection,DataSet);
  FEntrys.List := Self;
end;

destructor TLists.Destroy;
begin
  FEntrys.Free;
  inherited Destroy;
end;

procedure TLists.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'LISTS';
      TableCaption := strLists;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,60,False);
          end;
    end;
end;
function TLists.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FEntrys.CreateTable;
end;
function TLists.GetTextFieldName: string;
begin
  Result := 'NAME';
end;
function TLists.GetNumberFieldName: string;
begin
  Result := 'SQL_ID';
end;
procedure TDeletedItems.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'DELETEDITEMS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('REF_ID_ID',ftLargeInt,0,False);
            Add('LINK',ftString,200,False);
          end;
      if Assigned(ManagedIndexdefs) then
        with ManagedIndexDefs do
          begin
            Add('REF_ID_ID','REF_ID_ID',[]);
            Add('LINK','LINK',[]);
          end;
    end;
end;
procedure TImages.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'IMAGES';
      TableCaption:=strImages;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('REF_ID',ftLargeInt,0,True);
            Add('IMAGE',ftBlob,0,False);
          end;
    end;
end;
constructor TLinks.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner, DM, aConnection, aMasterdata);
end;

procedure TLinks.Open;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
        if Assigned(FParent) then
          begin
            if Filter <> '' then
              begin
                if not FParent.Id.IsNull then
                  Filter := Filter+' AND '+Data.QuoteField('RREF_ID')+'='+Data.QuoteValue(FParent.Id.AsString)
                else
                  Filter := Filter+' AND '+Data.QuoteField('RREF_ID')+'= 0';
              end
            else
              begin
              if not FParent.Id.IsNull then
                Filter := Data.QuoteField('RREF_ID')+'='+Data.QuoteValue(FParent.Id.AsString)
              else
                Filter := Data.QuoteField('RREF_ID')+'= 0';
              end;
          end;
        end;
    end;
  inherited Open;
end;

procedure TLinks.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'LINKS';
      TableCaption:=strLinks;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('RREF_ID',ftLargeInt,0,true);
            Add('LINK',ftString,200,true);
            Add('LINK_REF_ID',ftLargeInt,0,false);
            Add('ICON',ftInteger,0,False);
            Add('NAME',ftString,80,True);
            Add('REFERENCE',ftString,30,False);
            Add('CHANGEDBY',ftString,4,False);
            Add('CREATEDBY',ftString,4,False);
          end;
    end;
end;

procedure TLinks.Add(aLink: string);
var
  aLinkDesc: String;
  aIcon: Integer;
begin
  aLinkDesc := Data.GetLinkDesc(aLink);
  aIcon := Data.GetLinkIcon(aLink);
  Append;
  with DataSet do
    begin
      FieldByName('LINK').AsString := aLink;
      FieldByName('NAME').AsString := aLinkDesc;
      FieldByName('ICON').AsInteger := aIcon;
      FieldByName('CHANGEDBY').AsString := Data.Users.FieldByName('IDCODE').AsString;
      Post;
    end;
end;

procedure TUserfielddefs.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'USERFIELDDEFS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('TTABLE',ftString,25,True);
            Add('TFIELD',ftString,10,True);
            Add('TYPE',ftString,10,True);
            Add('SIZE',ftInteger,0,false);
          end;
    end;
end;
function TBaseDbList.GetBookNumber: TField;
var
  aField: String;
begin
  aField := GetBookNumberFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetMatchcode: TField;
var
  aField: String;
begin
  aField := GetMatchcodeFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetBarcode: TField;
var
  aField: String;
begin
  aField := GetBarcodeFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetCommission: TField;
var
  aField: String;
begin
  aField := GetCommissionFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetDescription: TField;
var
  aField: String;
begin
  aField := GetDescriptionFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetStatus: TField;
var
  aField: String;
begin
  Result := nil;
  aField := GetStatusFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetText: TField;
var
  aField: String;
begin
  if not Assigned(Self) then exit;
  Result := nil;
  aField := GetTextFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
function TBaseDbList.GetNumber: TField;
var
  aField: String;
begin
  Result := nil;
  aField := GetNumberFieldName;
  if aField <> '' then
    Result := DataSet.FieldByName(aField);
end;
constructor TBaseDbList.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner, DM, aConnection, aMasterdata);
  with BaseApplication as IBaseDbInterface do
    begin
      with FDataSet as IBaseDBFilter do
        begin
          BaseSortFields := 'TIMESTAMPD';
          SortFields := 'TIMESTAMPD';
          SortDirection := sdDescending;
        end;
    end;
  FStatusCache := TStringList.Create;
end;

destructor TBaseDbList.Destroy;
begin
  FStatusCache.Free;
  inherited Destroy;
end;

function TBaseDbList.GetStatusIcon: Integer;
var
  aStat: String;
begin
  Result := -1;
  if GetStatusFieldName='' then exit;
  aStat := FStatusCache.Values[FieldByName(GetStatusFieldName).AsString];
  if aStat <> '' then Result := StrToIntDef(aStat,-1)
  else
    begin
      if Data.States.DataSet.Locate('TYPE;STATUS',VarArrayOf([GetTyp,FieldByName(GetStatusFieldName).AsString]),[]) then
        Result := StrToIntDef(Data.States.DataSet.FieldByName('ICON').AsString,-1)
      else
        begin
          Data.SetFilter(Data.States,Data.QuoteField('TYPE')+'='+Data.QuoteValue(GetTyp));
          if Data.States.DataSet.Locate('TYPE;STATUS',VarArrayOf([GetTyp,FieldByName(GetStatusFieldName).AsString]),[]) then
            Result := StrToIntDef(Data.States.DataSet.FieldByName('ICON').AsString,-1)
        end;
      FStatusCache.Values[FieldByName(GetStatusFieldName).AsString] := IntToStr(Result);
    end;
end;

function TBaseDbList.GetTyp: string;
begin
  Result := '';
end;

function TBaseDbList.GetMatchcodeFieldName: string;
begin
  Result := '';
end;
function TBaseDbList.GetBarcodeFieldName: string;
begin
  Result := '';
end;
function TBaseDbList.GetCommissionFieldName: string;
begin
  Result := '';
end;
function TBaseDbList.GetDescriptionFieldName: string;
begin
  Result := '';
end;
function TBaseDbList.GetStatusFieldName: string;
begin
  Result := '';
end;
function TBaseDbList.GetBookNumberFieldName: string;
begin
  Result := '';
end;
procedure TBaseDBDataset.Select(aID: Variant);
var
  aField: String = '';
begin
  with BaseApplication as IBaseDBInterface do
    with DataSet as IBaseDBFilter do
      begin
        with DataSet as IBaseManageDb do
          if ManagedFieldDefs.IndexOf('AUTO_ID') > -1 then
            aField := 'AUTO_ID';
        if aField = '' then aField := 'SQL_ID';
        if (VarIsNumeric(aID) and (aID = 0))
        or (VarIsStr(aID) and (aID = ''))
        or (aID = Null)  then
          begin
            with DataSet as IBaseManageDb do
              Filter := Data.QuoteField(TableName)+'.'+Data.QuoteField(aField)+'='+Data.QuoteValue('0');
          end
        else
          begin
            with DataSet as IBaseManageDb do
              Filter := Data.QuoteField(TableName)+'.'+Data.QuoteField(aField)+'='+Data.QuoteValue(Format('%d',[Int64(aID)]));
          end;
      end;
end;

function TBaseDbList.Find(aIdent: string;Unsharp : Boolean = False): Boolean;
begin
  Result := False;
end;
function TBaseDbList.ExportToXML : string;
var
  Stream: TStringStream;
  Doc: TXMLDocument;
  RootNode: TDOMElement;

  procedure RecourseTables(aNode : TDOMNode;aDataSet : TDataSet);
  var
    i: Integer;
    aData: TDOMElement;
    DataNode: TDOMElement;
    a: Integer;
    Row: TDOMElement;
    tmp: String;
    tmp1: String;
  begin
    with aDataSet as IBaseManageDB do
      begin
        if pos('HISTORY',uppercase(TableName)) > 0 then exit;
        if Uppercase(TableName) = 'STORAGE' then exit;
      end;
    aData := Doc.CreateElement('TABLE');
    aNode.AppendChild(aData);
    with aDataSet as IBaseManageDB do
      aData.SetAttribute('NAME',TableName);
    DataNode := Doc.CreateElement('DATA');
    aData.AppendChild(DataNode);
    aDataSet.Open;
    aDataSet.Refresh;
    aDataSet.First;
    a := 0;
    while not aDataSet.EOF do
      begin
        inc(a);
        Row := Doc.CreateElement('ROW.'+IntToStr(a));
        DataNode.AppendChild(Row);
        for i := 1 to aDataSet.Fields.Count-1 do
          begin
            tmp := aDataSet.Fields[i].FieldName;
            if (tmp <> '')
            and (tmp <> 'SQL_ID')
            and (tmp <> 'REF_ID')
            then
              begin
                tmp1 := aDataSet.Fields[i].AsString;
                if (not aDataSet.Fields[i].IsNull) then
                  Row.SetAttribute(tmp,tmp1);
              end;
          end;
        with aDataSet as IBaseSubDataSets do
          begin
            for i := 0 to GetCount-1 do
              RecourseTables(Row,SubDataSet[i].DataSet);
          end;
        aDataSet.Next;
      end;
  end;
begin
  Doc := TXMLDocument.Create;
  RootNode := Doc.CreateElement('TABLES');
  Doc.AppendChild(RootNode);
  RecourseTables(RootNode,DataSet);
  Stream := TStringStream.Create('');
  WriteXMLFile(Doc,Stream);
  Result := Stream.DataString;
  Doc.Free;
  Stream.Free;
end;
procedure TBaseDbList.ImportFromXML(XML: string;OverrideFields : Boolean = False;ReplaceFieldFunc : TReplaceFieldFunc = nil);
var
  Doc : TXMLDocument;
  Stream : TStringStream;
  RootNode: TDOMNode;
  i: Integer;

  procedure RecourseTables(aNode : TDOMNode;aDataSet : TDataSet);
  var
    i: Integer;
    a: Integer;
    bNode: TDOMNode;
    cNode: TDOMNode;
    ThisDataSet: TDataSet;
    function ProcessDataSet(ThisDataSet : TDataSet) : Boolean;
    var
      c,d: Integer;
      b: Integer;
      aNewValue: String;
    begin
      Result := False;
      with ThisDataSet as IBaseManageDB do
        if (TableName = aNode.Attributes.GetNamedItem('NAME').NodeValue) then
          begin
            ThisDataSet.Open;
            cNode := aNode.ChildNodes[i];
            for c := 0 to cNode.ChildNodes.Count-1 do
              if copy(cNode.ChildNodes[c].NodeName,0,4) = 'ROW.' then
                begin
                  bNode := cNode.ChildNodes[c];
                  if (ThisDataSet.State = dsEdit) then
                    ThisDataSet.Post;
                  if (ThisDataSet.State <> dsInsert) then
                    ThisDataSet.Append;
                  for d := 0 to bNode.Attributes.Length-1 do
                    if ThisDataSet.FieldDefs.IndexOf(bNode.Attributes.Item[d].NodeName) <> -1 then
                      if (ThisDataSet.FieldByName(bNode.Attributes.Item[d].NodeName).IsNull or (OverrideFields))
                      or (bNode.Attributes.Item[d].NodeName = 'QUANTITY')
                      or (bNode.Attributes.Item[d].NodeName = 'POSNO')
                      or (bNode.Attributes.Item[d].NodeName = 'VAT')
                      or (bNode.Attributes.Item[d].NodeName = 'WARRENTY')
                      or (bNode.Attributes.Item[d].NodeName = 'PARENT')
                      or (bNode.Attributes.Item[d].NodeName = 'TYPE')
                      or (bNode.Attributes.Item[d].NodeName = 'DEPDONE')
                      or (bNode.Attributes.Item[d].NodeName = 'CHECKED')
                      or (bNode.Attributes.Item[d].NodeName = 'HASCHILDS')
                      then
                        begin
                          aNewValue := bNode.Attributes.Item[d].NodeValue;
                          if Assigned(ReplaceFieldFunc) then
                            ReplaceFieldFunc(ThisDataSet.FieldByName(bNode.Attributes.Item[d].NodeName),bNode.Attributes.Item[d].NodeValue,aNewValue);
                          ThisDataSet.FieldByName(bNode.Attributes.Item[d].NodeName).AsString := aNewValue;
                        end;
                  ThisDataSet.Post;
                  for b := 0 to bNode.ChildNodes.Count-1 do
                    if bNode.ChildNodes[b].NodeName = 'TABLE' then
                      begin
                        RecourseTables(bNode.ChildNodes[b],ThisDataSet);
                      end;
                  if (ThisDataSet.State = dsEdit) then
                    ThisDataSet.Post;
                end;
            Result := True;
          end;
    end;
  begin
    for i := 0 to aNode.ChildNodes.Count-1 do
      begin
        if aNode.ChildNodes[i].NodeName = 'DATA' then
          begin
            if not ProcessDataSet(aDataSet) then
              with aDataSet as IBaseSubDataSets do
                begin
                  for a := 0 to GetCount-1 do
                    begin
                      if ProcessDataSet(SubDataSet[a].DataSet) then break;
                    end;
                end;
          end;
      end;
  end;
begin
  Stream := TStringStream.Create(XML);
  Stream.Position:=0;
  ReadXMLFile(Doc,Stream);
  RootNode := Doc.FindNode('TABLES');
  for i := 0 to RootNode.ChildNodes.Count-1 do
    if RootNode.ChildNodes[i].NodeName = 'TABLE' then
      with DataSet as IBaseManageDB do
        begin
         if RootNode.ChildNodes[i].Attributes.GetNamedItem('NAME') <> nil then
           if RootNode.ChildNodes[i].Attributes.GetNamedItem('NAME').NodeValue <> TableName then
             raise Exception.Create(strPasteToanWrongDataSet)
           else
             RecourseTables(RootNode.ChildNodes[i],DataSet);
        end;
  Stream.Free;
  Doc.Free;
end;
procedure TBaseDbList.SelectFromLink(aLink: string);
begin
  Select(0);
  if pos('{',aLink) > 0 then
    aLink := copy(aLink,0,pos('{',aLink)-1)
  else if rpos('(',aLink) > 0 then
    aLink := copy(aLink,0,rpos('(',aLink)-1);
  with DataSet as IBaseManageDB do
    if copy(aLink,0,pos('@',aLink)-1) = TableName then
      if IsNumeric(copy(aLink,pos('@',aLink)+1,length(aLink))) then
        begin
          Select(StrToInt64(copy(aLink,pos('@',aLink)+1,length(aLink))));
        end;
end;
procedure TBaseDBDataset.Delete;
begin
  Change;
  if FDataSet.Active and (Count > 0) then
    FDataSet.Delete;
end;

procedure TBaseDBDataset.Insert;
begin
  if not DataSet.Active then
    begin
      Select(0);
      Open;
    end;
  DataSet.Insert;
end;
procedure TBaseDBDataset.Append;
begin
  if not DataSet.Active then
    begin
      Select(0);
      Open;
    end;
  DataSet.Append;
end;

procedure TBaseDBDataset.First;
begin
  DataSet.First;
end;

procedure TBaseDBDataset.Next;
begin
  DataSet.Next;
end;
procedure TBaseDBDataset.Prior;
begin
  DataSet.Prior;
end;

procedure TBaseDBDataset.Post;
begin
  FDataSet.Post;
end;

function TBaseDBDataset.EOF: Boolean;
begin
  Result := True;
  if Assigned(FDataSet) and (FDataSet.Active) then
    Result := FDataSet.EOF;
end;

function TBaseDBDataset.FieldByName(aFieldName : string): TField;
begin
  Result := nil;
  if Assigned(DataSet) and DataSet.Active then
    Result := DataSet.FieldByName(aFieldname);
end;
procedure TBaseDBDataset.Assign(Source: TPersistent);
begin
  if Source is Self.ClassType then
    DirectAssign(Source)
  else
    inherited Assign(Source);
end;
procedure TBaseDBDataset.DirectAssign(Source: TPersistent);
var
  i: Integer;
begin
  if (not DataSet.Active) or (DataSet.RecordCount = 0) then exit;
  if not (Source is TBaseDBDataSet) then exit;
  if (not TBaseDbDataSet(Source).DataSet.Active) or (TBaseDbDataSet(Source).DataSet.RecordCount = 0) then exit;
  for i := 0 to TBaseDbDataSet(Source).DataSet.Fields.Count-1 do
    if DataSet.FieldDefs.IndexOf(TBaseDbDataSet(Source).DataSet.Fields[i].FieldName) <> -1 then
      if  (TBaseDbDataSet(Source).DataSet.Fields[i].FieldName <> 'SQL_ID')
      and (TBaseDbDataSet(Source).DataSet.Fields[i].FieldName <> 'AUTO_ID')
      and (TBaseDbDataSet(Source).DataSet.Fields[i].FieldName <> 'TIMESTAMP') then
        DataSet.FieldByName(TBaseDbDataSet(Source).DataSet.Fields[i].FieldName).AsVariant:=TBaseDbDataSet(Source).DataSet.Fields[i].AsVariant;
end;
constructor TBaseHistory.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner, DM, aConnection, aMasterdata);
  FHChanged := False;
  FShouldChange:=False;
end;
procedure TBaseHistory.SetDisplayLabels(aDataSet: TDataSet);
begin
  inherited SetDisplayLabels(aDataSet);
  SetDisplayLabelName(aDataSet,'CHANGEDBY',strCreatedby);
  SetDisplayLabelName(aDataSet,'OBJECT',strObject);
  SetDisplayLabelName(aDataSet,'REFOBJECT',strRefObject);
end;
procedure TBaseHistory.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'HISTORY';
      TableCaption:=strHistory;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('REF_ID',ftLargeInt,0,true);
            Add('LINK',ftString,200,False);
            Add('OBJECT',ftString,200,False);
            Add('ACTIONICON',ftInteger,0,False);
            Add('ACTION',ftMemo,0,True);
            Add('REFERENCE', ftString,150,False);
            Add('REFOBJECT',ftString,200,False);
            Add('COMMISSION',ftString,60,False);
            Add('READ',ftString,1,False);
            Add('CHANGEDBY',ftString,4,False);
            Add('PARENT',ftLargeInt,0,False);
          end;
      if Assigned(ManagedIndexdefs) then
        with ManagedIndexDefs do
          begin
            Add('REF_ID','REF_ID',[]);
            Add('PARENT','PARENT',[]);
            Add('REFERENCE','REFERENCE',[]);
            Add('LINK','LINK',[]);
            Add('TIMESTAMPD','TIMESTAMPD',[]);
          end;
    end;
end;
procedure TBaseHistory.Change;
begin
  inherited;
  if FShouldChange then
    begin
      FHChanged := True;
      if Owner is TBaseDbDataSet then TBaseDbDataSet(Owner).Change;
      FShouldCHange := False;
    end;
end;
function TBaseHistory.AddItem(aObject: TDataSet; aAction: string;
  aLink: string; aReference: string; aRefObject: TDataSet; aIcon: Integer;
  aComission: string; CheckDouble: Boolean; DoPost: Boolean; DoChange: Boolean) : Boolean;
var
  tmp: String;
begin
  Result := False;
  if not DataSet.Active then
    Open;
  with DataSet do
    begin
      Last;
      tmp := FieldByName('ACTION').AsString;
      with BaseApplication as IBaseDbInterface do
        begin
          if  (FieldByName('ACTIONICON').AsInteger = aIcon)
          and (aIcon<>ACICON_USEREDITED)
          and (FieldByName('LINK').AsString = aLink)
          and (trunc(FieldByName('TIMESTAMPD').AsDatetime) = trunc(Now()))
          and (FieldByName('CHANGEDBY').AsString = Data.Users.FieldByName('IDCODE').AsString)
          and (FieldByName('REFERENCE').AsString = aReference)
          and (CheckDouble)
          then
            Delete;
        end;
      Append;
      if aLink <> '' then
        FieldByName('LINK').AsString      := aLink;
      with BaseApplication as IBaseDbInterface do
        FieldByName('OBJECT').AsString := Data.BuildLink(aObject);
      FieldByName('ACTIONICON').AsInteger := aIcon;
      FieldByName('ACTION').AsString    := aAction;
      FieldByName('REFERENCE').AsString := aReference;
      if Assigned(aRefObject) then
        begin
          with BaseApplication as IBaseDbInterface do
            FieldByName('REFOBJECT').AsString := Data.BuildLink(aRefObject);
        end;
      with BaseApplication as IBaseDbInterface do
        FieldByName('CHANGEDBY').AsString := Data.Users.FieldByName('IDCODE').AsString;
      DataSet.FieldByName('COMMISSION').AsString := aComission;
      if DoPost then
        Post;
      result := True;
      if DoChange or (not DoPost) then
        begin
          FShouldChange := True;
          Change;
        end;
    end;
end;

procedure TBaseHistory.AddParentedItem(aObject: TDataSet; aAction: string;
  aParent: Variant; aLink: string; aReference: string; aRefObject: TDataSet;
  aIcon: Integer; aComission: string; CheckDouble: Boolean; DoPost: Boolean;
  DoChange: Boolean);
begin
  if AddItem(aObject,aAction,aLink,aReference,aRefObject,aIcon,aComission,CheckDouble,False,DoChange) then
    begin
      DataSet.FieldByName('PARENT').AsVariant := aParent;
      if DoPost then
        Post;
    end;
end;

procedure TBaseHistory.AddItemWithoutUser(aObject: TDataSet; aAction: string;
  aLink: string; aReference: string; aRefObject: TDataSet; aIcon: Integer;
  aComission: string; CheckDouble: Boolean; DoPost: Boolean; DoChange: Boolean);
var
  tmp: String;
begin
  if not DataSet.Active then
    Open;
  with DataSet do
    begin
      Last;
      tmp := FieldByName('ACTION').AsString;
      with BaseApplication as IBaseDbInterface do
        begin
          if (tmp = aAction)
          and (FieldByName('ACTIONICON').AsInteger = aIcon)
          and (FieldByName('LINK').AsString = aLink)
          and (trunc(FieldByName('TIMESTAMPD').AsDatetime) = trunc(Now()))
          and (FieldByName('CHANGEDBY').AsString = Data.Users.FieldByName('IDCODE').AsString)
          and (FieldByName('REFERENCE').AsString = aReference)
          and (CheckDouble)
          then
            exit; //Ignore Add when Action is equal
        end;
      Append;
      if aLink <> '' then
        FieldByName('LINK').AsString      := aLink;
      with BaseApplication as IBaseDbInterface do
        FieldByName('OBJECT').AsString := Data.BuildLink(aObject);
      FieldByName('ACTIONICON').AsInteger := aIcon;
      FieldByName('ACTION').AsString    := aAction;
      FieldByName('REFERENCE').AsString := aReference;
      if Assigned(aRefObject) then
        begin
          with BaseApplication as IBaseDbInterface do
            FieldByName('REFOBJECT').AsString := Data.BuildLink(aRefObject);
        end;
      DataSet.FieldByName('COMMISSION').AsString := aComission;
      if DoPost then
        Post;
      if DoChange or (not DoPost) then
        begin
          FShouldChange := True;
          Change;
        end;
    end;
end;

function TBaseHistory.GetTextFieldName: string;
begin
  Result := 'ACTION';
end;

function TBaseHistory.GetNumberFieldName: string;
begin
  Result := 'REFERENCE';
end;

procedure TActiveUsers.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'ACTIVEUSERS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('ACCOUNTNO',ftString,20,False);
            Add('NAME',ftString,30,True);
            Add('CLIENT',ftString,50,True);
            Add('HOST',ftString,50,False);
            Add('VERSION',ftString,25,False);
            Add('COMMAND',ftMemo,0,False);
            Add('EXPIRES',ftDateTime,0,False);
          end;
    end;
end;
procedure TPermissions.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'PERMISSIONS';
      TableCaption:=strPermissions;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('REF_ID_ID',ftLargeInt,0,True);
            Add('USER',ftLargeInt,0,True);
            Add('RIGHT',ftSmallInt,0,True);
          end;
      if Assigned(ManagedIndexdefs) then
        with ManagedIndexDefs do
          Add('REF_ID_ID','REF_ID_ID',[]);
    end;
end;
procedure Treports.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'REPORTS';
      TableCaption:=strReports;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('TYPE',ftString,4,True);
            Add('NAME',ftString,60,True);
            Add('CHANGEDBY',ftString,4,False);
            Add('LANGUAGE',ftString,3,True);
            Add('REPORT',ftBlob,0,False);
            Add('TEXT',ftMemo,0,False);
          end;
    end;
end;
procedure TFilters.DefineFields(aDataSet: TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'FILTERS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('TYPE',ftString,1,True);
            Add('NAME',ftString,60,True);
            Add('FILTER',ftString,150,True);
            Add('FILTERIN',ftString,100,False);
            Add('STANDART',ftString,1,True);
            Add('SORTDIR',ftString,4,False);
            Add('SORTFIELD',ftString,20,False);
            Add('USER',ftString,20,False);
          end;
    end;
end;
procedure TFilters.FillDefaults(aDataSet: TDataSet);
begin
  aDataSet.FieldByName('STANDART').AsString := 'N';
end;
procedure TForms.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'FORMS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('TYPE',ftString,3,True);
            Add('NAME',ftString,60,True);
            Add('FORM',ftBlob,0,False);
          end;
    end;
end;
constructor TTree.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner, DM, aConnection, aMasterdata);
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          UsePermissions:=True;
          BaseSortFields := 'SQL_ID';
          SortFields := 'SQL_ID';
          SortDirection := sdAscending;
        end;
    end;
end;
procedure TTree.Open;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          Limit := 0;
        end;
    end;
  inherited Open;
end;
procedure TTree.ImportStandartEntrys;
begin
  Open;
  if not DataSet.Locate('SQL_ID',TREE_ID_CUSTOMER_UNSORTED,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'C';
      DataSet.FieldByName('NAME').AsString := strUnsorted;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_CUSTOMER_UNSORTED;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_MASTERDATA_UNSORTED,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'M';
      DataSet.FieldByName('NAME').AsString := strUnsorted;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_MASTERDATA_UNSORTED;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_PROJECT_UNSORTED,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'P';
      DataSet.FieldByName('NAME').AsString := strUnsorted;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_PROJECT_UNSORTED;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_WIKI_UNSORTED,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'W';
      DataSet.FieldByName('NAME').AsString := strUnsorted;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_WIKI_UNSORTED;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_MESSAGES,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strMessages;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_MESSAGES;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_UNKNOWN_MESSAGES,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strUnknownMessages;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_UNKNOWN_MESSAGES;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',IntToStr(TREE_ID_SEND_MESSAGES),[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strSendMessages;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_SEND_MESSAGES;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_SPAM_MESSAGES,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strSpam;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_SPAM_MESSAGES;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_ARCHIVE_MESSAGES,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strArchive;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_ARCHIVE_MESSAGES;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_DELETED_MESSAGES,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strDeletedMessages;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_DELETED_MESSAGES;
      DataSet.Post;
    end;
  if not DataSet.Locate('SQL_ID',TREE_ID_LOG_MESSAGES,[]) then
    begin
      DataSet.Append;
      DataSet.FieldByName('PARENT').AsString := '0';
      DataSet.FieldByName('TYPE').AsString := 'N';
      DataSet.FieldByName('NAME').AsString := strLogMessages;
      DataSet.Post;
      DataSet.Edit;
      id.AsVariant:=TREE_ID_LOG_MESSAGES;
      DataSet.Post;
    end;
end;
procedure TTree.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'TREE';
      TableCaption:=strTree;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('PARENT',ftLargeint,0,False);
            Add('TYPE',ftString,1,True);
            Add('NAME',ftString,60,True);
          end;
    end;
end;
procedure TOptions.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'OPTIONS';
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('OPTION',ftString,60,True);
            Add('VALUE',ftMemo,0,True);
          end;
    end;
end;

procedure TOptions.Open;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          Limit := 0;
        end;
    end;
  inherited Open;
end;

constructor TRights.Create(aOwner: TComponent; DM : TComponent;aConnection: TComponent;
  aMasterdata: TDataSet);
begin
  inherited Create(aOwner,DM, aConnection, aMasterdata);
  FCachedRights := TStringList.Create;
end;
destructor TRights.Destroy;
begin
  FCachedRights.Free;
  inherited Destroy;
end;

procedure TRights.Open;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          Limit := 0;
        end;
    end;
  inherited Open;
end;

procedure TRights.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'RIGHTS';
      TableCaption:=strUserRights;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('RIGHTNAME',ftString,20,true);
            Add('RIGHTS',ftSmallInt,0,true);
          end;
    end;
end;
function TRights.Right(Element: string; Recursive: Boolean; UseCache: Boolean): Integer;
var
  aUser : LongInt;

  procedure RecursiveGetRight(aRec : Integer = 0);
  begin
    if aRec>10 then
      begin
        Result := -1;
        exit;
      end;
    if DataSet.Locate('RIGHTNAME',VarArrayOf([Element]),[loCaseInsensitive]) then
      Result := DataSet.FieldByName('RIGHTS').AsInteger
    else
      begin
        with BaseApplication as IBaseDbInterface do
          begin
            if not UserTable.FieldByName('PARENT').IsNull then
              begin
                if (Recursive) and UserTable.GotoBookmark(UserTable.FieldByName('PARENT').AsInteger) then
                  RecursiveGetRight(aRec+1)
                else
                  Result := -1;
              end
            else
              Result := -1;
          end;
      end;
  end;
begin
  try
    if (FCachedRights.Values[Element] <> '') and UseCache then
      Result := StrToInt(FCachedRights.Values[Element])
    else
      begin
        with BaseApplication as IBaseDBInterface do
          begin
            aUser := UserTable.GetBookmark;
            with Self.DataSet as IBaseDBFilter do
              Filter := Data.QuoteField('RIGHTNAME')+'='+Data.QuoteValue(UpperCase(Element));
            Open;
            RecursiveGetRight;
            UserTable.GotoBookmark(aUser);
          end;
        FCachedRights.Values[Element] := IntToStr(Result);
      end;
  except
    Result := -1;
  end;
end;
procedure TMandantDetails.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'MANDANTDETAILS';
      TableCaption:=strMandantDetails;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('NAME',ftString,30,False);
            Add('ADRESS',ftMemo,0,False);
            Add('SORTCODE',ftString,8,False);
            Add('ACCOUNT',ftString,10,False);
            Add('INSTITUTE',ftString,40,false);
            Add('SWIFT',ftString,11,false);
            Add('IBAN',ftString,34,false);
            Add('TEL1',ftString,30,false);
            Add('TEL2',ftString,30,false);
            Add('TEL3',ftString,30,false);
            Add('TEL4',ftString,30,false);
            Add('FAX',ftString,30,false);
            Add('MAIL',ftString,50,false);
            Add('INTERNET',ftString,50,false);
            Add('ADDITION1',ftMemo,0,False);
            Add('ADDITION2',ftMemo,0,False);
            Add('ADDITION3',ftMemo,0,False);
            Add('ADDITION4',ftMemo,0,False);
            Add('ADDITION5',ftMemo,0,False);
            Add('ADDITION6',ftMemo,0,False);
            Add('ADDITION7',ftMemo,0,False);
            Add('ADDITION8',ftMemo,0,False);
            Add('STAMP',ftLargeInt,0,False);
            Add('IMAGE',ftBlob,0,False);
          end;
    end;
end;
procedure TNumbersets.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'NUMBERS';
      TableCaption:=strNumbersets;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('TABLENAME',ftString,25,True);
            Add('TYPE',ftString,1,True);
            Add('INCR',ftInteger,0,False);
            Add('ACTUAL',ftInteger,0,False);
            Add('STOP',ftInteger,0,False);
          end;
    end;
end;
function TNumbersets.GetNewNumber(Numberset: string): string;
var
  i: Integer;
begin
  Result := '';
  with BaseApplication as IBaseDbInterface do
    begin
      Data.SetFilter(Self, Data.QuoteField('TABLENAME')+'='+Data.QuoteValue(numberset));
      if DataSet.Recordcount > 0 then
        begin
          if DataSet.FieldByName('TYPE').AsString = 'N' then
            begin
              if DataSet.FieldByName('ACTUAL').AsInteger + DataSet.FieldByName('INCR').AsInteger < DataSet.FieldByName('STOP').AsInteger then
                begin
                  DataSet.Edit;
                  DataSet.FieldByName('ACTUAL').AsInteger :=
                    DataSet.FieldByName('ACTUAL').AsInteger + DataSet.FieldByName('INCR').AsInteger;
                  Result := IntToStr(DataSet.FieldByName('ACTUAL').AsInteger);
                  DataSet.Post;
                end;
            end
          else if DataSet.FieldByName('TYPE').AsString = 'A' then
            begin
              Randomize;
              for i := 0 to 14 do
                Result := Result + chr($30 + random(36));
              StringReplace(Result, '=', '-', [rfreplaceAll]);
              StringReplace(Result, '?', '-', [rfreplaceAll]);
              StringReplace(Result, '@', '-', [rfreplaceAll]);
            end;
        end
      else raise Exception.Create(Format(strNumbersetDontExists,[Numberset]));
    end;
end;
function TNumbersets.HasNumberSet(Numberset: string): Boolean;
begin
  with BaseApplication as IBaseDbInterface do
    Data.SetFilter(Self, Data.QuoteField('TABLENAME')+'='+Data.QuoteValue(numberset));
  Result := Count > 0;
end;
function TUser.GetLeaved: TField;
begin
  Result := DataSet.FieldByName('LEAVED');
end;
function TUser.GetPasswort: TField;
begin
  Result := DataSet.FieldByName('PASSWORD');
end;
function TUser.GetSalt: TField;
begin
  Result := DataSet.FieldByName('SALT');
end;
function TUser.GetUser: TField;
begin
  Result := DataSet.FieldByName('NAME');
end;
function TUser.GetTextFieldName: string;
begin
  Result := 'NAME';
end;
function TUser.GetNumberFieldName: string;
begin
  Result := 'CUSTOMERNO';
end;

function TUser.GetWorktime: Extended;
begin
  Result := FieldByName('WORKTIME').AsFloat;
  if Result=0 then Result := 8;
end;

function TUser.MergeSalt(apasswort, aSalt: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to length(aPasswort)-1 do
    begin
      Result += copy(aSalt,0,5);
      aSalt := copy(aSalt,6,length(aSalt));
      result += copy(aPasswort,0,1);
      aPasswort := copy(aPasswort,2,length(aPasswort));
    end;
end;
function TUser.GetHistory: TBaseHistory;
begin
  Result := FHistory;
end;
function TUser.GetTyp: string;
begin
  Result := 'U';
end;
constructor TUser.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner, DM, aConnection, aMasterdata);
  FOptions := TOptions.Create(Owner,DM,aConnection,DataSet);
  FRights := TRights.Create(Owner,DM,aConnection,DataSet);
  FFollows := TFollowers.Create(Owner,DM,aConnection,DataSet);
  FRights.Users := Self;
  FHistory := TBaseHistory.Create(Self,DM,aConnection,DataSet);
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          Limit := 0;
        end;
    end;
end;
destructor TUser.Destroy;
begin
  Options.Destroy;
  Rights.Destroy;
  FFollows.Destroy;
  FHistory.Destroy;
  inherited Destroy;
end;

procedure TUser.Open;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      with DataSet as IBaseDBFilter do
        begin
          Limit := 0;
        end;
    end;
  inherited Open;
end;

procedure TUser.DefineFields(aDataSet : TDataSet);
begin
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'USERS';
      TableCaption := strUsers;
      if Assigned(ManagedFieldDefs) then
        with ManagedFieldDefs do
          begin
            Add('TYPE',ftString,1,False);
            Add('PARENT',ftLargeint,0,False);
            Add('ACCOUNTNO',ftString,20,True);
            Add('NAME',ftString,30,True);
            Add('PASSWORD',ftString,45,False);
            Add('SALT',ftString,105,False);
            Add('IDCODE',ftString,4,False);
            Add('EMPLOYMENT',ftDate,0,False);
            Add('LEAVED',ftDate,0,false);
            Add('CUSTOMERNO',ftString,20,false);
            Add('DEPARTMENT',ftString,30,false);
            Add('POSITION',ftString,30,false);
            Add('LOGINNAME',ftString,30,false);
            Add('EMAIL',ftString,100,false);
            Add('PAYGROUP',ftLargeint,0,false);
            Add('WORKTIME',ftInteger,0,false); //8 wenn NULL
            Add('WEEKWORKTIME',ftInteger,0,false);//40 wenn NULL
            Add('USEWORKTIME',ftInteger,0,false);
            Add('LOGINACTIVE',ftString,1,false);
            Add('REMOTEACCESS',ftString,1,false);
          end;
      if Assigned(ManagedIndexdefs) then
        with ManagedIndexDefs do
          Add('ACCOUNTNO','ACCOUNTNO',[ixUnique]);
    end;
end;
procedure TUser.FillDefaults(aDataSet: TDataSet);
begin
  with BaseApplication as IBaseDbInterface do
    aDataSet.FieldByName('ACCOUNTNO').AsString:=Data.Numbers.GetNewNumber('USERS');
end;

procedure TUser.SelectByParent(aParent: Variant);
begin
  with  DataSet as IBaseDBFilter, BaseApplication as IBaseDBInterface, DataSet as IBaseManageDB do
    begin
      if aParent=Null then
        Filter := Data.ProcessTerm('('+QuoteField('PARENT')+'='+Data.QuoteValue('')+')')
      else
        Filter := '('+QuoteField('PARENT')+'='+QuoteValue(aParent)+')';
    end;
end;

function TUser.CreateTable : Boolean;
begin
  Result := inherited CreateTable;
  FOptions.CreateTable;
  FRights.CreateTable;
  FFollows.CreateTable;
end;
procedure TUser.SetPasswort(aPasswort: string);
var
  aGUID: TGUID;
  aSalt: String;
  aRes: String;
begin
  if not CanEdit then
    DataSet.Edit;
  Salt.AsString:=GetRandomSalt;
  aRes := '$'+SHA1Print(SHA1String(SHA1Print(SHA1String(MergeSalt(aPasswort,Salt.AsString)))));
  Passwort.AsString:=aRes;
  DataSet.Post;
end;

function TUser.GetRandomSalt: string;
var
  aSalt: String;
  aGUID: TGUID;
begin
  CreateGUID(aGUID);
  aSalt := md5Print(md5String(GUIDToString(aGUID)+UserName.AsString));
  CreateGUID(aGUID);
  aSalt += md5Print(md5String(GUIDToString(aGUID)+aSalt));
  CreateGUID(aGUID);
  aSalt += md5Print(md5String(GUIDToString(aGUID)));
  aSalt :=copy(aSalt,0,104);
  Result := aSalt;
end;

function TUser.CheckPasswort(aPasswort: string): Boolean;
var
  aRes: String;
  aSalt: String;
begin
  if copy(Passwort.AsString,0,1) <> '$' then
    Result := md5print(MD5String(aPasswort)) = Passwort.AsString
  else
    begin
      aSalt := Salt.AsString;
      aRes := '$'+SHA1Print(SHA1String(SHA1Print(SHA1String(MergeSalt(aPasswort,aSalt)))));
      Result := (copy(aRes,0,length(Passwort.AsString)) = Passwort.AsString) and (length(Passwort.AsString) > 30);
    end;
end;

function TUser.CheckSHA1Passwort(aPasswort : string): Boolean;
var
  aRes: String;
begin
  aRes := '$'+SHA1Print(SHA1String(aPasswort));
  Result := (copy(aRes,0,length(Passwort.AsString)) = Passwort.AsString) and (length(Passwort.AsString) > 30);
end;

procedure TUser.SelectByAccountno(aAccountno: string);
var
  aField: String = '';
begin
  with BaseApplication as IBaseDBInterface do
    with DataSet as IBaseDBFilter do
      begin
        Filter := Data.QuoteField('ACCOUNTNO')+'='+Data.QuoteValue(aAccountno);
      end;
end;
function TBaseDBDataset.GetID: TField;
begin
  Result := nil;
  if DataSet.Active and (DataSet.FieldDefs.IndexOf('SQL_ID')>-1) then
    Result := DataSet.FieldByName('SQL_ID');
end;
function TBaseDBDataset.GetState: TDataSetState;
begin
  if Assigned(FDataSet) then
    Result := FDataSet.State;
end;
function TBaseDBDataset.GetConnection: TComponent;
begin
  with FDataSet as IBaseManageDB do
    Result := GetConnection;
end;
function TBaseDBDataset.GetCaption: string;
begin
  with FDataSet as IBaseManageDB do
    Result := GetTableCaption;
end;
function TBaseDBDataset.GetCanEdit: Boolean;
begin
  Result := Assigned(fdataSet) and (FDataSet.State = dsEdit) or (FDataSet.State = dsInsert);
end;
function TBaseDBDataset.GetCount: Integer;
begin
  if DataSet.Active then
    Result := DataSet.RecordCount
  else
    Result := -1;
end;
function TBaseDBDataset.GetFullCount: Integer;
var
  aDS: TDataSet;
  aFilter: String;
begin
  if TBaseDBModule(DataModule).IsSQLDB then
    begin
      with FDataSet as IBaseManageDB,FDataSet as IBaseDbFilter do
        begin
          aFilter := Filter;
          if aFilter <> '' then
            aDS := TBaseDBModule(DataModule).GetNewDataSet('select count(*) from '+TBaseDBModule(DataModule).QuoteField(GetTableName)+' where '+Filter,Connection)
          else
            aDS := TBaseDBModule(DataModule).GetNewDataSet('select count(*) from '+TBaseDBModule(DataModule).QuoteField(GetTableName),Connection);
        end;
      aDS.Open;
      if aDS.RecordCount>0 then
        Result := aDS.Fields[0].AsInteger;
      aDS.Free;
    end
  else
    Result := Count;
end;
function TBaseDBDataset.GetTimestamp: TField;
begin
  Result := DataSet.FieldByName('TIMESTAMPD');
end;
constructor TBaseDBDataset.Create(aOwner: TComponent; DM: TComponent; aUseIntegrity: Boolean;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  inherited Create(aOwner);
  FUpdateFloatFields := false;
  Fparent := nil;
  FDataModule := DM;
  FSecModified := True;
  FDisplayLabelsWasSet:=False;
  FUseIntegrity:=aUseIntegrity;
  FOnChanged := nil;
  if Assigned(aOwner) and (aOwner is TBaseDbDataSet) then
    FParent := TBaseDbDataSet(aOwner);
  with BaseApplication as IBaseDbInterface do
    begin
      with FDataModule as TBaseDbModule do
        FDataSet := GetNewDataSet(Self,aConnection,aMasterdata);
      with FDataSet as IBaseManageDB do
        UseIntegrity := FUseIntegrity;
      with FDataSet as IBaseDBFilter do
        Limit := 100;
    end;
end;
constructor TBaseDBDataset.Create(aOwner: TComponent; DM: TComponent;
  aConnection: TComponent; aMasterdata: TDataSet);
begin
  Create(aOwner,DM,True,aConnection,aMasterdata);
end;
destructor TBaseDBDataset.Destroy;
begin
  if not TBaseDBModule(DataModule).IgnoreOpenRequests then
  if Assigned(FDataSet) then
    begin
      try
        if FDataSet.Active then
          FDataSet.Close;
      except
        on e : Exception do
          begin
            with BaseApplication as IBaseApplication do
              with FDataSet as IBaseManageDB do
                debugln(Format('Error Destroying Table %s,%s',[TableName,e.Message]));
          end;
      end;
    end;
  inherited Destroy;
end;
procedure TBaseDBDataset.Open;
var
  Retry: Boolean = False;
  aCreated: Boolean = False;
  aOldFilter: String = '';
  aOldLimit: Integer;
  aErr: String;
begin
  if not Assigned(FDataSet) then exit;
  if FDataSet.Active then
    begin
      FDataSet.Refresh;
      exit;
    end;
  try
    with DataSet as IBaseManageDB do
      begin
        FDataSet.Open
      end;
  except
    on e : Exception do
      begin
        aErr := e.Message;
        debugln(e.Message);
        Retry := True;
      end;
  end;
  if Retry then
    begin
      while FDataSet.ControlsDisabled do
        FDataSet.EnableControls;
      try
        FDataSet.Open;
      except
        begin
          raise Exception.Create(aErr);
          exit;
        end;
      end;
    end;
  if DataSet.Active and FDisplayLabelsWasSet then
    SetDisplayLabels(DataSet);
end;
function TBaseDBDataset.CreateTable : Boolean;
var
  aOldFilter: String;
  aOldLimit: Integer;
begin
  with FDataSet as IBaseManageDB do
    begin
      Result := CreateTable;
      if not Result then
        begin
          if (Assigned(Data)) and (Data.ShouldCheckTable(TableName,False)) then
            begin
              with DataSet as IBaseDbFilter do
                begin
                  aOldFilter := Filter;
                  Filter := '';
                  aOldLimit := Limit;
                  Limit := 1;
                end;
              FDataSet.Open;
              if CheckTable then
                if not AlterTable then
                  debugln('Altering Table "'+TableName+'" failed !');
              with DataSet as IBaseDbFilter do
                begin
                  Limit := aOldLimit;
                  Filter := aOldFilter;
                end;
            end;
        end;
    end;
end;
procedure TBaseDBDataset.DefineDefaultFields(aDataSet: TDataSet;HasMasterSource : Boolean);
begin
  with aDataSet as IBaseManageDB do
    begin
      if Assigned(ManagedIndexdefs) then
        begin
          if (ManagedFieldDefs.IndexOf('REF_ID') > -1) or HasMasterSource then
            ManagedIndexDefs.Add('REF_ID','REF_ID',[]);
          ManagedIndexDefs.Add('TIMESTAMPD','TIMESTAMPD',[]);
        end;
    end;
end;
procedure TBaseDBDataset.DefineUserFields(aDataSet: TDataSet);
var
  UserFields: TUserfielddefs;
begin
  with BaseApplication as IBaseDbInterface do
    begin
      UserFields := GetDB.Userfielddefs;
      if Assigned(UserFields) then
        begin
          if not UserFields.DataSet.Active then
            begin
              UserFields.CreateTable;
              UserFields.Open;
            end;
          with aDataSet as IBaseManageDB do
            UserFields.DataSet.Filter := Data.QuoteField('TTABLE')+'='+Data.QuoteValue(GetTableName);
          UserFields.DataSet.Filtered:=True;
          UserFields.DataSet.First;
          while not UserFields.DataSet.EOF do
            begin
              with aDataSet as IBaseManageDB do
                if Assigned(ManagedFieldDefs) then
                  with ManagedFieldDefs do
                    begin
                      if UserFields.FieldByName('TYPE').AsString = 'STRING' then
                        Add('U'+UserFields.FieldByName('TFIELD').AsString,ftString,UserFields.FieldByName('SIZE').AsInteger)
                      else if UserFields.FieldByName('TYPE').AsString = 'DATETIME' then
                        Add('U'+UserFields.FieldByName('TFIELD').AsString,ftDateTime,0)
                      ;
                    end;
              UserFields.DataSet.Next;
            end;
        end;
    end;
end;
procedure TBaseDBDataset.FillDefaults(aDataSet: TDataSet);
begin
  with BaseApplication as IBaseDbInterface do
    begin
      if aDataSet.FieldDefs.IndexOf('TIMESTAMPT') <> -1 then
        aDataSet.FieldByName('TIMESTAMPT').AsFloat:=frac(Now());
    end;
end;
procedure TBaseDBDataset.SetDisplayLabelName(aDataSet: TDataSet; aField,
  aName: string);
var
  Idx: LongInt;
begin
  Idx := aDataSet.FieldDefs.IndexOf(aField);
  if (Idx <> -1) and (aDataSet.Fields.Count>Idx) then
    aDataSet.Fields[Idx].DisplayLabel := aName
  else if (Idx <> -1) then
    aDataSet.FieldDefs[Idx].DisplayName:=aName;
end;
procedure TBaseDBDataset.SetDisplayLabels(aDataSet: TDataSet);
begin
  FDisplayLabelsWasSet := True;
  SetDisplayLabelName(aDataSet,'DUEDATE',strDue);
  SetDisplayLabelName(aDataSet,'ACCOUNTNO',strAccountNo);
  SetDisplayLabelName(aDataSet,'NAME',strName);
  SetDisplayLabelName(aDataSet,'PASSWORD',strPassword);
  SetDisplayLabelName(aDataSet,'TABLENAME',strTablename);
  SetDisplayLabelName(aDataSet,'TYPE',strType);
  SetDisplayLabelName(aDataSet,'LANGUAGE',strLanguage);
  SetDisplayLabelName(aDataSet,'ID',strID);
  SetDisplayLabelName(aDataSet,'STATUS',strStatus);
  SetDisplayLabelName(aDataSet,'ACTION',strAction);
  SetDisplayLabelName(aDataSet,'CHANGEDBY',strChangedBy);
  SetDisplayLabelName(aDataSet,'USER',strUser);
  SetDisplayLabelName(aDataSet,'READ',strRead);
  SetDisplayLabelName(aDataSet,'SENDER',strSender);
  SetDisplayLabelName(aDataSet,'SENDDATE',strDate);
  SetDisplayLabelName(aDataSet,'SENDTIME',strTime);
  SetDisplayLabelName(aDataSet,'SUBJECT',strSubject);
  SetDisplayLabelName(aDataSet,'MATCHCODE',strMatchCode);
  SetDisplayLabelName(aDataSet,'CURRENCY',strCurrency);
  SetDisplayLabelName(aDataSet,'PAYMENTTAR',strPaymentTarget);
  SetDisplayLabelName(aDataSet,'CRDATE',strCreatedDate);
  SetDisplayLabelName(aDataSet,'CHDATE',strChangedDate);
  SetDisplayLabelName(aDataSet,'CREATEDBY',strCreatedBy);
  SetDisplayLabelName(aDataSet,'CHANGEDBY',strChangedBy);
  SetDisplayLabelName(aDataSet,'SORTCODE',strSortCode);
  SetDisplayLabelName(aDataSet,'ACCOUNT',strAccount);
  SetDisplayLabelName(aDataSet,'INSTITUTE',strInstitute);
  SetDisplayLabelName(aDataSet,'DESCR',strDescription);
  SetDisplayLabelName(aDataSet,'DESC',strDescription);
  SetDisplayLabelName(aDataSet,'DATA',strData);
  SetDisplayLabelName(aDataSet,'EMPLOYEE',strEmployee);
  SetDisplayLabelName(aDataSet,'DEPARTMENT',strDepartment);
  SetDisplayLabelName(aDataSet,'POSITION',strPosition);
  SetDisplayLabelName(aDataSet,'VERSION',strVersion);
  SetDisplayLabelName(aDataSet,'BARCODE',strBarcode);
  SetDisplayLabelName(aDataSet,'SHORTTEXT',strShorttext);
  SetDisplayLabelName(aDataSet,'QUANTITYU',strQuantityUnit);
  SetDisplayLabelName(aDataSet,'VAT',strVat);
  SetDisplayLabelName(aDataSet,'UNIT',strUnit);
  SetDisplayLabelName(aDataSet,'VERSION',strVersion);
  SetDisplayLabelName(aDataSet,'PTYPE',strPriceType);
  SetDisplayLabelName(aDataSet,'PRICE',strPrice);
  SetDisplayLabelName(aDataSet,'MINCOUNT',strMinCount);
  SetDisplayLabelName(aDataSet,'MAXCOUNT',strMaxCount);
  SetDisplayLabelName(aDataSet,'VALIDFROM',strValidFrom);
  SetDisplayLabelName(aDataSet,'VALIDTO',strValidTo);
  SetDisplayLabelName(aDataSet,'PROBLEM',strProblem);
  SetDisplayLabelName(aDataSet,'ASSEMBLY',strAssembly);
  SetDisplayLabelName(aDataSet,'PART',strPart);
  SetDisplayLabelName(aDataSet,'STORAGEID',strID);
  SetDisplayLabelName(aDataSet,'STORNAME',strName);
  SetDisplayLabelName(aDataSet,'PLACE',strPlace);
  SetDisplayLabelName(aDataSet,'QUANTITY',strQuantity);
  SetDisplayLabelName(aDataSet,'SERIAL',strSerial);
  SetDisplayLabelName(aDataSet,'DATE',strDate);
  SetDisplayLabelName(aDataSet,'COMMISSION',strCommission);
  SetDisplayLabelName(aDataSet,'NUMBER',strNumber);
  SetDisplayLabelName(aDataSet,'ADDRNO',strNumber);
  SetDisplayLabelName(aDataSet,'CUSTNO',strCustomerNumber);
  SetDisplayLabelName(aDataSet,'CUSTNAME',strName);
  SetDisplayLabelName(aDataSet,'VATH',strHalfVat);                   //Halbe MwSt
  SetDisplayLabelName(aDataSet,'VATF',strFullVat);                   //Volle MwSt
  SetDisplayLabelName(aDataSet,'NETPRICE',strNetPrice);                //Nettopreis
  SetDisplayLabelName(aDataSet,'DISCOUNT',strDiscount);                //Rabatt
  SetDisplayLabelName(aDataSet,'GROSSPRICE',strGrossPrice);              //Bruttoprice
  SetDisplayLabelName(aDataSet,'DONE',strDone);
  SetDisplayLabelName(aDataSet,'ORDERNO',strOrderNo);
  SetDisplayLabelName(aDataSet,'TITLE',strTitle);
  SetDisplayLabelName(aDataSet,'ADDITIONAL',strAdditional);
  SetDisplayLabelName(aDataSet,'ADDRESS',strAdress);
  SetDisplayLabelName(aDataSet,'CITY',strCity);
  SetDisplayLabelName(aDataSet,'ZIP',strPostalCode);
  SetDisplayLabelName(aDataSet,'STATE',strState);
  SetDisplayLabelName(aDataSet,'COUNTRY',strLand);
  SetDisplayLabelName(aDataSet,'POBOX',strPostBox);
  SetDisplayLabelName(aDataSet,'POSNO',strPosNo);
  SetDisplayLabelName(aDataSet,'POSTYP',strType);
  SetDisplayLabelName(aDataSet,'TPOSNO',strTenderPosNo);                //Auschreibungsnummer
  SetDisplayLabelName(aDataSet,'IDENT',strIdent);
  SetDisplayLabelName(aDataSet,'TIDENT',strIdent);
  SetDisplayLabelName(aDataSet,'TVERSION',strVersion);
  SetDisplayLabelName(aDataSet,'TEXTTYPE',strTextTyp);
  SetDisplayLabelName(aDataSet,'TEXT',strText);
  SetDisplayLabelName(aDataSet,'REFERENCE',strReference);
  SetDisplayLabelName(aDataSet,'STORAGE',strStorage);
  SetDisplayLabelName(aDataSet,'ACTIONICON',' ');
  SetDisplayLabelName(aDataSet,'TIMESTAMPD',strDate);
  SetDisplayLabelName(aDataSet,'RESERVED',strReserved);
  SetDisplayLabelName(aDataSet,'PROPERTY',strProperty);
  SetDisplayLabelName(aDataSet,'VALUE',strValue);
  SetDisplayLabelName(aDataSet,'QUANTITYD',strQuantityDelivered);               //Menge Geliefert
  SetDisplayLabelName(aDataSet,'QUANTITYC',strQuantityCalculated);               //Menge berechnet
  SetDisplayLabelName(aDataSet,'PURCHASE',strPurchasePrice);                //Einkaufspreis
  SetDisplayLabelName(aDataSet,'SELLPRICE',strSellPrice);               //Verkaufspreis
  SetDisplayLabelName(aDataSet,'COMPRICE',strCommonPrice);                //Common Price
  SetDisplayLabelName(aDataSet,'POSPRICE',strPrice);                //Gesamtpreis
  SetDisplayLabelName(aDataSet,'GROSSPRICE',strGrossPrice);              //Bruttoprice
  SetDisplayLabelName(aDataSet,'ERROR',strProblem);
  SetDisplayLabelName(aDataSet,'BALLANCE',strBallance);
  SetDisplayLabelName(aDataSet,'VALUEDATE',strDate);
  SetDisplayLabelName(aDataSet,'PURPOSE',strPurpose);
  SetDisplayLabelName(aDataSet,'CHECKED',strChecked);
  SetDisplayLabelName(aDataSet,'CATEGORY',strCategory);
  SetDisplayLabelName(aDataSet,'CUSTOMER',strContact);
  SetDisplayLabelName(aDataSet,'PAYEDON',strPaid);
  SetDisplayLabelName(aDataSet,'DELIVERED',strDelivered);
  SetDisplayLabelName(aDataSet,'ACTIVE',strActive);
  SetDisplayLabelName(aDataSet,'START',strStart);
  SetDisplayLabelName(aDataSet,'END',strEnd);
  SetDisplayLabelName(aDataSet,'LINK',strLink);
  SetDisplayLabelName(aDataSet,'JOB',strTask);
  SetDisplayLabelName(aDataSet,'ISPAUSE',strPause);
  SetDisplayLabelName(aDataSet,'ODATE',strOriginaldate);
  SetDisplayLabelName(aDataSet,'NOTE',strNotes);
  SetDisplayLabelName(aDataSet,'PROJECT',strProject);
  SetDisplayLabelName(aDataSet,'SUMMARY',strSummary);
  SetDisplayLabelName(aDataSet,'OWNER',strOwner);
  SetDisplayLabelName(aDataSet,'AVALIBLE',strAvalible);
  SetDisplayLabelName(aDataSet,'ICON',' ');
end;
function TBaseDBDataset.GetBookmark: LargeInt;
begin
  if (not Assigned(Id)) or Id.IsNull then
    Result := 0
  else
    Result := Id.AsVariant;
end;
function TBaseDBDataset.GotoBookmark(aRec: Variant): Boolean;
begin
  Result := DataSet.Active;
  if Result then
    begin
      Result := DataSet.FieldByName('SQL_ID').AsVariant = aRec;
      if not Result then
        Result := DataSet.Locate('SQL_ID',aRec,[]);
    end;
end;
procedure TBaseDBDataset.FreeBookmark(aRec: Variant);
begin
end;
procedure TBaseDBDataset.DuplicateRecord(DoPost : Boolean);
var
  Data : array of string;
  i : integer;
  max : integer;
begin
  max := DataSet.fields.count -1;
  SetLength(data,max+1);

  // Copy the Record to the Array
  for i := 0 to max do
    Data[i] := DataSet.fields[i].AsString;

  DataSet.Append;
  for i := 0 to max do
    if  (DataSet.fields[i].DataType <> ftAutoInc)
    and (DataSet.FieldDefs[i].Name <> 'SQLITE_ID')
    and (DataSet.FieldDefs[i].Name <> 'SQL_ID')
    and (Data[i] <> '') then
      DataSet.fields[i].AsString := Data[i];
  if DoPost then
    DataSet.Post;
end;
procedure TBaseDBDataset.DisableChanges;
begin
  inc(FDoChange);
end;
procedure TBaseDBDataset.EnableChanges;
begin
  if FDoChange > 0 then
    dec(FDoChange);
end;
procedure TBaseDBDataset.Change;
begin
  if FDoChange > 0 then exit;
  FChanged := True;
  if Owner is TBaseDbDataSet then TBaseDbDataSet(Owner).Change;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;
procedure TBaseDBDataset.UnChange;
begin
  fChanged:=False;
end;
procedure TBaseDBDataset.CascadicPost;
begin
  if CanEdit then
    Post;
  FChanged := False;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;
procedure TBaseDBDataset.CascadicCancel;
begin
  if (FDataSet.State = dsEdit) or (FDataSet.State = dsInsert) then
    FDataSet.Cancel;
  FChanged := False;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;
initialization
end.
