table 50001 "User Subscription"
{
    Caption = 'UserSubscription';
    DataClassification = ToBeClassified;
    LookupPageId = "User Subscription";

    fields
    {
        field(1; "Config Id"; Integer)
        {
            Caption = 'Config Id';
            DataClassification = CustomerContent;
        }

        field(2; "Config Type"; Integer)
        {
            Caption = 'Config Type';
            DataClassification = CustomerContent;
        }

        // Source Partner
        field(10; "Source Name"; Text[100])
        {
            Caption = 'Source Partner Name';
        }

        field(11; "Source Alias"; Text[50])
        {
            Caption = 'Source Alias';
        }

        field(12; "Source Qualifier"; Text[30])
        {
            Caption = 'Source Qualifier';
        }

        // Destination Partner
        field(20; "Destination Name"; Text[100])
        {
            Caption = 'Destination Partner Name';
        }

        field(21; "Destination Alias"; Text[50])
        {
            Caption = 'Destination Alias';
        }

        field(22; "Destination Qualifier"; Text[30])
        {
            Caption = 'Destination Qualifier';
        }

        // Specification
        field(30; "Spec Business Type"; Code[20])
        {
            Caption = 'Specification Business Type';
        }

        field(31; "Spec Type"; Code[20])
        {
            Caption = 'Specification Type';
        }

        field(32; "Spec Version"; Text[50])
        {
            Caption = 'Specification Version';
        }

        field(33; "Spec Standard"; Code[10])
        {
            Caption = 'Specification Standard';
        }

        // Subscription
        field(40; "Subscription Test"; Boolean)
        {
            Caption = 'Subscription Test';
        }

        field(41; "Subscription Direction"; Boolean)
        {
            Caption = 'Subscription Direction';
        }
    }
    keys
    {
        key(PK; "Config Id")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Config Id", "Config Type")
        {
        }
    }
}
