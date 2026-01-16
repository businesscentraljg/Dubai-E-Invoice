codeunit 50003 "Subscription API Import"
{
    procedure ImportSubscriptions()
    var
        Setup: Record "Invoice Setup";
        Auth: Codeunit "Authenticate Management";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ReqHeaders: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseText: Text;
        ItemToken: JsonToken;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        Token: Text;
        I: Integer;
    begin
        // 1️⃣ Read Setup
        if not Setup.Get() then
            Error('Integration Setup not found.');

        Token := Auth.GetValidToken();

        // 2️⃣ Build POST Request
        Request.Method := 'POST';
        Request.SetRequestUri(Setup."Base URL" + '/api/v1/subscription');

        Request.GetHeaders(ReqHeaders);
        ReqHeaders.Clear();
        ReqHeaders.Add('Authorization', 'Bearer ' + Token);
        ReqHeaders.Add('Accept', 'application/json');

        // POST body
        Content.WriteFrom('{}');
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.Content := Content;

        // 3️⃣ Send Request
        Client.Send(Request, Response);

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            Error('Subscription API failed. Status: %1, Response: %2', Response.HttpStatusCode(), ResponseText);
        end else begin
            Response.Content.ReadAs(ResponseText);
            if Setup."Show Message" then
                Message(ResponseText);
        end;

        if not JsonArr.ReadFrom(ResponseText) then
            Error('Invalid JSON response from Subscription API.');

        // 5️⃣ Loop & Upsert
        for I := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(I, ItemToken);
            JsonObj := ItemToken.AsObject();
            IpsertSubscription(JsonObj);
        end;
    end;

    local procedure IpsertSubscription(JsonObj: JsonObject)
    var
        SubRec: Record Subscription;
        SourcePartner: JsonObject;
        DestPartner: JsonObject;
        ConfigId: Integer;
        IsNew: Boolean;
        SourcePartnerToken: JsonToken;
        DestPartnerToken: JsonToken;

    begin
        ConfigId := GetInt(JsonObj, 'ConfigId');

        if SubRec.Get(ConfigId) then
            IsNew := false
        else begin
            SubRec.Init();
            SubRec."Config Id" := ConfigId;
            IsNew := true;
        end;

        SubRec."Config Type" := GetInt(JsonObj, 'ConfigType');
        SubRec."Spec Business Type" := GetText(JsonObj, 'SpecificationBusinessType');
        SubRec."Spec Type" := GetText(JsonObj, 'SpecificationType');
        SubRec."Spec Version" := GetText(JsonObj, 'SpecificationVersion');
        SubRec."Spec Standard" := GetText(JsonObj, 'SpecificationStandard');
        SubRec."Subscription Test" := GetBool(JsonObj, 'SubscriptionTest');
        SubRec."Subscription Direction" := GetBool(JsonObj, 'SubscriptionDirection');


        if JsonObj.Get('SourcePartner', SourcePartnerToken) then begin
            SourcePartner := SourcePartnerToken.AsObject();
            SubRec."Source Name" := GetText(SourcePartner, 'Name');
            SubRec."Source Alias" := GetText(SourcePartner, 'Alias');
            SubRec."Source Qualifier" := GetText(SourcePartner, 'Qualifier');
        end;

        // Destination Partner
        if JsonObj.Get('DestinationPartner', DestPartnerToken) then begin
            DestPartner := DestPartnerToken.AsObject();
            SubRec."Destination Name" := GetText(DestPartner, 'Name');
            SubRec."Destination Alias" := GetText(DestPartner, 'Alias');
            SubRec."Destination Qualifier" := GetText(DestPartner, 'Qualifier');
        end;

        if IsNew then
            SubRec.Insert()
        else
            SubRec.Modify();
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

    local procedure GetBool(JObj: JsonObject; Name: Text): Boolean
    var
        Token: JsonToken;
    begin
        if JObj.Get(Name, Token) then
            exit(Token.AsValue().AsBoolean());
    end;
}
