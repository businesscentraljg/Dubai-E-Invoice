tableextension 50002 "Customer Ext" extends Customer
{
    fields
    {
        field(50000; ILN; Code[20])
        {
            Caption = 'ILN';
            DataClassification = ToBeClassified;
        }
    }
}
