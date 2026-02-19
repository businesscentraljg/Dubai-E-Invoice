table 50005 "Document Error Stg"
{
    Caption = 'Document Error Staging';
    DataClassification = CustomerContent;
    LookupPageId = "Document Error Stg";
    DrillDownPageId = "Document Error Stg";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Config Type"; Integer) { }
        field(3; "Config Id"; Integer) { }
        field(4; "Web Doc Id"; Integer) { }
        field(5; "Processing Status"; Boolean) { }
        field(6; "Error Description"; Text[250]) { }
        field(7; "Fetched At"; DateTime) { }
        field(8; "Error Details"; Blob)
        {
            SubType = Memo;
        }
        field(9; "Raw JSON"; Blob)
        {
            SubType = Memo;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ConfigDoc; "Config Type", "Config Id", "Web Doc Id")
        {
        }
    }
}

