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
        field(4; "No."; Code[30])
        {
            Caption = 'No.', Comment = 'ESP="Nº"';
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

            trigger OnValidate()
            begin
                "No. Modify" := "No.";
            end;
        }
        field(5; Name; Text[250])
        {
            Caption = 'Name', Comment = 'ESP="Nombre"';
            trigger OnValidate()
            begin
                "Name Modify" := Name;
            end;
        }
        field(6; Quantity; Text[10])
        {
            Caption = 'Quantity', Comment = 'ESP="Cantidad"';
            trigger OnValidate()
            begin
                "Quantity Modify" := Quantity;
            end;
        }
        field(7; Price; Text[20])
        {
            Caption = 'Price', Comment = 'ESP="Precio"';
            trigger OnValidate()
            begin
                "Price Modify" := Price;
            end;
        }
        field(8; SubTotal; Text[20])
        {
            Caption = 'SubTotal', Comment = 'ESP="Subtotal"';
            trigger OnValidate()
            begin
                "SubTotal Modify" := SubTotal;
            end;
        }
        field(9; "Type Modified"; Enum "Purchase Line Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Type', Comment = 'ESP="Tipo"';
            InitValue = Item;
        }
        field(10; "No. Modify"; Code[30])
        {
            Caption = 'No. Modify', Comment = 'ESP="Nº Modificado"';


        }
        field(11; "Name Modify"; Text[250])
        {
            Caption = 'Name Modify', Comment = 'ESP="Nombre"';

        }
        field(12; "Quantity Modify"; Text[10])
        {
            Caption = 'Quantity Modify', Comment = 'ESP="Cantidad"';

        }
        field(13; "Price Modify"; Text[20])
        {
            Caption = 'Price Modify', Comment = 'ESP="Precio"';

        }
        field(14; "SubTotal Modify"; Text[20])
        {
            Caption = 'SubTotal Modify', Comment = 'ESP="Subtotal"';

        }
        field(15; "% Discount"; Text[20])
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
    procedure SaveModifiedFields()
    var
        DocumentLine: Record "Document Line";
    begin
        Rec.setfilter("Line No.", '<>%1', rec."Line No.");
        if Rec.FindSet() then begin
            repeat
                DocumentLine.Get(Rec.ID, Rec."Line No.");
                DocumentLine."No." := Rec."No. Modify";
                DocumentLine.Name := Rec."Name Modify";
                DocumentLine.Quantity := Rec."Quantity Modify";
                DocumentLine.Price := Rec."Price Modify";
                DocumentLine.SubTotal := Rec."SubTotal Modify";
                DocumentLine.Modify(false);
            until Rec.Next() = 0;
        end;
    end;
}
