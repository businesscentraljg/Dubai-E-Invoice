table 50004 "Sent Status Stg"
{
    Caption = 'Sent Status Staging';
    DataClassification = CustomerContent;
    LookupPageId = "Sent Status Stg";
    DrillDownPageId = "Sent Status Stg";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Config Type"; Integer) { }
        field(3; "Config Id"; Integer) { }
        field(4; "Web Status Id"; BigInteger) { }
        field(5; "Web Doc Id"; Integer) { }
        field(6; "Message Id"; Guid) { }
        field(7; "Status Type Id"; Integer) { }
        field(8; "Status Date"; DateTime) { }
        field(9; Description; Text[250]) { }
        field(10; "Transport Type"; Code[20]) { }
        field(11; Type; Code[20]) { }
        field(12; Stage; Code[30]) { }
        field(13; State; Code[20]) { }
        field(14; Code; Code[30]) { }
        field(15; Confirmed; Boolean) { }
        field(16; "Confirmed At"; DateTime) { }
        field(17; "Raw JSON"; Blob)
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
        key(ConfigStatus; "Config Type", "Config Id", "Web Status Id")
        {
        }
    }
}

