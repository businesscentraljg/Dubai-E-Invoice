page 50003 "Received Document Stg"
{
    ApplicationArea = All;
    Caption = 'Received Documents';
    PageType = List;
    SourceTable = "Received Document Stg";
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
                field("Message Id"; Rec."Message Id") { }
                field("Source Name"; Rec."Source Name") { }
                field("Source Alias"; Rec."Source Alias") { }
                field("Source Qualifier"; Rec."Source Qualifier") { }
                field("Specification Business Type"; Rec."Specification Business Type") { }
                field("Compression Type"; Rec."Compression Type") { }
                field("Processing Date"; Rec."Processing Date") { }
                field(Confirmed; Rec.Confirmed) { }
                field("Confirmed At"; Rec."Confirmed At") { }
                field(Converted; Rec.Converted) { }
                field("Converted At"; Rec."Converted At") { }
                field("BC Document No."; Rec."BC Document No.") { }
                field("Processing Error"; Rec."Processing Error") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Process pending received docs")
            {
                Caption = 'Process pending received docs';
                Image = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Processor: Codeunit "EDI Received Processor";
                begin
                    Processor.ProcessPendingReceivedDocuments();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
