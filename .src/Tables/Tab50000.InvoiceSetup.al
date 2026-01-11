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
        }

        field(6; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            Editable = false;
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
