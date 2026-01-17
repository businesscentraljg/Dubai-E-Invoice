table 50002 "Sent Document Header"
{
    DataClassification = CustomerContent;
    LookupPageId = "Sent Documents";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }

        field(2; "Config Type"; Integer) { }
        field(3; "Config Id"; Integer) { }

        field(4; "Specification Business Type"; Code[10]) { }

        field(5; "Control Number"; Code[50]) { }
        field(6; "Submission Id"; Guid) { }

        field(7; "Invoice No."; Code[20]) { }
        field(8; "Customer No."; Code[20]) { }

        // field(9; Status; Enum "Sent Document Status") { }

        field(10; "Last API Call DateTime"; DateTime) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
    trigger OnDelete()
    var
        SentLine: Record "Sent Document Line";
    begin
        SentLine.Reset();
        SentLine.SetRange("Header Entry No.", Rec."Entry No.");
        if SentLine.FindSet() then
            SentLine.DeleteAll();
    end;
}
