table 50003 "Received Document Stg"
{
    Caption = 'Received Document Staging';
    DataClassification = CustomerContent;
    LookupPageId = "Received Document Stg";
    DrillDownPageId = "Received Document Stg";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Config Type"; Integer) { }
        field(3; "Config Id"; Integer) { }
        field(4; "Web Doc Id"; Integer) { }
        field(5; "Message Id"; Guid) { }
        field(6; "Source Name"; Text[100]) { }
        field(7; "Source Alias"; Text[50]) { }
        field(8; "Source Qualifier"; Text[30]) { }
        field(9; "Compression Type"; Code[20]) { }
        field(10; "Specification Business Type"; Code[20]) { }
        field(11; "Processing Date"; DateTime) { }
        field(12; Confirmed; Boolean) { }
        field(13; "Confirmed At"; DateTime) { }
        field(14; "Document Content"; Blob)
        {
            SubType = Memo;
        }
        field(15; "Raw JSON"; Blob)
        {
            SubType = Memo;
        }
        field(16; Converted; Boolean) { }
        field(17; "Converted At"; DateTime) { }
        field(18; "BC Document No."; Code[20]) { }
        field(19; "Processing Error"; Text[250]) { }
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
