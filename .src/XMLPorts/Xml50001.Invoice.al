xmlport 50001 "Invoice"
{
    Permissions = tabledata "Sales Invoice Header" = rm;
    Direction = Export;
    Encoding = UTF8;
    Format = Xml;
    UseDefaultNamespace = false;

    schema
    {
        tableelement(InvoiceHeaderLoop; Integer)
        {
            MaxOccurs = Once;
            XmlName = 'Document-Invoice';
            SourceTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));

            textelement(InvoiceHeader)
            {
                XmlName = 'Invoice-Header';
                textelement(InvoiceNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        InvoiceNumber := SalesInvoiceHeader."No.";
                    end;
                }
                textelement(InvoiceDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        InvoiceDate := Format(SalesInvoiceHeader."Posting Date", 0, 9);
                    end;
                }
                textelement(SalesDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SalesDate := Format(SalesInvoiceHeader."Document Date", 0, 9);
                    end;
                }
                textelement(InvoiceCurrency)
                {
                    trigger OnBeforePassVariable()
                    begin
                        InvoiceCurrency := GetSalesDocCurrencyCode();
                    end;
                }
                textelement(InvoicePaymentDueDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        InvoicePaymentDueDate := Format(SalesInvoiceHeader."Due Date", 0, 9);
                    end;
                }
                textelement(InvoicePaymentTerms)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if SalesInvoiceHeader."Payment Terms Code" <> '' then begin
                            RecPaymentTerms.Get(SalesInvoiceHeader."Payment Terms Code");
                            InvoicePaymentTerms := RecPaymentTerms.Description;
                        end;
                    end;
                }
                textelement(DocumentFunctionCode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        DocumentFunctionCode := 'O'; // Original invoice
                    end;
                }
                textelement(RegulatoryInformation)
                {
                    trigger OnBeforePassVariable()
                    begin
                        RegulatoryInformation := 'test_invoice'; // Customize as needed
                    end;
                }
                textelement(PriceConditions)
                {
                    trigger OnBeforePassVariable()
                    begin
                        PriceConditions := 'ST3'; // Customize as needed
                    end;
                }
                textelement(Order)
                {
                    textelement(BuyerOrderNumber)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            if BuyerOrderNumber = '' then
                                currXMLport.Skip();

                            BuyerOrderNumber := SalesInvoiceHeader."External Document No.";
                        end;
                    }
                    textelement(BuyerOrderDate)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            BuyerOrderDate := Format(SalesInvoiceHeader."Order Date", 0, 9);
                        end;
                    }
                }
                textelement(Delivery)
                {
                    textelement(DeliveryLocationNumber)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            DeliveryLocationNumber := SalesInvoiceHeader."Location Code";
                        end;
                    }
                    textelement(DeliveryDate)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            DeliveryDate := Format(SalesInvoiceHeader."Shipment Date", 0, 9);
                        end;
                    }
                    textelement(DespatchNumber)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            DespatchNumber := SalesInvoiceHeader."No.";
                        end;
                    }
                }
                textelement(Allowances)
                {
                    textelement(Allowance)
                    {
                        textelement(SpecialServiceDescription)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                SpecialServiceDescription := 'RAA'; // Customize based on allowances
                            end;
                        }
                    }
                }
                textelement(Charges)
                {
                    textelement(Charge)
                    {
                        textelement(ChargeAmount)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                // Calculate total charges if any
                                ChargeAmount := '110.00';
                            end;
                        }
                        textelement(SpecialService)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                SpecialService := 'FC';
                            end;
                        }
                        textelement(SpecialServiceDescription1)
                        {
                            XmlName = 'SpecialServiceDescription';
                            trigger OnBeforePassVariable()
                            begin
                                SpecialServiceDescription1 := 'SER';
                            end;
                        }
                    }
                }
            }

            textelement(InvoiceParties)
            {
                XmlName = 'Invoice-Parties';
                textelement(Buyer)
                {
                    textelement(BuyerILN)
                    {
                        XmlName = 'ILN';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerILN := RecCustomer.ILN;
                        end;
                    }
                    textelement(BuyerTaxID)
                    {
                        XmlName = 'TaxID';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerTaxID := RecCustomer."VAT Registration No.";
                        end;
                    }
                    textelement(BuyerName)
                    {
                        XmlName = 'Name';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerName := SalesInvoiceHeader."Bill-to Name";
                        end;
                    }
                    textelement(BuyerStreetAndNumber)
                    {
                        XmlName = 'StreetAndNumber';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerStreetAndNumber := SalesInvoiceHeader."Bill-to Address";
                        end;
                    }
                    textelement(BuyerCityName)
                    {
                        XmlName = 'CityName';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerCityName := SalesInvoiceHeader."Bill-to City";
                        end;
                    }
                    textelement(BuyerPostalCode)
                    {
                        XmlName = 'PostalCode';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerPostalCode := SalesInvoiceHeader."Bill-to Post Code";
                        end;
                    }
                    textelement(BuyerCountry)
                    {
                        XmlName = 'Country';
                        trigger OnBeforePassVariable()
                        begin
                            BuyerCountry := HeaderCountryRegion."ISO Code";
                        end;
                    }
                }

                textelement(Payer)
                {
                    textelement(PayerILN)
                    {
                        XmlName = 'ILN';
                        trigger OnBeforePassVariable()
                        begin
                            PayerILN := RecCustomer.ILN;
                        end;
                    }
                    textelement(PayerTaxID)
                    {
                        XmlName = 'TaxID';
                        trigger OnBeforePassVariable()
                        begin
                            PayerTaxID := RecCustomer."VAT Registration No.";
                        end;
                    }
                    textelement(PayerName)
                    {
                        XmlName = 'Name';
                        trigger OnBeforePassVariable()
                        begin
                            PayerName := SalesInvoiceHeader."Bill-to Name";
                        end;
                    }
                    textelement(PayerStreetAndNumber)
                    {
                        XmlName = 'StreetAndNumber';
                        trigger OnBeforePassVariable()
                        begin
                            PayerStreetAndNumber := SalesInvoiceHeader."Bill-to Address";
                        end;
                    }
                    textelement(PayerCityName)
                    {
                        XmlName = 'CityName';
                        trigger OnBeforePassVariable()
                        begin
                            PayerCityName := SalesInvoiceHeader."Bill-to City";
                        end;
                    }
                    textelement(PayerPostalCode)
                    {
                        XmlName = 'PostalCode';
                        trigger OnBeforePassVariable()
                        begin
                            PayerPostalCode := SalesInvoiceHeader."Bill-to Post Code";
                        end;
                    }
                    textelement(PayerCountry)
                    {
                        XmlName = 'Country';
                        trigger OnBeforePassVariable()
                        begin
                            PayerCountry := HeaderCountryRegion."ISO Code";
                        end;
                    }
                }

                textelement(Invoicee)
                {
                    textelement(InvoiceILN)
                    {
                        XmlName = 'ILN';
                        trigger OnBeforePassVariable()
                        begin
                            InvoiceILN := RecCustomer.ILN;
                        end;
                    }
                    textelement(InvoiceTaxID)
                    {
                        XmlName = 'TaxID';
                        trigger OnBeforePassVariable()
                        begin
                            InvoiceTaxID := RecCustomer."VAT Registration No.";
                        end;
                    }
                    textelement(InvoiceName)
                    {
                        XmlName = 'Name';
                        trigger OnBeforePassVariable()
                        begin
                            InvoiceName := SalesInvoiceHeader."Sell-to Customer Name";
                        end;
                    }
                    textelement(InvoiceStreetAndNumber)
                    {
                        XmlName = 'StreetAndNumber';
                        trigger OnBeforePassVariable()
                        begin
                            InvoiceStreetAndNumber := SalesInvoiceHeader."Sell-to Address";
                        end;
                    }
                    textelement(InvoiceCityName)
                    {
                        XmlName = 'CityName';
                        trigger OnBeforePassVariable()
                        begin
                            InvoiceCityName := SalesInvoiceHeader."Sell-to City";
                        end;
                    }
                    textelement(InvoicePostalCode)
                    {
                        XmlName = 'PostalCode';
                        trigger OnBeforePassVariable()
                        begin
                            InvoicePostalCode := SalesInvoiceHeader."Sell-to Post Code";
                        end;
                    }
                    textelement(InvoiceCountry)
                    {
                        XmlName = 'Country';
                        trigger OnBeforePassVariable()
                        begin
                            InvoiceCountry := HeaderCountryRegion."ISO Code";
                        end;
                    }
                }

                textelement(Seller)
                {
                    textelement(SellerILN)
                    {
                        XmlName = 'ILN';
                        trigger OnBeforePassVariable()
                        begin
                            SellerILN := RecCompanyInformation.ILN;
                        end;
                    }
                    textelement(SellerTaxID)
                    {
                        XmlName = 'TaxID';
                        trigger OnBeforePassVariable()
                        begin
                            SellerTaxID := RecCompanyInformation."VAT Registration No.";
                        end;
                    }
                    textelement(SellerCodeByBuyer)
                    {
                        XmlName = 'CodeByBuyer';
                        trigger OnBeforePassVariable()
                        begin
                            SellerCodeByBuyer := '123'; // Customize as needed
                        end;
                    }
                    textelement(SellerName)
                    {
                        XmlName = 'Name';
                        trigger OnBeforePassVariable()
                        begin
                            SellerName := RecCompanyInformation.Name;
                        end;
                    }
                    textelement(SellerStreetAndNumber)
                    {
                        XmlName = 'StreetAndNumber';
                        trigger OnBeforePassVariable()
                        begin
                            SellerStreetAndNumber := RecCompanyInformation.Address;
                        end;
                    }
                    textelement(SellerCityName)
                    {
                        XmlName = 'CityName';
                        trigger OnBeforePassVariable()
                        begin
                            SellerCityName := RecCompanyInformation.City;
                        end;
                    }
                    textelement(SellerPostalCode)
                    {
                        XmlName = 'PostalCode';
                        trigger OnBeforePassVariable()
                        begin
                            SellerPostalCode := RecCompanyInformation."Post Code";
                        end;
                    }
                    textelement(SellerCountry)
                    {
                        XmlName = 'Country';
                        trigger OnBeforePassVariable()
                        begin
                            SellerCountry := CompanyCountryRegion."ISO Code";
                        end;
                    }
                    textelement(CourtAndCapitalInformation)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            CourtAndCapitalInformation := 'Informations'; // Customize
                        end;
                    }
                }
            }

            textelement(InvoiceLines)
            {
                XmlName = 'Invoice-Lines';

                tableelement(Line; Integer)
                {
                    SourceTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                    textelement(LineItem)
                    {
                        XmlName = 'Line-Item';
                        textelement(LineNumber)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                LineNumber := Format(SalesInvoiceLine."Line No.", 0, 9);
                            end;
                        }
                        textelement(EAN)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                // Get EAN from item if available
                                EAN := '5900886419437'; // Placeholder
                            end;
                        }
                        textelement(BuyerItemCode)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                BuyerItemCode := '706084'; // Placeholder
                            end;
                        }
                        textelement(SupplierItemCode)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                SupplierItemCode := SalesInvoiceLine."No.";
                            end;
                        }
                        textelement(ItemDescription)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                ItemDescription := SalesInvoiceLine.Description;
                            end;
                        }
                        textelement(ItemType)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                ItemType := 'CU'; // Custom Unit
                            end;
                        }
                        textelement(InvoiceQuantity)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                InvoiceQuantity := Format(SalesInvoiceLine.Quantity, 0, '<Precision,3:3><Standard Format,0>');
                            end;
                        }
                        textelement(UnitOfMeasure)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                if RecUnitofMeasure.get(SalesInvoiceLine."Unit of Measure Code") then
                                    UnitOfMeasure := RecUnitofMeasure."International Standard Code";
                                if UnitOfMeasure = '' then
                                    UnitOfMeasure := 'PCE';
                            end;
                        }
                        textelement(InvoiceUnitNetPrice)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                InvoiceUnitNetPrice := Format(SalesInvoiceLine."Unit Price", 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                        textelement(LineTaxRate)
                        {
                            XmlName = 'TaxRate';
                            trigger OnBeforePassVariable()
                            begin
                                LineTaxRate := Format(SalesInvoiceLine."VAT %", 0, 9);
                            end;
                        }
                        textelement(LineTaxCategoryCode)
                        {
                            XmlName = 'TaxCategoryCode';
                            trigger OnBeforePassVariable()
                            begin
                                LineTaxCategoryCode := 'S'; // Standard rate
                            end;
                        }
                        textelement(LineTaxAmount)
                        {
                            XmlName = 'TaxAmount';
                            trigger OnBeforePassVariable()
                            begin
                                LineTaxAmount := Format(SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount, 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                        textelement(NetAmount)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                NetAmount := Format(SalesInvoiceLine."Line Amount", 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                    }
                    textelement(LineMeasurements)
                    {
                        XmlName = 'Line-Measurements';
                        textelement(GrossWeight)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                GrossWeight := '226.000'; // Placeholder - get from item
                            end;
                        }
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if not FindNextInvoiceLineRec(Line.Number) then
                            currXMLport.Break();

                        if SalesInvoiceLine."No." = '' then
                            currXMLport.Skip();

                        if SalesInvoiceLine.Quantity = 0 then
                            currXMLport.Skip();
                    end;
                }
            }

            textelement(InvoiceSummary)
            {
                XmlName = 'Invoice-Summary';
                textelement(TotalLines)
                {
                    trigger OnBeforePassVariable()
                    var
                        LineCount: Integer;
                    begin
                        SalesInvoiceLine.Reset();
                        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                        LineCount := SalesInvoiceLine.Count();
                        TotalLines := Format(LineCount);
                    end;
                }
                textelement(TotalNetAmount)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SalesInvoiceHeader.CalcFields(Amount);
                        TotalNetAmount := Format(SalesInvoiceHeader.Amount, 0, '<Precision,2:2><Standard Format,0>');
                    end;
                }
                textelement(TotalTaxableBasis)
                {
                    trigger OnBeforePassVariable()
                    begin
                        TotalTaxableBasis := Format(SalesInvoiceHeader.Amount, 0, '<Precision,2:2><Standard Format,0>');
                    end;
                }
                textelement(TotalTaxAmount)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SalesInvoiceHeader.CalcFields("Amount Including VAT");
                        TotalTaxAmount := Format(SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, 0, '<Precision,2:2><Standard Format,0>');
                    end;
                }
                textelement(TotalGrossAmount)
                {
                    trigger OnBeforePassVariable()
                    begin
                        TotalGrossAmount := Format(SalesInvoiceHeader."Amount Including VAT", 0, '<Precision,2:2><Standard Format,0>');
                    end;
                }
                textelement(TotalAllowancesAmount)
                {
                    trigger OnBeforePassVariable()
                    begin
                        TotalAllowancesAmount := Format(0.0, 0, '<Precision,2:2><Standard Format,0>');
                    end;
                }
                textelement(TaxSummary)
                {
                    textelement(TaxSummaryLine)
                    {
                        textelement(TaxRate)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                TaxRate := Format(SalesInvoiceLine."VAT %", 0, 9);
                            end;
                        }
                        textelement(TaxCategoryCode)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                TaxCategoryCode := 'S';
                            end;
                        }
                        textelement(TaxAmount)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                TaxAmount := Format(SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                        textelement(TaxableBasis)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                TaxableBasis := Format(SalesInvoiceHeader.Amount, 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                        textelement(TaxableAmount)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                TaxableAmount := Format(SalesInvoiceHeader.Amount, 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                        textelement(GrossAmount)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                GrossAmount := Format(SalesInvoiceHeader."Amount Including VAT", 0, '<Precision,2:2><Standard Format,0>');
                            end;
                        }
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                // Initialize the main SalesInvoiceHeader record from the table element
                if not FindNextInvoiceRec() then
                    currXMLport.Break();

                RecCompanyInformation.Get();
                RecCustomer.Get(SalesInvoiceHeader."Sell-to Customer No.");  // This was failing
                HeaderCountryRegion.Get(SalesInvoiceHeader."Sell-to Country/Region Code");
                CompanyCountryRegion.Get(RecCompanyInformation."Country/Region Code");
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Control2)
                {
                    ShowCaption = false;
                    field(SalesInvoiceNo; SalesInvoiceHeaderFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales Invoice No.';
                        TableRelation = "Sales Invoice Header";
                        ToolTip = 'Select Sales Invoice No';
                    }
                }
            }
        }
        actions
        {
        }
    }

    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RecCompanyInformation: Record "Company Information";
        RecCustomer: Record Customer;
        RecPaymentTerms: Record "Payment Terms";
        RecUnitofMeasure: Record "Unit of Measure";
        HeaderCountryRegion: Record "Country/Region";
        CompanyCountryRegion: Record "Country/Region";
        RecGeneralLedgerSetup: Record "General Ledger Setup";
        SalesInvoiceHeaderFilter: Code[20];
        SpecifySalesShipmentNoErr: label 'You must specify a Sales Invoice number.';

    local procedure FindNextInvoiceRec(): Boolean
    var
        Found: Boolean;
    begin
        IF SalesInvoiceHeader."No." = '' THEN
            ERROR(SpecifySalesShipmentNoErr);
        Found := SalesInvoiceHeader.GET(SalesInvoiceHeader."No.");
        EXIT(Found);
    end;

    local procedure FindNextInvoiceLineRec(Position: Integer): Boolean
    var
        Found: Boolean;
    begin
        if Position = 1 then begin
            SalesInvoiceLine.Reset();
            SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
            Found := SalesInvoiceLine.FindFirst();
        end else
            Found := SalesInvoiceLine.Next() <> 0;
        exit(Found);
    end;

    local procedure GetSalesDocCurrencyCode(): Code[10]
    begin
        if SalesInvoiceHeader."Currency Code" = '' then begin
            RecGeneralLedgerSetup.Get();
            RecGeneralLedgerSetup.TestField("LCY Code");
            exit(RecGeneralLedgerSetup."LCY Code");
        end;
        exit(SalesInvoiceHeader."Currency Code");
    end;


    procedure SetParameter(Order_No: code[20])
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
    begin
        IF Order_No = '' THEN BEGIN
            IF PAGE.RUNMODAL(143, SalesInvoiceHeader1) = ACTION::LookupOK THEN
                SalesInvoiceHeader."No." := SalesInvoiceHeader1."No.";
        END
        ELSE
            SalesInvoiceHeader."No." := Order_No;

        IF SalesInvoiceHeader."No." = '' THEN
            ERROR(SpecifySalesShipmentNoErr);
        IF NOT SalesInvoiceHeader1.GET(SalesInvoiceHeader."No.") THEN
            ERROR('No Record Found');
    end;
}