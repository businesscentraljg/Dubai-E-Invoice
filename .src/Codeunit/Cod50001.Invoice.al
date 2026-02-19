codeunit 50001 "Invoice"
{
    Permissions = tabledata "Sales Invoice Header" = RIMD;

    procedure SendPostedSalesInvoice(var SIH: Record "Sales Invoice Header")
    var
        Setup: Record "User Setup";
        Subscription: Record "User Subscription";
        API: Codeunit "EDI API Management";
        XmlBody: Text;
        ControlNumber: Text;
        SubmissionId: Text;
    begin
        if SIH."Invoice Send" then
            Error('Invoice %1 already sent.', SIH."No.");

        if not Setup.Get(UserId) then
            Error('User Setup not found for %1.', UserId);
        if Setup."Subscription Config Id" = 0 then
            Error('Subscription Config Id is not defined in User Setup.');
        if not Subscription.Get(Setup."Subscription Config Id") then
            Error('Subscription %1 not found.', Setup."Subscription Config Id");

        XmlBody := GenerateInvoiceXML(SIH);
        ControlNumber := Format(CreateGuid());

        API.SendDocument(Subscription."Config Type", Subscription."Config Id", ControlNumber, XmlBody, SubmissionId);

        SIH."Invoice Send" := true;
        SIH."Invoice Send DateTime" := CurrentDateTime();
        SIH."Control Number" := ControlNumber;
        SIH."Submission Id" := SubmissionId;
        SIH.Modify();
    end;

    procedure CheckPostedSalesInvoiceSentStatus(var SIH: Record "Sales Invoice Header")
    var
        Setup: Record "User Setup";
        Subscription: Record "User Subscription";
        API: Codeunit "EDI API Management";
        IsSent: Boolean;
        SubmissionId: Text;
    begin
        SIH.TestField("Control Number");

        if not Setup.Get(UserId) then
            Error('User Setup not found for %1.', UserId);
        if Setup."Subscription Config Id" = 0 then
            Error('Subscription Config Id is not defined in User Setup.');
        if not Subscription.Get(Setup."Subscription Config Id") then
            Error('Subscription %1 not found.', Setup."Subscription Config Id");

        API.CheckSentDocument(Subscription."Config Type", Subscription."Config Id", SIH."Control Number", IsSent, SubmissionId);

        SIH."Sent Status" := IsSent;
        SIH."Submission Id" := SubmissionId;
        SIH.Modify();
    end;

    procedure GetSentDocumentDetails()
    var
        API: Codeunit "EDI API Management";
    begin
        API.PullSentDetails();
    end;

    local procedure GenerateInvoiceXML(SIH: Record "Sales Invoice Header"): Text
    var
        InvoiceXmlPort: XmlPort Invoice;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        XmlText: Text;
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

