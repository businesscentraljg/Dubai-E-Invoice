page 50001 Subscription
{
    ApplicationArea = All;
    Caption = 'Subscription';
    PageType = List;
    SourceTable = Subscription;
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Config Id"; Rec."Config Id")
                {
                    ToolTip = 'Specifies the value of the Config Id field.', Comment = '%';
                }
                field("Config Type"; Rec."Config Type")
                {
                    ToolTip = 'Specifies the value of the Config Type field.', Comment = '%';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ToolTip = 'Specifies the value of the Source Partner Name field.', Comment = '%';
                }
                field("Source Alias"; Rec."Source Alias")
                {
                    ToolTip = 'Specifies the value of the Source Alias field.', Comment = '%';
                }
                field("Source Qualifier"; Rec."Source Qualifier")
                {
                    ToolTip = 'Specifies the value of the Source Qualifier field.', Comment = '%';
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ToolTip = 'Specifies the value of the Destination Partner Name field.', Comment = '%';
                }
                field("Destination Alias"; Rec."Destination Alias")
                {
                    ToolTip = 'Specifies the value of the Destination Alias field.', Comment = '%';
                }
                field("Destination Qualifier"; Rec."Destination Qualifier")
                {
                    ToolTip = 'Specifies the value of the Destination Qualifier field.', Comment = '%';
                }
                field("Spec Business Type"; Rec."Spec Business Type")
                {
                    ToolTip = 'Specifies the value of the Specification Business Type field.', Comment = '%';
                }
                field("Spec Type"; Rec."Spec Type")
                {
                    ToolTip = 'Specifies the value of the Specification Type field.', Comment = '%';
                }
                field("Spec Version"; Rec."Spec Version")
                {
                    ToolTip = 'Specifies the value of the Specification Version field.', Comment = '%';
                }
                field("Spec Standard"; Rec."Spec Standard")
                {
                    ToolTip = 'Specifies the value of the Specification Standard field.', Comment = '%';
                }
                field("Subscription Test"; Rec."Subscription Test")
                {
                    ToolTip = 'Specifies the value of the Subscription Test field.', Comment = '%';
                }
                field("Subscription Direction"; Rec."Subscription Direction")
                {
                    ToolTip = 'Specifies the value of the Subscription Direction field.', Comment = '%';
                }
            }
        }
    }
}
