codeunit 50005 "EDI Received Processor"
{
    procedure ProcessPendingReceivedDocuments()
    var
        Received: Record "Received Document Stg";
    begin
        Received.SetRange(Converted, false);
        if not Received.FindSet() then
            exit;

        repeat
            ProcessSingleReceivedDocument(Received);
        until Received.Next() = 0;
    end;

    procedure ProcessSingleReceivedDocument(var Received: Record "Received Document Stg")
    var
        PurchaseHeader: Record "Purchase Header";
        Setup: Record "Invoice Setup";
        VendorNo: Code[20];
        XmlText: Text;
        InvoiceNo: Text;
        CurrencyCode: Code[10];
        InvoiceDate: Date;
    begin
        ClearLastError();
        if not TryProcessSingleReceivedDocument(Received, PurchaseHeader, Setup, VendorNo, XmlText, InvoiceNo, CurrencyCode, InvoiceDate) then begin
            Received."Processing Error" := CopyStr(GetLastErrorText(), 1, MaxStrLen(Received."Processing Error"));
            Received.Modify();
        end;
    end;

    [TryFunction]
    local procedure TryProcessSingleReceivedDocument(var Received: Record "Received Document Stg"; var PurchaseHeader: Record "Purchase Header"; Setup: Record "Invoice Setup"; var VendorNo: Code[20]; var XmlText: Text; var InvoiceNo: Text; var CurrencyCode: Code[10]; var InvoiceDate: Date)
    var
        InStr: InStream;
        Part: Text;
        Value: Text;
        Tempblob: Codeunit "Temp Blob";
    begin
        GetSetup(Setup);
        Setup.TestField("Default Purch. G/L Account No.");

        // XmlText := ReadBlobText(Received."Document Content");

        //  if not BlobField.HasValue() then
        //     exit('');
        // BlobField.CreateInStream(InStr);
        // while not InStr.EOS do begin
        //     InStr.ReadText(Part);
        //     Value += Part;
        // end;
        // exit(Value);

        Received."Document Content".CreateInStream(InStr);

        while not InStr.EOS do begin
            InStr.ReadText(Part);
            Value += Part;
        end;
        XmlText := Value;


        if XmlText = '' then
            Error('Received document %1 has empty Document Content.', Received."Entry No.");

        VendorNo := ResolveVendorNo(XmlText, Setup);
        if VendorNo = '' then
            Error('Vendor could not be resolved for received document %1.', Received."Entry No.");

        InvoiceNo := GetXmlValue(XmlText, '//Document-Invoice/Invoice-Header/InvoiceNumber');
        CurrencyCode := CopyStr(GetXmlValue(XmlText, '//Document-Invoice/Invoice-Header/InvoiceCurrency'), 1, 10);
        if not Evaluate(InvoiceDate, GetXmlValue(XmlText, '//Document-Invoice/Invoice-Header/InvoiceDate')) then
            InvoiceDate := WorkDate();

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        if InvoiceNo <> '' then
            PurchaseHeader.Validate("Vendor Invoice No.", CopyStr(InvoiceNo, 1, MaxStrLen(PurchaseHeader."Vendor Invoice No.")));
        PurchaseHeader.Validate("Document Date", InvoiceDate);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        if CurrencyCode <> '' then
            PurchaseHeader.Validate("Currency Code", CurrencyCode);
        PurchaseHeader.Modify(true);

        CreatePurchaseLinesFromXml(PurchaseHeader, XmlText, Setup."Default Purch. G/L Account No.");

        Received.Converted := true;
        Received."Converted At" := CurrentDateTime();
        Received."BC Document No." := PurchaseHeader."No.";
        Received."Processing Error" := '';
        Received.Modify();
    end;

    local procedure CreatePurchaseLinesFromXml(PurchaseHeader: Record "Purchase Header"; XmlText: Text; GLAccountNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        LineNo: Integer;
        I: Integer;
        LineCount: Integer;
        XPath: Text;
        QtyTxt: Text;
        PriceTxt: Text;
        DescTxt: Text;
        Qty: Decimal;
        UnitPrice: Decimal;
        TotalNet: Decimal;
    begin
        LineCount := GetXmlNodeCount(XmlText, '//Document-Invoice/Invoice-Lines/Line');
        LineNo := 10000;

        if LineCount = 0 then begin
            Evaluate(TotalNet, GetXmlValue(XmlText, '//Document-Invoice/Invoice-Summary/TotalNetAmount'));
            if TotalNet = 0 then
                exit;

            PurchaseLine.Init();
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine."Line No." := LineNo;
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
            PurchaseLine.Validate("No.", GLAccountNo);
            PurchaseLine.Validate(Quantity, 1);
            PurchaseLine.Validate("Direct Unit Cost", TotalNet);
            PurchaseLine.Modify(true);
            exit;
        end;

        for I := 1 to LineCount do begin
            XPath := StrSubstNo('//Document-Invoice/Invoice-Lines/Line[%1]/Line-Item', I);
            QtyTxt := GetXmlValue(XmlText, XPath + '/InvoiceQuantity');
            PriceTxt := GetXmlValue(XmlText, XPath + '/InvoiceUnitNetPrice');
            DescTxt := GetXmlValue(XmlText, XPath + '/ItemDescription');

            if not TryParseDecimal(QtyTxt, Qty) then
                Qty := 1;
            if Qty = 0 then
                Qty := 1;
            if not TryParseDecimal(PriceTxt, UnitPrice) then
                UnitPrice := 0;

            PurchaseLine.Init();
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine."Line No." := LineNo;
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
            PurchaseLine.Validate("No.", GLAccountNo);
            PurchaseLine.Validate(Quantity, Qty);
            PurchaseLine.Validate("Direct Unit Cost", UnitPrice);
            if DescTxt <> '' then
                PurchaseLine.Validate(Description, CopyStr(DescTxt, 1, MaxStrLen(PurchaseLine.Description)));
            PurchaseLine.Modify(true);

            LineNo += 10000;
        end;
    end;

    local procedure ResolveVendorNo(XmlText: Text; Setup: Record "Invoice Setup"): Code[20]
    var
        Vendor: Record Vendor;
        SellerILN: Code[20];
        SellerTaxId: Text;
    begin
        SellerILN := CopyStr(GetXmlValue(XmlText, '//Document-Invoice/Invoice-Parties/Seller/ILN'), 1, 20);
        if SellerILN <> '' then begin
            Vendor.SetRange(ILN, SellerILN);
            if Vendor.FindFirst() then
                exit(Vendor."No.");
        end;

        SellerTaxId := GetXmlValue(XmlText, '//Document-Invoice/Invoice-Parties/Seller/TaxID');
        if SellerTaxId <> '' then begin
            Vendor.SetRange("VAT Registration No.", CopyStr(SellerTaxId, 1, MaxStrLen(Vendor."VAT Registration No.")));
            if Vendor.FindFirst() then
                exit(Vendor."No.");
        end;

        if Setup."Default Vendor No." <> '' then
            exit(Setup."Default Vendor No.");
    end;

    local procedure GetXmlValue(XmlText: Text; XPathExpr: Text): Text
    var
        XmlDoc: XmlDocument;
        XmlNode: XmlNode;
    begin
        if not XmlDocument.ReadFrom(XmlText, XmlDoc) then
            Error('Failed to parse incoming XML.');
        if not XmlDoc.SelectSingleNode(XPathExpr, XmlNode) then
            exit('');
        exit(XmlNode.AsXmlElement().InnerText);
    end;

    local procedure GetXmlNodeCount(XmlText: Text; XPathExpr: Text): Integer
    var
        XmlDoc: XmlDocument;
        Nodes: XmlNodeList;
    begin
        if not XmlDocument.ReadFrom(XmlText, XmlDoc) then
            Error('Failed to parse incoming XML.');
        if not XmlDoc.SelectNodes(XPathExpr, Nodes) then
            exit(0);
        exit(Nodes.Count);
    end;

    // local procedure ReadBlobText(BlobField: Blob): Text
    // var
    //     InStr: InStream;
    //     Part: Text;
    //     Value: Text;
    // begin
    //     if not BlobField.HasValue() then
    //         exit('');
    //     BlobField.CreateInStream(InStr);
    //     while not InStr.EOS do begin
    //         InStr.ReadText(Part);
    //         Value += Part;
    //     end;
    //     exit(Value);
    // end;

    local procedure TryParseDecimal(ValueText: Text; var Value: Decimal): Boolean
    begin
        if Evaluate(Value, ValueText) then
            exit(true);
        exit(Evaluate(Value, ConvertStr(ValueText, '.', ',')));
    end;

    local procedure GetSetup(var Setup: Record "Invoice Setup")
    begin
        if Setup.Get() then
            exit;
        if Setup.Get('') then
            exit;
        Error('Invoice Setup not found.');
    end;
}
