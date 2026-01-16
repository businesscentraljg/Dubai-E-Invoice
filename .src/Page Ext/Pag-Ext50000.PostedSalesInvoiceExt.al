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
        addlast(Processing)
        {
            group(InvoiceActions)
            {
                Caption = 'Invoice';

                action(SendDocument)
                {
                    Caption = 'Send Document';
                    Image = SendTo;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;

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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

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
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        CU: Codeunit "Invoice";
                    begin
                        CU.CheckPostedSalesInvoiceSentStatus(Rec);
                    end;
                }
            }

        }
    }
}
