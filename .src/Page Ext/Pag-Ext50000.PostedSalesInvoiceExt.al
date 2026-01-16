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
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
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
        }
    }
}
