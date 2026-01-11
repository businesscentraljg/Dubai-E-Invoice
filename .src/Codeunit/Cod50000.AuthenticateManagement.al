codeunit 50000 "Authenticate Management"
{
    procedure GenerateToken(): Text
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
        if not InvoiceSetup.Get() then
            Error('Invoice Setup not found.');

        // Build request JSON
        JsonRequest.Add('Login', InvoiceSetup.Login);
        JsonRequest.Add('Password', InvoiceSetup."Password");
        JsonRequest.WriteTo(RequestBody);

        // Prepare HTTP content
        RequestContent.WriteFrom(RequestBody);
        RequestContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        // Call API
        if not Client.Post(InvoiceSetup."Base URL" + '/api/v1/auth', RequestContent, ResponseMessage) then
            Error('Failed to connect to token API.');

        ResponseMessage.Content().ReadAs(ResponseText);

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('Token API failed. HTTP %1. Response: %2', ResponseMessage.HttpStatusCode(), ResponseText);

        Token := DelChr(ResponseText, '=', '"');

        InvoiceSetup."Bearer Token" := Token;
        InvoiceSetup."Token Expiry" := CurrentDateTime() + (50 * 60 * 1000);
        InvoiceSetup.Modify();

        Message('Token generated successfully. Expiry: %1', InvoiceSetup."Token Expiry");

        exit(Token);
    end;


}
