table 50003 "Sent Document Line"
{
    DataClassification = CustomerContent;
    LookupPageId = "Sent Document Lines";
    DrillDownPageId = "Sent Document Lines";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }

        field(2; "Header Entry No."; Integer) { }

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
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Header; "Header Entry No.") { }
    }
}
