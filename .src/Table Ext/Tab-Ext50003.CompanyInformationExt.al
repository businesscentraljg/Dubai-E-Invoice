tableextension 50003 "Company Information Ext" extends "Company Information"
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
