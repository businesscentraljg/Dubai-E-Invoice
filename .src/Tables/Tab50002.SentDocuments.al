table 50002 "Sent Documents"
{
    DataClassification = CustomerContent;
    LookupPageId = "Sent Documents";
    DrillDownPageId = "Sent Documents";
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }

        field(3; "Message Id"; Guid) { }
        field(4; "Processing Status"; Boolean) { }
        field(5; "Web Doc Id"; Integer) { }
        field(6; "Submission Id"; Guid) { }
        field(7; "Control Number"; Code[50]) { }

        field(8; "Destination Name"; Text[100]) { }
        field(9; "Destination Alias"; Code[30]) { }
        field(10; "Destination Qualifier"; Code[10]) { }

        field(11; "Compression Type"; Code[10]) { }
        field(12; "Processing Date"; DateTime) { }

        field(13; "Raw JSON"; Blob)
        {
            SubType = Memo;
        }
        field(14; "Config Type"; Integer) { }
        field(15; "Config Id"; Integer) { }

        field(16; "Specification Business Type"; Code[10]) { }

    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
