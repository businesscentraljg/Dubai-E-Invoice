pageextension 50001 "User Setup Ext" extends "User Setup"
{
    layout
    {
        addafter(PhoneNo)
        {
            field("Subscription Config Id"; Rec."Subscription Config Id")
            {
                ApplicationArea = All;
                Caption = 'Subscription Config Id';
                ToolTip = 'Specifies the Subscription Config Id for the user.';
            }
        }
    }
}
