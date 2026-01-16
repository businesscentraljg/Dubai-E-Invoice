codeunit 50002 "Download XML"
{
    procedure DownloadInvoice(SalesInvoiceNo: Code[20])
    begin
        RecSalesInvoiceHeader.get(SalesInvoiceNo);
        XMLportInvoice.SetParameter(SalesInvoiceNo);
        TempBlob.CreateOutStream(OutStr);
        XMLportInvoice.SetDestination(OutStr);
        XMLportInvoice.Export();
        FileName := 'Invoice_' + format(SalesInvoiceNo) + '.xml';
        CodFileManagement.BLOBExport(TempBlob, FileName, True);
    end;

    var
        RecSalesInvoiceHeader: Record "Sales Invoice Header";
        XMLportInvoice: XMLport "Invoice";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FileName: Text;
        CodFileManagement: Codeunit "File Management";
}
