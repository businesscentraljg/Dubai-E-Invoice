codeunit 50001 "Invoice"
{
    procedure SendPostedSalesInvoice(var SIH: Record "Sales Invoice Header")
    var
        CU: Codeunit "Authenticate Management";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        Token: Text;
        XmlBody: Text;
        Setup: Record "Invoice Setup";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ToFile: Text;
        ContentHeaders: HttpHeaders;
    begin
        if SIH."Invoice Send" then
            Error('Invoice %1 already sent.', SIH."No.");

        if not Setup.Get() then
            Error('Invoice Setup not found.');

        // 1️⃣ Get token
        Token := CU.GetValidToken();

        // 2️⃣ Build XML from Posted Sales Invoice
        XmlBody := BuildInvoiceXmlFromPSI(SIH);

        // 3️⃣ Prepare HTTP content
        Content.WriteFrom(XmlBody);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/xml');

        // Set Authorization and accept headers on the request
        Request.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + Token);
        Headers.Add('accept', 'application/json');

        // 4️⃣ Prepare request
        Request.Method := 'POST';
        Request.SetRequestUri(Setup."Base URL" + '/api/v1/documents/send');
        Request.Content := Content;

        // 5️⃣ Send
        Client.Send(Request, Response);

        if not Response.IsSuccessStatusCode() then
            Error('Send failed. HTTP %1', Response.HttpStatusCode());

        // ✅ 6️⃣ MARK AS SENT (ONLY ON SUCCESS)
        SIH."Invoice Send" := true;
        SIH."Invoice Send DateTime" := CurrentDateTime();
        SIH.Modify();

        // Download the XML file
        TempBlob.CreateOutStream(OutStr);
        OutStr.Write(XmlBody);
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, 'application/xml', '', 'Invoice_' + SIH."No." + '.xml', ToFile);

        Message('Posted Sales Invoice %1 successfully sent and XML downloaded.', SIH."No.");
    end;

    procedure BuildInvoiceXmlFromPSI(SIH: Record "Sales Invoice Header"): Text
    var
        XmlDoc: XmlDocument;
        Root, Header, Parties, Lines, Summary : XmlElement;
        SIL: Record "Sales Invoice Line";
        LineNode, LineItem : XmlElement;
        XmlText: Text;
        LineCount: Integer;
        TotalTax: Decimal;
    begin
        XmlDoc := XmlDocument.Create();

        Root := XmlElement.Create('Invoice');
        XmlDoc.Add(Root);

        // ================= HEADER =================
        Header := XmlElement.Create('Invoice-Header');
        Root.Add(Header);

        AddNodeToParent(Header, 'InvoiceNumber', SIH."No.");
        AddNodeToParent(Header, 'InvoiceDate', Format(SIH."Posting Date", 0, 9));
        AddNodeToParent(Header, 'InvoiceCurrency', SIH."Currency Code");
        AddNodeToParent(Header, 'InvoicePaymentTerms', SIH."Payment Terms Code");

        // ================= PARTIES =================
        Parties := XmlElement.Create('Invoice-Parties');
        Root.Add(Parties);

        AddPartyToParent(Parties, 'Buyer', SIH."Bill-to Name");
        AddPartyToParent(Parties, 'Seller', SIH."Sell-to Customer Name");

        // ================= LINES =================
        Lines := XmlElement.Create('Invoice-Lines');
        Root.Add(Lines);

        SIL.SetRange("Document No.", SIH."No.");
        SIL.SetRange(Type, SIL.Type::Item);

        LineCount := 0;
        TotalTax := 0;
        if SIL.FindSet() then
            repeat
                LineNode := XmlElement.Create('Line');
                Lines.Add(LineNode);

                LineItem := XmlElement.Create('Line-Item');
                LineNode.Add(LineItem);

                AddNodeToParent(LineItem, 'LineNumber', Format(SIL."Line No."));
                AddNodeToParent(LineItem, 'ItemDescription', SIL.Description);
                AddNodeToParent(LineItem, 'InvoiceQuantity', Format(SIL.Quantity, 0, 9));
                AddNodeToParent(LineItem, 'InvoiceUnitNetPrice', Format(SIL."Unit Price", 0, 9));
                AddNodeToParent(LineItem, 'NetAmount', Format(SIL."Line Amount", 0, 9));
                AddNodeToParent(LineItem, 'TaxAmount', Format(SIL."Amount Including VAT" - SIL."Line Amount", 0, 9));
                LineCount += 1;
                TotalTax += (SIL."Amount Including VAT" - SIL."Line Amount");
            until SIL.Next() = 0;

        // ================= SUMMARY =================
        Summary := XmlElement.Create('Invoice-Summary');
        Root.Add(Summary);

        AddNodeToParent(Summary, 'TotalLines', Format(LineCount));
        AddNodeToParent(Summary, 'TotalNetAmount', Format(SIH."Amount", 0, 9));
        AddNodeToParent(Summary, 'TotalTaxAmount', Format(TotalTax, 0, 9));
        AddNodeToParent(Summary, 'TotalGrossAmount', Format(SIH."Amount Including VAT", 0, 9));

        XmlDoc.WriteTo(XmlText);
        exit(XmlText);
    end;

    local procedure AddNodeToParent(Parent: XmlElement; Name: Text; Value: Text)
    var
        Node: XmlElement;
    begin
        Node := XmlElement.Create(Name);
        Node.Add(Value);
        Parent.Add(Node);
    end;

    local procedure AddPartyToParent(Parent: XmlElement; PartyName: Text; PartyDisplayName: Text)
    var
        Party: XmlElement;
    begin
        Party := XmlElement.Create(PartyName);
        Parent.Add(Party);
        AddNodeToParent(Party, 'Name', PartyDisplayName);
        AddNodeToParent(Party, 'Country', 'PL');
    end;

}
