tableextension 50001 "User Setup Ext" extends "User Setup"
{
    fields
    {
        field(50000; "Subscription Config Id"; Integer)
        {
            Caption = 'Subscription Config Id';
            DataClassification = ToBeClassified;
            TableRelation = "User Subscription"."Config Id";
            BlankZero = true;
        }
    }
}
