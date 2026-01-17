page 50002 "Sent Documents"
{
    ApplicationArea = All;
    Caption = 'Sent Documents';
    PageType = List;
    SourceTable = "Sent Document Header";
    UsageCategory = Lists;
    CardPageId = "Sent Document";
    Editable = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Config Type"; Rec."Config Type")
                {
                    ToolTip = 'Specifies the value of the Config Type field.', Comment = '%';
                }
                field("Config Id"; Rec."Config Id")
                {
                    ToolTip = 'Specifies the value of the Config Id field.', Comment = '%';
                }
                field("Specification Business Type"; Rec."Specification Business Type")
                {
                    ToolTip = 'Specifies the value of the Specification Business Type field.', Comment = '%';
                }
                field("Control Number"; Rec."Control Number")
                {
                    ToolTip = 'Specifies the value of the Control Number field.', Comment = '%';
                }
                field("Submission Id"; Rec."Submission Id")
                {
                    ToolTip = 'Specifies the value of the Submission Id field.', Comment = '%';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Invoice No. field.', Comment = '%';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.', Comment = '%';
                }
                field("Last API Call DateTime"; Rec."Last API Call DateTime")
                {
                    ToolTip = 'Specifies the value of the Last API Call DateTime field.', Comment = '%';
                }
            }
        }
    }
}
