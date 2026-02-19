table 50000 "Invoice Setup"
{
    Caption = 'Invoice Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
        }
        field(3; "Login"; Text[100])
        {
            Caption = 'Login';
        }
        field(4; "Password"; Text[100])
        {
            ExtendedDatatype = Masked;
        }

        field(5; "Bearer Token"; Text[2048])
        {
            Caption = 'Bearer Token';
            Editable = false;
            ExtendedDatatype = Masked;
        }

        field(6; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            Editable = false;
        }
        field(7; "Show Message"; Boolean)
        {
            Caption = 'Show Message';
        }
        field(8; "Default Config Type"; Integer)
        {
            Caption = 'Default Config Type';
            InitValue = 1;
        }
        field(9; "Default Config Id"; Integer)
        {
            Caption = 'Default Config Id';
        }
        field(10; "Default Business Type"; Code[20])
        {
            Caption = 'Default Business Type';
            InitValue = 'INVOIC';
        }
        field(11; "Receive Top"; Integer)
        {
            Caption = 'Receive Top';
            InitValue = 50;
        }
        field(12; "Token TTL (Minutes)"; Integer)
        {
            Caption = 'Token TTL (Minutes)';
            InitValue = 50;
        }
        field(13; "Auto Process Received"; Boolean)
        {
            Caption = 'Auto Process Received';
        }
        field(14; "Default Vendor No."; Code[20])
        {
            Caption = 'Default Vendor No.';
            TableRelation = Vendor."No.";
        }
        field(15; "Default Purch. G/L Account No."; Code[20])
        {
            Caption = 'Default Purch. G/L Account No.';
            TableRelation = "G/L Account"."No.";
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
