page 50000 "Invoice Setup"
{
    ApplicationArea = All;
    Caption = 'Invoice Setup';
    PageType = Card;
    SourceTable = "Invoice Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Base URL"; Rec."Base URL")
                {
                    ToolTip = 'Specifies the value of the Base URL field.', Comment = '%';
                }
                field(Login; Rec.Login)
                {
                    ToolTip = 'Specifies the value of the Login field.', Comment = '%';
                }
                field(Password; Rec.Password)
                {
                    ToolTip = 'Specifies the value of the Password field.', Comment = '%';
                }
                field("Bearer Token"; Rec."Bearer Token")
                {
                    ToolTip = 'Specifies the value of the Bearer Token field.', Comment = '%';
                }
                field("Token Expiry"; Rec."Token Expiry")
                {
                    ToolTip = 'Specifies the value of the Token Expiry field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GenerateToken)
            {
                Caption = 'Generate Token';
                Image = Refresh;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Generate Token action.';
                trigger OnAction()
                var
                    CU: Codeunit "Authenticate Management";
                begin
                    if not Confirm('Do you want to Genrate Token?') then exit;
                    CU.GenerateToken();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
