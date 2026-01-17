pageextension 50003 "Company Information Ext" extends "Company Information"
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
