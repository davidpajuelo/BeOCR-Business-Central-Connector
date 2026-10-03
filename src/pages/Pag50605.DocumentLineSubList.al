page 50605 "Document Line SubList"
{
    Caption = 'BeOCR - Document Lines', Comment = 'ESP="BeOCR - Sublista de Documentos"';
    PageType = ListPart;
    SourceTable = "Document Line";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type', Comment = 'ESP="Tipo"';
                    ToolTip = 'Specifies the type Line.';
                }
                field("No."; Rec."No. BC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the account or article number.';
                    trigger OnValidate()
                    var
                    begin
                        isModify := true;
                        CurrPage.Update();
                    end;
                }
                field("No. Modify"; Rec."No. Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the account or article number.';
                    StyleExpr = noStyle;
                    trigger OnValidate()
                    var
                    begin
                        isModify := true;
                        CurrPage.Update();
                    end;
                }

                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the modified item or article name.';
                    StyleExpr = nameStyle;
                    trigger OnValidate()
                    var
                    begin
                        //isModify := true;
                        CurrPage.Update();
                    end;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                    StyleExpr = quantityStyle;
                    trigger OnValidate()
                    var
                    begin
                        //isModify := true;
                        CurrPage.Update();
                    end;
                }
                field("% Discount"; Rec."% Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the % Discount.';
                }
                field(Price; Rec."Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price.';
                    StyleExpr = priceStyle;
                    trigger OnValidate()
                    var
                    begin
                        //isModify := true;
                        CurrPage.Update();
                    end;
                }
                field("SubTotal"; Rec."SubTotal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the modified subtotal for this line.';
                    StyleExpr = subtotalStyle;
                    trigger OnValidate()
                    var
                    begin
                        //isModify := true;
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
    var
        TempDocumentLine: Record "Document Line" temporary;
        noStyle: text;
        nameStyle: text;
        quantityStyle: text;
        priceStyle: text;
        subtotalStyle: text;
        isModify: Boolean;
}
