pageextension 50004 "Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter(General)
        {
            group(EInvoiceDetails)
            {
                Caption = 'E-Invoice Details';
                field(ILN; Rec.ILN)
                {
                    ApplicationArea = All;
                    Caption = 'ILN';
                }
            }
        }
    }
}

