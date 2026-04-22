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
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number.';
                    Editable = false;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type', Comment = 'ESP="Tipo"';
                    ToolTip = 'Specifies the type Line.';
                }
                field("No."; Rec."No.")
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
                field("No. Modify"; Rec."No. Modify")
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
    actions
    {
        area(Processing)
        {
            action(Guardar)
            {
                ApplicationArea = All;
                Caption = 'Guardar';
                ToolTip = 'Guarda las líneas del documento en la base de datos';
                Image = Save;
                Visible = false;
                trigger OnAction()
                var
                begin
                    Rec.SaveModifiedFields();
                    message('Guardado');
                    isModify := true;
                    CurrPage.Update();
                end;
            }
            action(SearchProduct)
            {
                ApplicationArea = All;
                Caption = 'Buscar Producto';
                Visible = false;
                ToolTip = 'Busca el producto por nombre usando el API de búsqueda';
                Image = Find;
                trigger OnAction()
                var
                    OCRIntegration: Codeunit "OCR Integration";
                    ResponseText: Text;
                    JsonObject: JsonObject;
                    JsonToken: JsonToken;
                begin
                    if Rec."Name Modify" = '' then begin
                        message('Por favor ingrese un nombre de producto para buscar');
                        exit;
                    end;
                    OCRIntegration.SetMethod(Enum::"Method OCR API"::record_search);
                    ResponseText := OCRIntegration.SearchProductByName(Rec."Name Modify");

                    if JsonObject.ReadFrom(ResponseText) then begin
                        if JsonObject.Get('code', JsonToken) then
                            Rec."No. Modify" := JsonToken.AsValue().AsText();
                        if JsonObject.Get('name', JsonToken) then
                            Rec."Name Modify" := JsonToken.AsValue().AsText();
                        message('Producto encontrado: ' + Rec."Name Modify");
                    end else begin
                        message('No se encontró el producto o error en la respuesta');
                    end;

                    isModify := true;
                    CurrPage.Update();
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
    begin
        if isModify then begin
            setcolor();
            isModify := false;
        end;
    end;



    local procedure setcolor()
    var
        StyleLbl: label 'favorable';
    begin
        if rec."No." <> rec."No. Modify" then
            noStyle := StyleLbl
        else
            noStyle := '';
        if rec.Name <> rec."Name Modify" then
            nameStyle := StyleLbl
        else
            nameStyle := '';
        if rec.Quantity <> rec."Quantity Modify" then
            quantityStyle := StyleLbl
        else
            quantityStyle := '';
        if rec.Price <> rec."Price Modify" then
            priceStyle := StyleLbl
        else
            priceStyle := '';
        if rec.SubTotal <> rec."SubTotal Modify" then
            subtotalStyle := StyleLbl
        else
            subtotalStyle := '';
    end;



    var
        TempDocumentLine: Record "Document Line" temporary;
        noStyle: text;
        nameStyle: text;
        quantityStyle: text;
        priceStyle: text;
        subtotalStyle: text;
        isModify: Boolean;
}
