codeunit 50001 "Invoice"
{
    Permissions = tabledata "Sales Invoice Header" = RIMD;
    procedure SendPostedSalesInvoice(var SIH: Record "Sales Invoice Header")
    var
        AuthCU: Codeunit "Authenticate Management";
        UserSubscription: Record "User Subscription";
        UserSetup: Record "User Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        Setup: Record "Invoice Setup";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        Token: Text;
        XmlBody: Text;
        JsonBody: Text;
        JsonObj: JsonObject;
        DocsArray: JsonArray;
        DocObj: JsonObject;
        ResponseText: Text;
        ControlNumber: Text;
    begin
        if SIH."Invoice Send" then
            Error('Invoice %1 already sent.', SIH."No.");

        if not Setup.Get() then
            Error('Invoice Setup not found.');

        // Token
        Token := AuthCU.GetValidToken();

        if not UserSetup.Get(UserId) then
            Error('User Setup not found for %1.', UserId);

        if UserSetup."Subscription Config Id" = 0 then
            Error('Subscription Config Id not defined in User Setup.');

        if not UserSubscription.Get(UserSetup."Subscription Config Id") then
            Error('No Subscription found for Config Id %1.', UserSetup."Subscription Config Id");
        // XML
        XmlBody := GenerateInvoiceXML(SIH);
        // JSON

        ControlNumber := Format(CreateGuid());

        DocObj.Add('ControlNumber', ControlNumber);
        DocObj.Add('Content', XmlBody);
        DocObj.Add('CompressType', 'NONE');

        DocsArray.Add(DocObj);

        JsonObj.Add('ConfigType', UserSubscription."Config Type");
        JsonObj.Add('ConfigId', UserSetup."Subscription Config Id");
        JsonObj.Add('Documents', DocsArray);
        JsonObj.WriteTo(JsonBody);

        if Setup."Show Message" then
            Message(JsonBody);

        // HTTP Content
        TempBlob.CreateOutStream(OutStr);
        OutStr.Write(JsonBody);
        TempBlob.CreateInStream(InStr);

        Content.WriteFrom(JsonBody);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');


        // Request
        Request.Method := 'POST';
        Request.SetRequestUri(Setup."Base URL" + '/api/v1/documents/send');
        Request.Content := Content;

        Request.GetHeaders(Headers);


        Headers.Remove('Authorization');
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));

        Headers.Remove('Accept');
        Headers.Add('Accept', 'application/json');

        // Send
        Client.Send(Request, Response);

        If not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            Error('Send failed. HTTP %1\%2', Response.HttpStatusCode(), ResponseText);
        end else begin
            Response.Content.ReadAs(ResponseText);
            if Setup."Show Message" then
                Message(ResponseText);

            SIH."Invoice Send" := true;
            SIH."Invoice Send DateTime" := CurrentDateTime();
            SIH."Control Number" := ControlNumber;
            SIH.Modify();
        end;
    end;

    local procedure GenerateInvoiceXML(SIH: Record "Sales Invoice Header"): Text
    var
        InvoiceXmlPort: XmlPort Invoice;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        XmlText: Text;
        JO: JsonObject;
    begin
        InvoiceXmlPort.SetParameter(SIH."No.");
        TempBlob.CreateOutStream(OutStr);
        InvoiceXmlPort.SetDestination(OutStr);
        InvoiceXmlPort.Export();
        TempBlob.CreateInStream(InStr);
        InStr.Read(XmlText);
        exit(XmlText);
    end;

    procedure CheckPostedSalesInvoiceSentStatus(var SIH: Record "Sales Invoice Header")
    var
        Setup: Record "Invoice Setup";
        UserSetup: Record "User Setup";
        UserSubscription: Record "User Subscription";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        JsonRequest: JsonObject;
        JsonResponse: JsonObject;
        ResponseText: Text;
        Url: Text;
        Status: Boolean;
        SubmissionId: Text;
        StatusToken: JsonToken;
        SubmissionToken: JsonToken;
        AuthCU: Codeunit "Authenticate Management";
    begin
        SIH.TestField("Control Number");
        if not Setup.Get() then
            Error('Invoice Setup not found');

        if not UserSetup.Get(UserId) then
            Error('User Setup not found for %1.', UserId);

        if UserSetup."Subscription Config Id" = 0 then
            Error('Subscription Config Id not defined in User Setup.');

        if not UserSubscription.Get(UserSetup."Subscription Config Id") then
            Error('No Subscription found for Config Id %1.', UserSetup."Subscription Config Id");

        // URL
        Url := Setup."Base URL" + '/api/v1/documents/sent/check';

        // JSON Body
        JsonRequest.Add('ConfigId', UserSubscription."Config Id");
        JsonRequest.Add('ConfigType', UserSubscription."Config Type");
        JsonRequest.Add('ControlNumber', SIH."Control Number");

        JsonRequest.WriteTo(ResponseText);
        Content.WriteFrom(ResponseText);

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        // Request
        Request.SetRequestUri(Url);
        Request.Method := 'POST';
        Request.Content := Content;

        Request.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + AuthCU.GetValidToken());

        // Send
        if not Client.Send(Request, Response) then
            Error('Unable to reach sent status API');

        // Check HTTP status
        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            Error('Send failed. HTTP %1\%2', Response.HttpStatusCode(), ResponseText);
        end;

        // Read response content FIRST
        Response.Content.ReadAs(ResponseText);

        if Setup."Show Message" then
            Message(ResponseText);

        // Parse response JSON
        if not JsonResponse.ReadFrom(ResponseText) then
            Error('Invalid JSON response from sent status API');

        // ---- SAFE JSON access ----
        if JsonResponse.Get('Status', StatusToken) then
            Status := StatusToken.AsValue().AsBoolean()
        else
            Error('Response does not contain Status field.');

        if JsonResponse.Get('SubmissionId', SubmissionToken) then
            SubmissionId := SubmissionToken.AsValue().AsText()
        else
            SubmissionId := '';

        // Update Sales Invoice
        SIH."Sent Status" := Status;
        SIH."Submission Id" := SubmissionId;
        SIH.Modify();
    end;

    procedure GetSentDocumentDetails(PostedInvoiceNo: Code[20])
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SentHdr: Record "Sent Document Header";
        InvoiceSetup: Record "Invoice Setup";
        AuthCU: Codeunit "Authenticate Management";
        UserSetup: Record "User Setup";
        UserSubscription: Record "User Subscription";
        EntryNo: Integer;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        JsonReq: JsonObject;
        JsonResp: JsonArray;
        JsonObj: JsonObject;
        BearerToken: Text;
        RespTxt: Text;
        Token: JsonToken;
    begin
        // --- 1. Get Sales Invoice and validate ---
        SalesInvHdr.Get(PostedInvoiceNo);
        SalesInvHdr.TestField("Control Number");
        SalesInvHdr.TestField("Submission Id");

        // --- 2. Load setup & user subscription ---
        InvoiceSetup.Get();

        if not UserSetup.Get(UserId) then
            Error('User Setup not found for %1.', UserId);

        if UserSetup."Subscription Config Id" = 0 then
            Error('Subscription Config Id not defined in User Setup.');

        if not UserSubscription.Get(UserSetup."Subscription Config Id") then
            Error('No Subscription found for Config Id %1.', UserSetup."Subscription Config Id");

        // --- 3. Get bearer token ---
        BearerToken := AuthCU.GetValidToken();

        SentHdr.SetRange("Invoice No.", PostedInvoiceNo);
        if SentHdr.FindFirst() then
            exit; // already have details

        // --- 4. Create header record ---
        SentHdr.Reset();
        if SentHdr.FindLast() then
            EntryNo := SentHdr."Entry No." + 1
        else
            EntryNo := 1;

        SentHdr.Init();
        SentHdr."Entry No." := EntryNo;
        SentHdr."Config Type" := UserSubscription."Config Type";
        SentHdr."Config Id" := UserSubscription."Config Id";
        SentHdr."Specification Business Type" := 'INVOIC';
        SentHdr."Control Number" := SalesInvHdr."Control Number";
        SentHdr."Submission Id" := SalesInvHdr."Submission Id";
        SentHdr."Invoice No." := SalesInvHdr."No.";
        SentHdr."Customer No." := SalesInvHdr."Bill-to Customer No.";
        SentHdr."Last API Call DateTime" := CurrentDateTime();
        SentHdr.Insert(true);

        // --- 5. Build request JSON ---
        JsonReq.Add('ConfigType', SentHdr."Config Type");
        JsonReq.Add('ConfigId', SentHdr."Config Id");
        JsonReq.Add('SpecificationBusinessType', SentHdr."Specification Business Type");

        JsonReq.WriteTo(RespTxt);
        Content.WriteFrom(RespTxt);

        // --- 6. Set content headers ---
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        // --- 7. Prepare request ---
        Request.Method := 'POST';
        Request.SetRequestUri(InvoiceSetup."Base URL" + '/api/v1/documents/sent/details');
        Request.Content := Content;

        // --- 8. Set request authorization ---
        Request.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Authorization', 'Bearer ' + BearerToken);

        // --- 9. Send request ---
        Client.Send(Request, Response);
        Response.Content.ReadAs(RespTxt);

        if InvoiceSetup."Show Message" then
            Message(RespTxt);

        // --- 10. Parse JSON response ---
        if not JsonResp.ReadFrom(RespTxt) then
            Error('Invalid response JSON');

        // --- 11. Insert each line safely ---
        foreach Token in JsonResp do begin
            JsonObj := Token.AsObject(); // convert JsonToken → JsonObject
            CreateSentDocumentLine(SentHdr, JsonObj);
        end;
    end;

    local procedure CreateSentDocumentLine(SentHdr: Record "Sent Document Header"; JsonObj: JsonObject)
    var
        SentLine: Record "Sent Document Line";
        DestObj: JsonObject;
        DestToken: JsonToken;
        OutStr: OutStream;
        JsonText: Text;
        MsgId: Guid;
        EntryNo: Integer;
    begin
        MsgId := GetGuid(JsonObj, 'MessageId');

        // --- 1. Skip duplicate lines for same Header + MessageId ---
        SentLine.SetRange("Header Entry No.", SentHdr."Entry No.");
        SentLine.SetRange("Message Id", MsgId);
        if SentLine.FindFirst() then
            exit; // already exists

        // --- 2. Prepare new line ---
        SentLine.Reset();
        if SentLine.FindLast() then
            EntryNo := SentLine."Entry No." + 1
        else
            EntryNo := 1;

        SentLine.Init();
        SentLine."Entry No." := EntryNo;
        SentLine."Header Entry No." := SentHdr."Entry No.";
        SentLine."Message Id" := MsgId;
        SentLine."Processing Status" := GetBool(JsonObj, 'ProcessingStatus');
        SentLine."Web Doc Id" := GetInt(JsonObj, 'WebDocId');
        SentLine."Submission Id" := GetGuid(JsonObj, 'SubmissionId');
        SentLine."Control Number" := GetText(JsonObj, 'ControlNumber');
        SentLine."Compression Type" := GetText(JsonObj, 'CompressionType');
        SentLine."Processing Date" := GetDateTime(JsonObj, 'ProcessingDate');

        if JsonObj.Get('DestinationPartner', DestToken) then begin
            DestObj := DestToken.AsObject();
            SentLine."Destination Name" := GetText(DestObj, 'Name');
            SentLine."Destination Alias" := GetText(DestObj, 'Alias');
            SentLine."Destination Qualifier" := GetText(DestObj, 'Qualifier');
        end;

        // --- 3. Store raw JSON ---
        JsonObj.WriteTo(JsonText);
        SentLine."Raw JSON".CreateOutStream(OutStr);
        OutStr.WriteText(JsonText);

        // --- 4. Insert ---
        SentLine.Insert();
    end;

    local procedure GetText(JObj: JsonObject; Name: Text): Text
    var
        JTok: JsonToken;
    begin
        if JObj.Get(Name, JTok) then
            exit(JTok.AsValue().AsText());
    end;

    local procedure GetInt(JObj: JsonObject; Name: Text): Integer
    var
        JTok: JsonToken;
    begin
        if JObj.Get(Name, JTok) then
            exit(JTok.AsValue().AsInteger());
    end;

    local procedure GetBool(JObj: JsonObject; Name: Text): Boolean
    var
        JTok: JsonToken;
    begin
        if JObj.Get(Name, JTok) then
            exit(JTok.AsValue().AsBoolean());
    end;

    local procedure GetDateTime(JObj: JsonObject; Name: Text): DateTime
    var
        JTok: JsonToken;
    begin
        if JObj.Get(Name, JTok) then
            exit(JTok.AsValue().AsDateTime());
    end;

    local procedure GetGuid(JObj: JsonObject; Name: Text): Guid
    var
        JTok: JsonToken;
        GuidTxt: Text;
        GuidVal: Guid;
    begin
        if JObj.Get(Name, JTok) then begin
            GuidTxt := JTok.AsValue().AsText();
            if GuidTxt <> '' then
                Evaluate(GuidVal, GuidTxt);
            exit(GuidVal);
        end;
    end;

}
