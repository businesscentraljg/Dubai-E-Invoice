pageextension 50002 "Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group(InvoiceDetails)
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
