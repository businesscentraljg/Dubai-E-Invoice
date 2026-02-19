codeunit 50000 "Authenticate Management"
{
    procedure GetValidToken(): Text
    var
        InvoiceSetup: Record "Invoice Setup";
    begin
        GetSetup(InvoiceSetup);

        if (InvoiceSetup."Bearer Token" <> '') and
           (InvoiceSetup."Token Expiry" > CurrentDateTime()) then
            exit(InvoiceSetup."Bearer Token");

        exit(GenerateToken());
    end;

    local procedure GenerateToken(): Text
    var
        InvoiceSetup: Record "Invoice Setup";
        Client: HttpClient;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        JsonRequest: JsonObject;
        RequestBody: Text;
        ResponseText: Text;
        Token: Text;
    begin
        GetSetup(InvoiceSetup);

        //Build request JSON
        JsonRequest.Add('Login', InvoiceSetup.Login);
        JsonRequest.Add('Password', InvoiceSetup."Password");
        JsonRequest.WriteTo(RequestBody);

        //Prepare HTTP content
        RequestContent.WriteFrom(RequestBody);
        RequestContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        //Call API
        if not Client.Post(InvoiceSetup."Base URL" + '/api/v1/auth', RequestContent, ResponseMessage) then
            Error('Failed to connect to token API.');

        ResponseMessage.Content().ReadAs(ResponseText);

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('Token API failed. HTTP %1. Response: %2', ResponseMessage.HttpStatusCode(), ResponseText);

        Token := DelChr(ResponseText, '=', '"');

        InvoiceSetup."Bearer Token" := Token;
        if InvoiceSetup."Token TTL (Minutes)" <= 0 then
            InvoiceSetup."Token TTL (Minutes)" := 50;
        InvoiceSetup."Token Expiry" := CurrentDateTime() + (InvoiceSetup."Token TTL (Minutes)" * 60 * 1000);
        InvoiceSetup.Modify();

        exit(Token);
    end;

    local procedure GetSetup(var InvoiceSetup: Record "Invoice Setup")
    begin
        if InvoiceSetup.Get() then
            exit;
        if InvoiceSetup.Get('') then
            exit;
        Error('Invoice Setup not found.');
    end;

}
