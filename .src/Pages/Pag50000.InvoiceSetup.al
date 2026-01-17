page 50000 "Invoice Setup"
{
    ApplicationArea = All;
    Caption = 'E-Invoice Setup';
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
                field("Show Message"; Rec."Show Message")
                {
                    ToolTip = 'Specifies whether to show messages during operations.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Process)
            {
                Caption = 'Process';

                action(GenerateToken)
                {
                    Caption = 'Generate Token';
                    Image = Refresh;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Generate Token action.';
                    Visible = false;
                    trigger OnAction()
                    var
                        CU: Codeunit "Authenticate Management";
                    begin
                        if not Confirm('Do you want to Genrate Token?') then exit;
                        CU.GetValidToken();
                    end;
                }
                action(ImportSubscriptions)
                {
                    Caption = 'Import Subscriptions';
                    Image = Import;
                    trigger OnAction()
                    var
                        SubAPI: Codeunit "Subscription API Import";
                    begin
                        SubAPI.ImportSubscriptions();
                        Message('Subscriptions imported successfully.');
                    end;
                }
                action("Gets details of sent documents")
                {
                    Caption = 'Gets details of sent documents';
                    Image = Import;
                    trigger OnAction()
                    var
                        SubAPI: Codeunit Invoice;
                    begin
                        SubAPI.GetSentDocumentDetails();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                group(Category_Category6)
                {
                    Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 5.';
                    actionref(GenerateToken_Category; GenerateToken)
                    {

                    }
                    actionref(ImportSubscriptions_Category; ImportSubscriptions)
                    {
                    }

                    actionref(Getsdetailsofsentdocuments_Category; "Gets details of sent documents")
                    {
                    }
                }
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
