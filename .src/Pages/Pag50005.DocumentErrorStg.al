page 50005 "Document Error Stg"
{
    ApplicationArea = All;
    Caption = 'Document Errors';
    PageType = List;
    SourceTable = "Document Error Stg";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Config Type"; Rec."Config Type") { }
                field("Config Id"; Rec."Config Id") { }
                field("Web Doc Id"; Rec."Web Doc Id") { }
                field("Processing Status"; Rec."Processing Status") { }
                field("Error Description"; Rec."Error Description") { }
                field("Fetched At"; Rec."Fetched At") { }
            }
        }
    }
}

