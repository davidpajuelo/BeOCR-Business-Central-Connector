table 50603 "Document Line"
{
    Caption = 'Document Line', Comment = 'ESP="Línea de Documento"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID', Comment = 'ESP="ID"';
            DataClassification = SystemMetadata;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'ESP="Nº Línea"';
            DataClassification = ToBeClassified;
        }
        field(3; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type', Comment = 'ESP="Tipo"';
            DataClassification = ToBeClassified;
            InitValue = Item;

        }
        field(4; "No. BC"; Code[30])
        {
            Caption = 'No. BC', Comment = 'ESP="Nº Business Central"';
            TableRelation =
            if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const("Fixed Asset")) "Fixed Asset"
            else
            if (Type = const("Charge (Item)")) "Item Charge"
            else
            if (Type = const(Item)) Item
            else
            if (Type = const("Allocation Account")) "Allocation Account"
            else
            if (Type = const(Resource)) Resource;

        }
        field(5; Name; Text[250])
        {
            Caption = 'Name', Comment = 'ESP="Nombre"';
        }
        field(6; Quantity; Text[10])
        {
            Caption = 'Quantity', Comment = 'ESP="Cantidad"';

        }
        field(7; Price; Text[20])
        {
            Caption = 'Price', Comment = 'ESP="Precio"';

        }
        field(8; SubTotal; Text[20])
        {
            Caption = 'SubTotal', Comment = 'ESP="Subtotal"';

        }

        field(9; "No. Import"; Code[30])
        {
            Caption = 'No. Import', Comment = 'ESP="Nº Importado"';


        }
        field(10; "% Discount"; Text[20])
        {
            Caption = '% Discount', Comment = 'ESP="% Descuento"';
        }
    }

    keys
    {
        key(PK; ID, "Line No.")
        {
            Clustered = true;
        }
    }

}
