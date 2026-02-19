page 50004 "Sent Status Stg"
{
    ApplicationArea = All;
    Caption = 'Sent Statuses';
    PageType = List;
    SourceTable = "Sent Status Stg";
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
                field("Web Status Id"; Rec."Web Status Id") { }
                field("Web Doc Id"; Rec."Web Doc Id") { }
                field("Message Id"; Rec."Message Id") { }
                field("Status Type Id"; Rec."Status Type Id") { }
                field("Status Date"; Rec."Status Date") { }
                field(Description; Rec.Description) { }
                field("Transport Type"; Rec."Transport Type") { }
                field(Type; Rec.Type) { }
                field(Stage; Rec.Stage) { }
                field(State; Rec.State) { }
                field(Code; Rec.Code) { }
                field(Confirmed; Rec.Confirmed) { }
                field("Confirmed At"; Rec."Confirmed At") { }
            }
        }
    }
}

