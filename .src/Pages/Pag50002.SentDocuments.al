page 50002 "Sent Documents"
{
    ApplicationArea = All;
    Caption = 'Sent Documents';
    PageType = List;
    SourceTable = "Sent Documents";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("Message Id"; Rec."Message Id")
                {
                    ToolTip = 'Specifies the value of the Message Id field.', Comment = '%';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the value of the Processing Status field.', Comment = '%';
                }
                field("Web Doc Id"; Rec."Web Doc Id")
                {
                    ToolTip = 'Specifies the value of the Web Doc Id field.', Comment = '%';
                }
                field("Submission Id"; Rec."Submission Id")
                {
                    ToolTip = 'Specifies the value of the Submission Id field.', Comment = '%';
                }
                field("Control Number"; Rec."Control Number")
                {
                    ToolTip = 'Specifies the value of the Control Number field.', Comment = '%';
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ToolTip = 'Specifies the value of the Destination Name field.', Comment = '%';
                }
                field("Destination Alias"; Rec."Destination Alias")
                {
                    ToolTip = 'Specifies the value of the Destination Alias field.', Comment = '%';
                }
                field("Destination Qualifier"; Rec."Destination Qualifier")
                {
                    ToolTip = 'Specifies the value of the Destination Qualifier field.', Comment = '%';
                }
                field("Compression Type"; Rec."Compression Type")
                {
                    ToolTip = 'Specifies the value of the Compression Type field.', Comment = '%';
                }
                field("Processing Date"; Rec."Processing Date")
                {
                    ToolTip = 'Specifies the value of the Processing Date field.', Comment = '%';
                }
                field("Raw JSON"; Rec."Raw JSON")
                {
                    ToolTip = 'Specifies the value of the Raw JSON field.', Comment = '%';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
            }
        }
    }
}
