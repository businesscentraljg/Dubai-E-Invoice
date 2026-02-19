codeunit 50003 "Subscription API Import"
{
    procedure ImportSubscriptions()
    var
        API: Codeunit "EDI API Management";
    begin
        API.ImportSubscriptions();
    end;
}

