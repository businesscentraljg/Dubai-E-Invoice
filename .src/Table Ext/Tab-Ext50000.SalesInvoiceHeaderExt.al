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
        field(50002; "Control Number"; Text[100])
        {
            Caption = 'Control Number';
            DataClassification = ToBeClassified;
        }
        field(50003; "Sent Status"; Boolean)
        {
            Caption = 'Sent Status';
            DataClassification = ToBeClassified;
        }
        field(50004; "Submission Id"; Text[100])
        {
            Caption = 'Submission Id';
            DataClassification = ToBeClassified;
        }
    }
}
