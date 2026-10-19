page 50608 "Document Header API"
{
    PageType = API;
    Caption = 'documentHeader', Locked = true;
    APIPublisher = 'beOCR';
    APIGroup = 'ocr';
    APIVersion = 'v1.0';
    EntityName = 'documentHeader';
    EntitySetName = 'documentHeaders';
    EntityCaption = 'Document Header';
    EntitySetCaption = 'Document Headers';
    SourceTable = "Document Header";
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
                    Editable = false;
                }
                field(idApi; Rec."ID API")
                {
                    Caption = 'ID API', Locked = true;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(invoiceDate; Rec."Invoice Date")
                {
                    Caption = 'Invoice Date', Locked = true;
                }
                field(nif; Rec.NIF)
                {
                    Caption = 'NIF', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(vendorNumber; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.', Locked = true;
                }
                field(vatAmount; Rec."VAT Amount")
                {
                    Caption = 'VAT Amount', Locked = true;
                }
                field(total; Rec.Total)
                {
                    Caption = 'Total', Locked = true;
                }
                field(documentString; DocumentString)
                {
                    Caption = 'Document String', Locked = true;

                    trigger OnValidate()
                    begin
                        Rec.SetDocumentFromBase64(DocumentString);
                    end;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                    Editable = false;
                }
                part(documentLines; "Document Line API")
                {
                    Caption = 'Document Lines', Locked = true;
                    EntityName = 'documentLine';
                    EntitySetName = 'documentLines';
                    SubPageLink = ID = field(ID);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(DocumentString);
    end;

    var
        DocumentString: Text;
}
