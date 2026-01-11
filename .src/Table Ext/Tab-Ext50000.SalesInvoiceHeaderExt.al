tableextension 50000 "Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(50000; "Invoice Send"; Boolean)
        {
            Caption = 'Invoice Send';
            DataClassification = ToBeClassified;
        }
        field(50001; "Invoice Send DateTime"; DateTime)
        {
            Caption = 'Invoice Send DateTime';
            DataClassification = ToBeClassified;
        }
    }
}
