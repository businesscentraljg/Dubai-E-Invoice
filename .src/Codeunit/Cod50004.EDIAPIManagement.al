codeunit 50004 "EDI API Management"
{
    procedure SendDocument(ConfigType: Integer; ConfigId: Integer; ControlNumber: Text; DocumentContent: Text; var SubmissionId: Text)
    var
        Request: JsonObject;
        Documents: JsonArray;
        Document: JsonObject;
        ResponseText: Text;
        ResponseArray: JsonArray;
        ResponseToken: JsonToken;
        ResponseObj: JsonObject;
    begin
        Document.Add('ControlNumber', ControlNumber);
        Document.Add('Content', DocumentContent);
        Document.Add('CompressType', 'NONE');
        Documents.Add(Document);

        Request.Add('ConfigType', ConfigType);
        Request.Add('ConfigId', ConfigId);
        Request.Add('Documents', Documents);

        ResponseText := PostAuthorizedFromObject('/api/v1/documents/send', Request);
        if not ResponseArray.ReadFrom(ResponseText) then
            exit;

        if ResponseArray.Count() = 0 then
            exit;

        ResponseArray.Get(0, ResponseToken);
        ResponseObj := ResponseToken.AsObject();
        SubmissionId := GetText(ResponseObj, 'SubmissionId');
    end;

    procedure CheckSentDocument(ConfigType: Integer; ConfigId: Integer; ControlNumber: Text; var Status: Boolean; var SubmissionId: Text)
    var
        Request: JsonObject;
        ResponseText: Text;
        ResponseObj: JsonObject;
        StatusToken: JsonToken;
    begin
        Request.Add('ConfigId', ConfigId);
        Request.Add('ConfigType', ConfigType);
        Request.Add('ControlNumber', ControlNumber);

        ResponseText := PostAuthorizedFromObject('/api/v1/documents/sent/check', Request);
        if not ResponseObj.ReadFrom(ResponseText) then
            Error('Invalid response from sent check endpoint.');

        if ResponseObj.Get('Status', StatusToken) then
            Status := StatusToken.AsValue().AsBoolean();

        SubmissionId := GetText(ResponseObj, 'SubmissionId');
    end;

    procedure ImportSubscriptions()
    var
        ResponseText: Text;
        JsonArr: JsonArray;
        ItemToken: JsonToken;
        JsonObj: JsonObject;
        I: Integer;
    begin
        ResponseText := PostAuthorized('/api/v1/subscription', '{}');
        if not JsonArr.ReadFrom(ResponseText) then
            Error('Invalid subscription response.');

        for I := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(I, ItemToken);
            JsonObj := ItemToken.AsObject();
            UpsertSubscription(JsonObj);
        end;
    end;

    procedure PullReceivedDocuments()
    var
        Setup: Record "Invoice Setup";
        Request: JsonObject;
        ResponseText: Text;
        JsonArr: JsonArray;
        ItemToken: JsonToken;
        JsonObj: JsonObject;
        I: Integer;
    begin
        GetSetup(Setup);
        EnsureDefaultConfig(Setup);

        Request.Add('ConfigType', Setup."Default Config Type");
        Request.Add('ConfigId', Setup."Default Config Id");
        Request.Add('SpecificationBusinessType', Setup."Default Business Type");
        if Setup."Receive Top" > 0 then
            Request.Add('Top', Setup."Receive Top");

        ResponseText := PostAuthorizedFromObject('/api/v1/documents/receive', Request);
        if not JsonArr.ReadFrom(ResponseText) then
            Error('Invalid documents receive response.');

        for I := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(I, ItemToken);
            JsonObj := ItemToken.AsObject();
            UpsertReceivedDocument(JsonObj, Setup."Default Business Type");
        end;
    end;

    procedure ConfirmReceivedDocuments()
    var
        Received: Record "Received Document Stg";
        Request: JsonObject;
        Documents: JsonArray;
        Document: JsonObject;
        ResponseText: Text;
        ResponseArr: JsonArray;
        ResponseToken: JsonToken;
        ResponseObj: JsonObject;
    begin
        Received.SetRange(Confirmed, false);
        if not Received.FindSet() then
            exit;

        repeat
            Clear(Document);
            Document.Add('WebDocId', Received."Web Doc Id");
            Document.Add('ConfigType', Received."Config Type");
            Document.Add('ConfigId', Received."Config Id");
            Documents.Add(Document);
        until Received.Next() = 0;

        Request.Add('Documents', Documents);
        ResponseText := PostAuthorizedFromObject('/api/v1/status/received/confirm', Request);
        if not ResponseArr.ReadFrom(ResponseText) then
            exit;

        foreach ResponseToken in ResponseArr do begin
            ResponseObj := ResponseToken.AsObject();
            MarkReceivedConfirmed(
              GetInt(ResponseObj, 'ConfigType'),
              GetInt(ResponseObj, 'ConfigId'),
              GetInt(ResponseObj, 'WebDocId'),
              GetInt(ResponseObj, 'Status'));
        end;
    end;

    procedure PullSentDetails()
    var
        Setup: Record "Invoice Setup";
        Request: JsonObject;
        ResponseText: Text;
        JsonArr: JsonArray;
        ItemToken: JsonToken;
        JsonObj: JsonObject;
        I: Integer;
    begin
        GetSetup(Setup);
        EnsureDefaultConfig(Setup);

        Request.Add('ConfigType', Setup."Default Config Type");
        Request.Add('ConfigId', Setup."Default Config Id");
        Request.Add('SpecificationBusinessType', Setup."Default Business Type");

        ResponseText := PostAuthorizedFromObject('/api/v1/documents/sent/details', Request);
        if not JsonArr.ReadFrom(ResponseText) then
            Error('Invalid sent details response.');

        for I := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(I, ItemToken);
            JsonObj := ItemToken.AsObject();
            UpsertSentDocumentDetails(JsonObj);
        end;
    end;

    procedure ConfirmSentDetails()
    var
        SentDoc: Record "Sent Documents";
        Request: JsonObject;
        Documents: JsonArray;
        Document: JsonObject;
        ResponseText: Text;
        ResponseArr: JsonArray;
        ResponseToken: JsonToken;
        ResponseObj: JsonObject;
    begin
        SentDoc.SetRange(Confirmed, false);
        if not SentDoc.FindSet() then
            exit;

        repeat
            Clear(Document);
            Document.Add('WebDocId', SentDoc."Web Doc Id");
            Document.Add('ConfigType', SentDoc."Config Type");
            Document.Add('ConfigId', SentDoc."Config Id");
            Documents.Add(Document);
        until SentDoc.Next() = 0;

        Request.Add('Documents', Documents);
        ResponseText := PostAuthorizedFromObject('/api/v1/status/sent/details/confirm', Request);
        if not ResponseArr.ReadFrom(ResponseText) then
            exit;

        foreach ResponseToken in ResponseArr do begin
            ResponseObj := ResponseToken.AsObject();
            MarkSentDetailConfirmed(
              GetInt(ResponseObj, 'ConfigType'),
              GetInt(ResponseObj, 'ConfigId'),
              GetInt(ResponseObj, 'WebDocId'),
              GetInt(ResponseObj, 'Status'));
        end;
    end;

    procedure PullSentStatuses()
    var
        Setup: Record "Invoice Setup";
        Request: JsonObject;
        ResponseText: Text;
        JsonArr: JsonArray;
        ItemToken: JsonToken;
        JsonObj: JsonObject;
        I: Integer;
    begin
        GetSetup(Setup);
        EnsureDefaultConfig(Setup);

        Request.Add('SpecificationBusinessType', Setup."Default Business Type");
        Request.Add('ConfigType', Setup."Default Config Type");
        Request.Add('ConfigId', Setup."Default Config Id");
        Request.Add('LanguageCode', 'en');

        ResponseText := PostAuthorizedFromObject('/api/v1/status/sent', Request);
        if not JsonArr.ReadFrom(ResponseText) then
            Error('Invalid sent status response.');

        for I := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(I, ItemToken);
            JsonObj := ItemToken.AsObject();
            UpsertSentStatus(JsonObj);
        end;
    end;

    procedure ConfirmSentStatuses()
    var
        SentStatus: Record "Sent Status Stg";
        Request: JsonObject;
        StatusesToConfirm: JsonArray;
        StatusObj: JsonObject;
        ResponseText: Text;
        ResponseArr: JsonArray;
        ResponseToken: JsonToken;
        ResponseObj: JsonObject;
    begin
        SentStatus.SetRange(Confirmed, false);
        if not SentStatus.FindSet() then
            exit;

        repeat
            Clear(StatusObj);
            StatusObj.Add('WebStatusId', SentStatus."Web Status Id");
            StatusObj.Add('ConfigType', SentStatus."Config Type");
            StatusObj.Add('ConfigId', SentStatus."Config Id");
            StatusesToConfirm.Add(StatusObj);
        until SentStatus.Next() = 0;

        Request.Add('StatusesToConfirm', StatusesToConfirm);
        ResponseText := PostAuthorizedFromObject('/api/v1/status/sent/confirm', Request);
        if not ResponseArr.ReadFrom(ResponseText) then
            exit;

        foreach ResponseToken in ResponseArr do begin
            ResponseObj := ResponseToken.AsObject();
            MarkSentStatusConfirmed(
              GetInt(ResponseObj, 'ConfigType'),
              GetInt(ResponseObj, 'ConfigId'),
              GetBigInt(ResponseObj, 'WebStatusId'),
              GetInt(ResponseObj, 'Status'));
        end;
    end;

    procedure PullDocumentErrors()
    var
        Setup: Record "Invoice Setup";
        SentDoc: Record "Sent Documents";
        Request: JsonObject;
        Docs: JsonArray;
        DocObj: JsonObject;
        ResponseText: Text;
        ResponseArr: JsonArray;
        ResponseToken: JsonToken;
        ResponseObj: JsonObject;
    begin
        GetSetup(Setup);
        EnsureDefaultConfig(Setup);

        SentDoc.SetRange("Config Type", Setup."Default Config Type");
        SentDoc.SetRange("Config Id", Setup."Default Config Id");
        if not SentDoc.FindSet() then
            exit;

        repeat
            Clear(DocObj);
            DocObj.Add('ConfigId', SentDoc."Config Id");
            DocObj.Add('ConfigType', SentDoc."Config Type");
            DocObj.Add('WebDocId', SentDoc."Web Doc Id");
            Docs.Add(DocObj);
        until SentDoc.Next() = 0;

        Request.Add('Documents', Docs);
        ResponseText := PostAuthorizedFromObject('/api/v1/status/error', Request);
        if not ResponseArr.ReadFrom(ResponseText) then
            exit;

        foreach ResponseToken in ResponseArr do begin
            ResponseObj := ResponseToken.AsObject();
            UpsertDocumentError(
              Setup."Default Config Type",
              Setup."Default Config Id",
              ResponseObj);
        end;
    end;

    local procedure UpsertSubscription(JsonObj: JsonObject)
    var
        SubRec: Record "User Subscription";
        SourcePartner: JsonObject;
        DestPartner: JsonObject;
        SourceToken: JsonToken;
        DestToken: JsonToken;
        ConfigId: Integer;
    begin
        ConfigId := GetInt(JsonObj, 'ConfigId');
        if ConfigId = 0 then
            exit;

        if not SubRec.Get(ConfigId) then begin
            SubRec.Init();
            SubRec."Config Id" := ConfigId;
            SubRec.Insert();
        end;

        SubRec."Config Type" := GetInt(JsonObj, 'ConfigType');
        SubRec."Spec Business Type" := GetText(JsonObj, 'SpecificationBusinessType');
        SubRec."Spec Type" := GetText(JsonObj, 'SpecificationType');
        SubRec."Spec Version" := GetText(JsonObj, 'SpecificationVersion');
        SubRec."Spec Standard" := GetText(JsonObj, 'SpecificationStandard');
        SubRec."Subscription Test" := GetBool(JsonObj, 'SubscriptionTest');
        SubRec."Subscription Direction" := GetBool(JsonObj, 'SubscriptionDirection');

        if JsonObj.Get('SourcePartner', SourceToken) then begin
            SourcePartner := SourceToken.AsObject();
            SubRec."Source Name" := GetText(SourcePartner, 'Name');
            SubRec."Source Alias" := GetText(SourcePartner, 'Alias');
            SubRec."Source Qualifier" := GetText(SourcePartner, 'Qualifier');
        end;

        if JsonObj.Get('DestinationPartner', DestToken) then begin
            DestPartner := DestToken.AsObject();
            SubRec."Destination Name" := GetText(DestPartner, 'Name');
            SubRec."Destination Alias" := GetText(DestPartner, 'Alias');
            SubRec."Destination Qualifier" := GetText(DestPartner, 'Qualifier');
        end;

        SubRec.Modify();
    end;

    local procedure UpsertReceivedDocument(JsonObj: JsonObject; BusinessType: Code[20])
    var
        Stg: Record "Received Document Stg";
        SourceToken: JsonToken;
        SourceObj: JsonObject;
        ConfigType: Integer;
        ConfigId: Integer;
        WebDocId: Integer;
        DocumentContent: Text;
        RawText: Text;
        OutStr: OutStream;
    begin
        ConfigType := GetInt(JsonObj, 'ConfigType');
        ConfigId := GetInt(JsonObj, 'ConfigId');
        WebDocId := GetInt(JsonObj, 'WebDocId');
        if (ConfigId = 0) or (WebDocId = 0) then
            exit;

        if not FindReceivedDocument(Stg, ConfigType, ConfigId, WebDocId) then begin
            Stg.Init();
            Stg."Config Type" := ConfigType;
            Stg."Config Id" := ConfigId;
            Stg."Web Doc Id" := WebDocId;
            Stg.Insert();
        end;

        Stg."Message Id" := GetGuid(JsonObj, 'MessageId');
        Stg."Compression Type" := CopyStr(GetText(JsonObj, 'CompressionType'), 1, MaxStrLen(Stg."Compression Type"));
        Stg."Specification Business Type" := BusinessType;
        Stg."Processing Date" := GetDateTime(JsonObj, 'ProcessingDate');

        if JsonObj.Get('SourcePartner', SourceToken) then begin
            SourceObj := SourceToken.AsObject();
            Stg."Source Name" := CopyStr(GetText(SourceObj, 'Name'), 1, MaxStrLen(Stg."Source Name"));
            Stg."Source Alias" := CopyStr(GetText(SourceObj, 'Alias'), 1, MaxStrLen(Stg."Source Alias"));
            Stg."Source Qualifier" := CopyStr(GetText(SourceObj, 'Qualifier'), 1, MaxStrLen(Stg."Source Qualifier"));
        end;

        DocumentContent := GetText(JsonObj, 'DocumentContent');
        if DocumentContent <> '' then begin
            //WriteBlobText(Stg."Document Content", DocumentContent);
            Stg."Document Content".CreateOutStream(OutStr);
            OutStr.WriteText(DocumentContent);
        end;
        JsonObj.WriteTo(RawText);
        //WriteBlobText(Stg."Raw JSON", RawText);
        Stg."Raw JSON".CreateOutStream(OutStr);
        OutStr.WriteText(RawText);
        Stg.Modify();
    end;

    local procedure UpsertSentDocumentDetails(JsonObj: JsonObject)
    var
        SentDoc: Record "Sent Documents";
        DestinationToken: JsonToken;
        DestinationObj: JsonObject;
        ConfigType: Integer;
        ConfigId: Integer;
        WebDocId: Integer;
        RawText: Text;
        OutStr: OutStream;
    begin
        ConfigType := GetInt(JsonObj, 'ConfigType');
        ConfigId := GetInt(JsonObj, 'ConfigId');
        WebDocId := GetInt(JsonObj, 'WebDocId');
        if (ConfigId = 0) or (WebDocId = 0) then
            exit;

        if not FindSentDocument(SentDoc, ConfigType, ConfigId, WebDocId) then begin
            SentDoc.Init();
            SentDoc."Config Type" := ConfigType;
            SentDoc."Config Id" := ConfigId;
            SentDoc."Web Doc Id" := WebDocId;
            SentDoc.Insert();
        end;

        SentDoc."Message Id" := GetGuid(JsonObj, 'MessageId');
        SentDoc."Processing Status" := GetBool(JsonObj, 'ProcessingStatus');
        SentDoc."Submission Id" := GetGuid(JsonObj, 'SubmissionId');
        SentDoc."Control Number" := CopyStr(GetText(JsonObj, 'ControlNumber'), 1, MaxStrLen(SentDoc."Control Number"));
        SentDoc."Compression Type" := CopyStr(GetText(JsonObj, 'CompressionType'), 1, MaxStrLen(SentDoc."Compression Type"));
        SentDoc."Processing Date" := GetDateTime(JsonObj, 'ProcessingDate');

        if JsonObj.Get('DestinationPartner', DestinationToken) then begin
            DestinationObj := DestinationToken.AsObject();
            SentDoc."Destination Name" := CopyStr(GetText(DestinationObj, 'Name'), 1, MaxStrLen(SentDoc."Destination Name"));
            SentDoc."Destination Alias" := CopyStr(GetText(DestinationObj, 'Alias'), 1, MaxStrLen(SentDoc."Destination Alias"));
            SentDoc."Destination Qualifier" := CopyStr(GetText(DestinationObj, 'Qualifier'), 1, MaxStrLen(SentDoc."Destination Qualifier"));
        end;

        JsonObj.WriteTo(RawText);
        //WriteBlobText(SentDoc."Raw JSON", RawText);
        SentDoc."Raw JSON".CreateOutStream(OutStr);
        OutStr.WriteText(RawText);
        SentDoc.Modify();
    end;

    local procedure UpsertSentStatus(JsonObj: JsonObject)
    var
        SentStatus: Record "Sent Status Stg";
        ConfigType: Integer;
        ConfigId: Integer;
        WebStatusId: BigInteger;
        RawText: Text;
        OutStr: OutStream;
    begin
        ConfigType := GetInt(JsonObj, 'ConfigType');
        ConfigId := GetInt(JsonObj, 'ConfigId');
        WebStatusId := GetBigInt(JsonObj, 'WebStatusId');
        if (ConfigId = 0) or (WebStatusId = 0) then
            exit;

        if not FindSentStatus(SentStatus, ConfigType, ConfigId, WebStatusId) then begin
            SentStatus.Init();
            SentStatus."Config Type" := ConfigType;
            SentStatus."Config Id" := ConfigId;
            SentStatus."Web Status Id" := WebStatusId;
            SentStatus.Insert();
        end;

        SentStatus."Web Doc Id" := GetInt(JsonObj, 'WebDocId');
        SentStatus."Message Id" := GetGuid(JsonObj, 'MessageId');
        SentStatus."Status Type Id" := GetInt(JsonObj, 'StatusTypeId');
        SentStatus."Status Date" := GetDateTime(JsonObj, 'StatusDate');
        SentStatus.Description := CopyStr(GetText(JsonObj, 'Description'), 1, MaxStrLen(SentStatus.Description));
        SentStatus."Transport Type" := CopyStr(GetText(JsonObj, 'TransportType'), 1, MaxStrLen(SentStatus."Transport Type"));
        SentStatus.Type := CopyStr(GetText(JsonObj, 'Type'), 1, MaxStrLen(SentStatus.Type));
        SentStatus.Stage := CopyStr(GetText(JsonObj, 'Stage'), 1, MaxStrLen(SentStatus.Stage));
        SentStatus.State := CopyStr(GetText(JsonObj, 'State'), 1, MaxStrLen(SentStatus.State));
        SentStatus.Code := CopyStr(GetText(JsonObj, 'Code'), 1, MaxStrLen(SentStatus.Code));

        JsonObj.WriteTo(RawText);
        //WriteBlobText(SentStatus."Raw JSON", RawText);
        SentStatus."Raw JSON".CreateOutStream(OutStr);
        OutStr.WriteText(RawText);
        SentStatus.Modify();
    end;

    local procedure UpsertDocumentError(ConfigType: Integer; ConfigId: Integer; JsonObj: JsonObject)
    var
        ErrStg: Record "Document Error Stg";
        WebDocId: Integer;
        RawText: Text;
        OutStr: OutStream;
    begin
        WebDocId := GetInt(JsonObj, 'WebDocId');
        if (ConfigId = 0) or (WebDocId = 0) then
            exit;

        if not FindDocumentError(ErrStg, ConfigType, ConfigId, WebDocId) then begin
            ErrStg.Init();
            ErrStg."Config Type" := ConfigType;
            ErrStg."Config Id" := ConfigId;
            ErrStg."Web Doc Id" := WebDocId;
            ErrStg.Insert();
        end;

        ErrStg."Processing Status" := GetBool(JsonObj, 'ProcessingStatus');
        ErrStg."Error Description" := CopyStr(GetText(JsonObj, 'ErrorDescription'), 1, MaxStrLen(ErrStg."Error Description"));
        ErrStg."Fetched At" := CurrentDateTime();
        // WriteBlobText(ErrStg."Error Details", GetErrorDetails(JsonObj));
        ErrStg."Error Details".CreateOutStream(OutStr);
        OutStr.WriteText(GetErrorDetails(JsonObj));
        JsonObj.WriteTo(RawText);
        //WriteBlobText(ErrStg."Raw JSON", RawText);
        ErrStg."Raw JSON".CreateOutStream(OutStr);
        OutStr.WriteText(RawText);
        ErrStg.Modify();
    end;

    local procedure MarkReceivedConfirmed(ConfigType: Integer; ConfigId: Integer; WebDocId: Integer; Status: Integer)
    var
        Received: Record "Received Document Stg";
    begin
        if Status <> 1 then
            exit;

        if not FindReceivedDocument(Received, ConfigType, ConfigId, WebDocId) then
            exit;

        Received.Confirmed := true;
        Received."Confirmed At" := CurrentDateTime();
        Received.Modify();
    end;

    local procedure MarkSentDetailConfirmed(ConfigType: Integer; ConfigId: Integer; WebDocId: Integer; Status: Integer)
    var
        SentDoc: Record "Sent Documents";
    begin
        if Status <> 1 then
            exit;

        if not FindSentDocument(SentDoc, ConfigType, ConfigId, WebDocId) then
            exit;

        SentDoc.Confirmed := true;
        SentDoc."Confirmed At" := CurrentDateTime();
        SentDoc.Modify();
    end;

    local procedure MarkSentStatusConfirmed(ConfigType: Integer; ConfigId: Integer; WebStatusId: BigInteger; Status: Integer)
    var
        SentStatus: Record "Sent Status Stg";
    begin
        if Status <> 1 then
            exit;

        if not FindSentStatus(SentStatus, ConfigType, ConfigId, WebStatusId) then
            exit;

        SentStatus.Confirmed := true;
        SentStatus."Confirmed At" := CurrentDateTime();
        SentStatus.Modify();
    end;

    local procedure PostAuthorizedFromObject(Endpoint: Text; RequestJson: JsonObject): Text
    var
        RequestBody: Text;
    begin
        RequestJson.WriteTo(RequestBody);
        exit(PostAuthorized(Endpoint, RequestBody));
    end;

    local procedure PostAuthorized(Endpoint: Text; RequestBody: Text): Text
    var
        Setup: Record "Invoice Setup";
        Auth: Codeunit "Authenticate Management";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        ResponseText: Text;
        Token: Text;
    begin
        GetSetup(Setup);
        Token := Auth.GetValidToken();

        Request.Method := 'POST';
        Request.SetRequestUri(Setup."Base URL" + Endpoint);

        Content.WriteFrom(RequestBody);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Request.Content := Content;

        Request.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Authorization', 'Bearer ' + Token);
        Headers.Add('Accept', 'application/json');

        if not Client.Send(Request, Response) then
            Error('Failed to call endpoint %1.', Endpoint);

        Response.Content.ReadAs(ResponseText);
        if not Response.IsSuccessStatusCode() then
            Error('Request failed for %1. HTTP %2. %3', Endpoint, Response.HttpStatusCode(), ResponseText);

        if Setup."Show Message" then
            Message(ResponseText);

        exit(ResponseText);
    end;

    local procedure FindReceivedDocument(var Received: Record "Received Document Stg"; ConfigType: Integer; ConfigId: Integer; WebDocId: Integer): Boolean
    begin
        Received.Reset();
        Received.SetRange("Config Type", ConfigType);
        Received.SetRange("Config Id", ConfigId);
        Received.SetRange("Web Doc Id", WebDocId);
        exit(Received.FindFirst());
    end;

    local procedure FindSentDocument(var SentDoc: Record "Sent Documents"; ConfigType: Integer; ConfigId: Integer; WebDocId: Integer): Boolean
    begin
        SentDoc.Reset();
        SentDoc.SetRange("Config Type", ConfigType);
        SentDoc.SetRange("Config Id", ConfigId);
        SentDoc.SetRange("Web Doc Id", WebDocId);
        exit(SentDoc.FindFirst());
    end;

    local procedure FindSentStatus(var SentStatus: Record "Sent Status Stg"; ConfigType: Integer; ConfigId: Integer; WebStatusId: BigInteger): Boolean
    begin
        SentStatus.Reset();
        SentStatus.SetRange("Config Type", ConfigType);
        SentStatus.SetRange("Config Id", ConfigId);
        SentStatus.SetRange("Web Status Id", WebStatusId);
        exit(SentStatus.FindFirst());
    end;

    local procedure FindDocumentError(var ErrStg: Record "Document Error Stg"; ConfigType: Integer; ConfigId: Integer; WebDocId: Integer): Boolean
    begin
        ErrStg.Reset();
        ErrStg.SetRange("Config Type", ConfigType);
        ErrStg.SetRange("Config Id", ConfigId);
        ErrStg.SetRange("Web Doc Id", WebDocId);
        exit(ErrStg.FindFirst());
    end;

    local procedure EnsureDefaultConfig(Setup: Record "Invoice Setup")
    begin
        if Setup."Default Config Id" = 0 then
            Error('Default Config Id must be set in Invoice Setup.');
    end;

    local procedure GetSetup(var Setup: Record "Invoice Setup")
    begin
        if Setup.Get() then
            exit;
        if Setup.Get('') then
            exit;
        Error('Invoice Setup not found.');
    end;

    local procedure GetText(JObj: JsonObject; Name: Text): Text
    var
        Token: JsonToken;
    begin
        if JObj.Get(Name, Token) then
            exit(Token.AsValue().AsText());
    end;

    local procedure GetInt(JObj: JsonObject; Name: Text): Integer
    var
        Token: JsonToken;
    begin
        if JObj.Get(Name, Token) then
            exit(Token.AsValue().AsInteger());
    end;

    local procedure GetBigInt(JObj: JsonObject; Name: Text): BigInteger
    var
        Token: JsonToken;
        ValueText: Text;
        Value: BigInteger;
    begin
        if not JObj.Get(Name, Token) then
            exit(0);

        ValueText := Token.AsValue().AsText();
        if Evaluate(Value, ValueText) then
            exit(Value);
    end;

    local procedure GetBool(JObj: JsonObject; Name: Text): Boolean
    var
        Token: JsonToken;
    begin
        if JObj.Get(Name, Token) then
            exit(Token.AsValue().AsBoolean());
    end;

    local procedure GetDateTime(JObj: JsonObject; Name: Text): DateTime
    var
        Token: JsonToken;
    begin
        if JObj.Get(Name, Token) then
            exit(Token.AsValue().AsDateTime());
    end;

    local procedure GetGuid(JObj: JsonObject; Name: Text): Guid
    var
        Token: JsonToken;
        GuidText: Text;
        GuidValue: Guid;
    begin
        if not JObj.Get(Name, Token) then
            exit(GuidValue);

        GuidText := Token.AsValue().AsText();
        if GuidText = '' then
            exit(GuidValue);

        if Evaluate(GuidValue, GuidText) then
            exit(GuidValue);
    end;

    local procedure GetErrorDetails(JObj: JsonObject): Text
    var
        Token: JsonToken;
        ResultText: Text;
    begin
        if not JObj.Get('ErrorDetails', Token) then
            exit('');

        Token.WriteTo(ResultText);
        exit(ResultText);
    end;

    // local procedure WriteBlobText(var BlobField: Blob; Value: Text)
    // var
    //     OutStr: OutStream;
    // begin
    //     BlobField.CreateOutStream(OutStr);
    //     OutStr.WriteText(Value);
    // end;
}
