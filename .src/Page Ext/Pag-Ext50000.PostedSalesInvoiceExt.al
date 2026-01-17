pageextension 50000 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addlast(Content)
        {
            group(InvoiceProcessing)
            {
                Caption = 'Invoice Processing';

                field("Invoice Send"; Rec."Invoice Send")
                {
                    ApplicationArea = All;
                }
                field("Invoice Send DateTime"; Rec."Invoice Send DateTime")
                {
                    ApplicationArea = All;
                }
                field("Control Number"; Rec."Control Number")
                {
                    ApplicationArea = All;
                }
                group("Sent Status Group")
                {
                    Caption = 'Sent Status';

                    field("Sent Status"; Rec."Sent Status")
                    {
                        ApplicationArea = All;
                    }
                    field("Submission Id"; Rec."Submission Id")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    actions
    {
        addafter(IncomingDocument)
        {
            group(InvoiceActions)
            {
                Caption = 'Invoice';

                action(SendDocument)
                {
                    Caption = 'Send Document';
                    Image = SendTo;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CU: Codeunit "Invoice";
                    begin
                        CU.SendPostedSalesInvoice(Rec);
                    end;
                }
                action("Download Sales Invoice XML")
                {
                    ApplicationArea = All;
                    Caption = 'Download XML';
                    ToolTip = 'Download XML';
                    Image = Download;

                    trigger OnAction()
                    var
                        Invoice: Codeunit "Download XML";
                    begin
                        Invoice.DownloadInvoice(Rec."No.");
                    end;
                }
                action("Checks the state of sent document")
                {
                    ApplicationArea = All;
                    Caption = 'Check Sent Status';
                    ToolTip = 'Check Sent Status';
                    Image = Refresh;


                    trigger OnAction()
                    var
                        CU: Codeunit "Invoice";
                    begin
                        CU.CheckPostedSalesInvoiceSentStatus(Rec);
                    end;
                }
                action("Get Sent Document Details")
                {
                    ApplicationArea = All;
                    Image = Refresh;

                    trigger OnAction()
                    var
                        ApiMgt: Codeunit Invoice;
                    begin
                        ApiMgt.GetSentDocumentDetails(Rec."No.");
                        Message('Sent document details retrieved successfully.');
                    end;
                }
                action("View Sent Documents")
                {
                    ApplicationArea = All;
                    Image = List;

                    trigger OnAction()
                    var
                        SentHdr: Record "Sent Document Header";
                    begin
                        SentHdr.Reset();
                        SentHdr.SetRange("Invoice No.", Rec."No.");
                        Page.Run(Page::"Sent Documents", SentHdr);
                    end;
                }
            }
        }
        addafter(Category_Process)
        {
            group("Category_Invoice Approvals")
            {
                Caption = 'E-Invoice', Comment = 'Actions related to invoice approvals';

                actionref(DownloadSalesInvoice_Promoted; "Download Sales Invoice XML")
                {
                }
                actionref(SendDocument_Promoted; SendDocument)
                {
                }
                actionref(CheckSentStatus_Promoted; "Checks the state of sent document")
                {
                }
                actionref(GetSentDocumentDetails_Promoted; "Get Sent Document Details")
                {
                }
                actionref(ViewSentDocuments_Promoted; "View Sent Documents")
                {
                }
            }
        }
    }
}
