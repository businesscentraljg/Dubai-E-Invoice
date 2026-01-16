codeunit 50001 "Invoice"
{
    Permissions = tabledata "Sales Invoice Header" = rimd;
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
        DocObj.Add('ControlNumber', Format(CreateGuid()));
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
}
