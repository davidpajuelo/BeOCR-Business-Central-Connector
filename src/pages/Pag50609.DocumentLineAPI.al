page 50609 "Document Line API"
{
    PageType = API;
    Caption = 'documentLine', Locked = true;
    APIPublisher = 'beOCR';
    APIGroup = 'ocr';
    APIVersion = 'v1.0';
    EntityName = 'documentLine';
    EntitySetName = 'documentLines';
    EntityCaption = 'Document Line';
    EntitySetCaption = 'Document Lines';
    SourceTable = "Document Line";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(documentId; Rec.ID)
                {
                    Caption = 'Document Id', Locked = true;
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }


                field(numberImport; Rec."No. Import")
                {
                    Caption = 'No. Import', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(price; Rec.Price)
                {
                    Caption = 'Price', Locked = true;
                }
                field(discountPercent; Rec."% Discount")
                {
                    Caption = '% Discount', Locked = true;
                }
                field(subTotal; Rec.SubTotal)
                {
                    Caption = 'SubTotal', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DocumentLine: Record "Document Line";
    begin
        if Rec."Line No." = 0 then begin
            DocumentLine.SetRange(ID, Rec.ID);
            if DocumentLine.FindLast() then
                Rec."Line No." := DocumentLine."Line No." + 1
            else
                Rec."Line No." := 1;
        end;
    end;
}
