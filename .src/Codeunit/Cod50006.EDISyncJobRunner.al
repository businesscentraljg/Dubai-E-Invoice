codeunit 50006 "EDI Sync Job Runner"
{
    trigger OnRun()
    begin
        RunSyncCycle();
    end;

    procedure RunSyncCycle()
    var
        API: Codeunit "EDI API Management";
        Processor: Codeunit "EDI Received Processor";
        Setup: Record "Invoice Setup";
    begin
        API.PullReceivedDocuments();
        API.ConfirmReceivedDocuments();
        API.PullSentDetails();
        API.ConfirmSentDetails();
        API.PullSentStatuses();
        API.ConfirmSentStatuses();
        API.PullDocumentErrors();

        GetSetup(Setup);
        if Setup."Auto Process Received" then
            Processor.ProcessPendingReceivedDocuments();
    end;

    local procedure GetSetup(var Setup: Record "Invoice Setup")
    begin
        if Setup.Get() then
            exit;
        if Setup.Get('') then
            exit;
        Error('Invoice Setup not found.');
    end;
}

