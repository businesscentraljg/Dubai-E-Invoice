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
                field("Default Config Type"; Rec."Default Config Type")
                {
                    ToolTip = 'Specifies default ConfigType used by synchronization actions.';
                }
                field("Default Config Id"; Rec."Default Config Id")
                {
                    ToolTip = 'Specifies default ConfigId used by synchronization actions.';
                }
                field("Default Business Type"; Rec."Default Business Type")
                {
                    ToolTip = 'Specifies business type filter, e.g. INVOIC.';
                }
                field("Receive Top"; Rec."Receive Top")
                {
                    ToolTip = 'Specifies max number of documents to receive per call.';
                }
                field("Token TTL (Minutes)"; Rec."Token TTL (Minutes)")
                {
                    ToolTip = 'Specifies JWT cache lifetime in minutes.';
                }
                field("Auto Process Received"; Rec."Auto Process Received")
                {
                    ToolTip = 'Specifies whether received staged documents are automatically converted to BC purchase invoices during sync.';
                }
                field("Default Vendor No."; Rec."Default Vendor No.")
                {
                    ToolTip = 'Specifies fallback vendor when vendor cannot be resolved from incoming XML.';
                }
                field("Default Purch. G/L Account No."; Rec."Default Purch. G/L Account No.")
                {
                    ToolTip = 'Specifies default G/L account used when creating purchase invoice lines from received XML.';
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
                        API: Codeunit "EDI API Management";
                    begin
                        API.ImportSubscriptions();
                        Message('Subscriptions imported successfully.');
                    end;
                }
                action("Gets details of sent documents")
                {
                    Caption = 'Gets details of sent documents';
                    Image = Import;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.PullSentDetails();
                        Message('Sent document details synchronized.');
                    end;
                }
                action("Receive documents")
                {
                    Caption = 'Receive documents';
                    Image = Import;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.PullReceivedDocuments();
                        Message('Received documents synchronized.');
                    end;
                }
                action("Confirm received documents")
                {
                    Caption = 'Confirm received documents';
                    Image = Approve;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.ConfirmReceivedDocuments();
                        Message('Received documents confirmation sent.');
                    end;
                }
                action("Get sent statuses")
                {
                    Caption = 'Get sent statuses';
                    Image = Refresh;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.PullSentStatuses();
                        Message('Sent statuses synchronized.');
                    end;
                }
                action("Confirm sent statuses")
                {
                    Caption = 'Confirm sent statuses';
                    Image = Approve;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.ConfirmSentStatuses();
                        Message('Sent statuses confirmation sent.');
                    end;
                }
                action("Confirm sent details")
                {
                    Caption = 'Confirm sent details';
                    Image = Approve;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.ConfirmSentDetails();
                        Message('Sent document details confirmation sent.');
                    end;
                }
                action("Get document errors")
                {
                    Caption = 'Get document errors';
                    Image = Error;
                    trigger OnAction()
                    var
                        API: Codeunit "EDI API Management";
                    begin
                        API.PullDocumentErrors();
                        Message('Document errors synchronized.');
                    end;
                }
                action("Run full sync cycle")
                {
                    Caption = 'Run full sync cycle';
                    Image = RefreshLines;
                    trigger OnAction()
                    var
                        Runner: Codeunit "EDI Sync Job Runner";
                    begin
                        Runner.RunSyncCycle();
                        Message('Full sync cycle completed.');
                    end;
                }
                action("Open Job Queue Entries")
                {
                    Caption = 'Open Job Queue Entries';
                    Image = Job;
                    trigger OnAction()
                    begin
                        Page.Run(Page::"Job Queue Entries");
                    end;
                }
                action("Process received to BC docs")
                {
                    Caption = 'Process received to BC docs';
                    Image = Process;
                    trigger OnAction()
                    var
                        Processor: Codeunit "EDI Received Processor";
                    begin
                        Processor.ProcessPendingReceivedDocuments();
                        Message('Received document conversion completed.');
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
                    actionref(Receivedocuments_Category; "Receive documents")
                    {
                    }
                    actionref(Confirmreceiveddocuments_Category; "Confirm received documents")
                    {
                    }
                    actionref(Getsentstatuses_Category; "Get sent statuses")
                    {
                    }
                    actionref(Confirmsentstatuses_Category; "Confirm sent statuses")
                    {
                    }
                    actionref(Confirmsentdetails_Category; "Confirm sent details")
                    {
                    }
                    actionref(Getdocumenterrors_Category; "Get document errors")
                    {
                    }
                    actionref(Runfullsynccycle_Category; "Run full sync cycle")
                    {
                    }
                    actionref(OpenJobQueueEntries_Category; "Open Job Queue Entries")
                    {
                    }
                    actionref(ProcessreceivedtoBCdocs_Category; "Process received to BC docs")
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
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
